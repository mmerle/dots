//! tmux session/window picker built on fff (https://github.com/dmtrKovalenko/fff),
//! working like fff.nvim: its typo-resistant matcher (neo_frizbee), frecency
//! from every switch, and combo boosts for results picked repeatedly for a query.
//!
//!   tmux-sessions                            open the picker (Tab switches lists)
//!   tmux-sessions record <session>           log a session switch (tmux hook)
//!   tmux-sessions record <session> <window>  log a window switch (tmux hook)

use std::cmp::Reverse;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::{env, fs, io, mem};

use fff_search::{FFFMode, FrecencyTracker, QueryTracker};
use neo_frizbee::{Config, Matcher, Pattern, Scoring, SortStrategy};
use ratatui::crossterm::event::{self, Event, KeyCode, KeyEventKind, KeyModifiers};
use ratatui::layout::{Constraint, Layout, Margin};
use ratatui::style::{Color, Style, Stylize};
use ratatui::text::{Line, Span};
use ratatui::widgets::{Block, Paragraph, Scrollbar, ScrollbarOrientation, ScrollbarState};
use ratatui::{DefaultTerminal, Frame};

// terminal palette only, so light/dark themes just work. The cursor row matches
// fzf's --color=16: bright black background, bright white text
const BORDER: Color = Color::Black;
const CURSOR: Color = Color::DarkGray;
const CURSOR_TEXT: Color = Color::White;
const DIM: Color = Color::Black;
const MATCHED: Color = Color::Yellow;

// fff.nvim defaults: a pick counts as a combo from its 3rd time with the same query
const MIN_COMBO_COUNT: u32 = 3;
const COMBO_MULTIPLIER: i32 = 100;

struct Entry {
    // tmux target for switch-client
    target: String,
    // frecency and combo key: "session" or "session:window"
    key: String,
    name: String,
    // windows also match on their session, so `haystack` is "name session"
    haystack: String,
    detail: String,
    frecency: i32,
    current: bool,
    window: Option<Window>,
}

struct Window {
    session: String,
    session_windows: String,
    index: u32,
}

struct Item {
    entry: usize,
    score: i32,
    combo: u32,
    // char indices into the entry's haystack
    indices: Vec<u32>,
}

struct Picker {
    queries: QueryTracker,
    sessions: Vec<Entry>,
    windows: Vec<Entry>,
    showing_windows: bool,
    query: String,
    items: Vec<Item>,
    selected: usize,
}

fn main() -> io::Result<()> {
    let args: Vec<String> = env::args().skip(1).collect();
    let args: Vec<&str> = args.iter().map(String::as_str).collect();
    match args.as_slice() {
        [] => pick(),
        ["record", session] => track(session),
        ["record", session, window] => track(&window_key(session, window)),
        _ => {
            eprintln!("usage: tmux-sessions [record <session> [<window>]]");
            std::process::exit(2);
        }
    }
}

// session names can't contain ':', so window keys never collide with session keys
fn window_key(session: &str, window: &str) -> String {
    format!("{session}:{window}")
}

fn state_dir(name: &str) -> io::Result<PathBuf> {
    let state = env::var_os("XDG_STATE_HOME")
        .map(PathBuf::from)
        .unwrap_or_else(|| {
            PathBuf::from(env::var_os("HOME").unwrap_or_default()).join(".local/state")
        });
    let dir = state.join("tmux").join(name);
    fs::create_dir_all(&dir)?;
    Ok(dir)
}

fn track(key: &str) -> io::Result<()> {
    FrecencyTracker::open(state_dir("fff-sessions")?)
        .and_then(|tracker| tracker.track_access(Path::new(key)))
        .map_err(io::Error::other)
}

const CURRENT_FORMAT: &str = "current\t#{session_id}\t#{window_id}";
const SESSION_FORMAT: &str =
    "session\t#{session_id}\t#{session_name}\t#{session_windows}\t#{session_last_attached}";
const WINDOW_FORMAT: &str = "window\t#{session_id}\t#{window_id}\t#{session_name}\t#{session_windows}\t#{window_index}\t#{window_name}\t#{pane_current_command}\t#{window_activity}";

// one tmux call for everything, since each process spawn is most of the startup cost
fn load_entries() -> io::Result<(Vec<Entry>, Vec<Entry>)> {
    let tracker = FrecencyTracker::open(state_dir("fff-sessions")?).map_err(io::Error::other)?;
    let out = Command::new("tmux")
        .args(["display-message", "-p", CURRENT_FORMAT, ";"])
        .args(["list-sessions", "-F", SESSION_FORMAT, ";"])
        .args(["list-windows", "-a", "-F", WINDOW_FORMAT])
        .output()?;
    if !out.status.success() {
        return Err(io::Error::other(
            String::from_utf8_lossy(&out.stderr).trim().to_string(),
        ));
    }

    let frecency = |key: &str| tracker.get_access_score(Path::new(key), FFFMode::Neovim) as i32;
    let (mut current_session, mut current_window) = ("", "");
    let mut sessions = Vec::new();
    let mut windows = Vec::new();

    for line in String::from_utf8_lossy(&out.stdout).lines() {
        match line.split('\t').collect::<Vec<_>>().as_slice() {
            ["current", sid, wid] => (current_session, current_window) = (sid, wid),
            ["session", id, name, window_count, last] => {
                let entry = Entry {
                    target: id.to_string(),
                    key: name.to_string(),
                    name: name.to_string(),
                    haystack: name.to_string(),
                    detail: format!("{window_count}w"),
                    frecency: frecency(name),
                    current: *id == current_session,
                    window: None,
                };
                sessions.push((entry, last.parse().unwrap_or(0)));
            }
            [
                "window",
                sid,
                wid,
                session,
                window_count,
                index,
                name,
                command,
                activity,
            ] => {
                let key = window_key(session, name);
                let entry = Entry {
                    target: format!("{sid}:{wid}"),
                    frecency: frecency(&key),
                    key,
                    name: name.to_string(),
                    haystack: format!("{name} {session}"),
                    detail: command.to_string(),
                    current: *sid == current_session && *wid == current_window,
                    window: Some(Window {
                        session: session.to_string(),
                        session_windows: window_count.to_string(),
                        index: index.parse().unwrap_or(0),
                    }),
                };
                windows.push((entry, activity.parse().unwrap_or(0)));
            }
            _ => {}
        }
    }

    Ok((rank(sessions), rank(windows)))
}

// current last, then frecency, then most recently used
fn rank(mut entries: Vec<(Entry, u64)>) -> Vec<Entry> {
    entries.sort_by_key(|(e, recency)| (e.current, Reverse(e.frecency), Reverse(*recency)));
    entries.into_iter().map(|(e, _)| e).collect()
}

fn pick() -> io::Result<()> {
    let (sessions, windows) = load_entries()?;
    let mut picker = Picker {
        queries: QueryTracker::open(state_dir("fff-queries")?).map_err(io::Error::other)?,
        sessions,
        windows,
        showing_windows: false,
        query: String::new(),
        items: Vec::new(),
        selected: 0,
    };
    picker.refilter();

    let mut terminal = ratatui::try_init()?;
    let picked = run(&mut terminal, &mut picker);
    ratatui::restore();

    let Some(entry) = picked?.then(|| picker.selected_entry()).flatten() else {
        return Ok(());
    };
    let (target, key) = (entry.target.clone(), entry.key.clone());
    let query = picker.query.trim();
    if !query.is_empty() {
        let list = picker.list_name();
        picker
            .queries
            .track_query_completion(query, list, Path::new(&key))
            .map_err(io::Error::other)?;
    }
    Command::new("tmux")
        .args(["switch-client", "-t", &target])
        .status()?;
    Ok(())
}

// true when an entry was picked
fn run(terminal: &mut DefaultTerminal, picker: &mut Picker) -> io::Result<bool> {
    loop {
        terminal.draw(|frame| picker.render(frame))?;

        let Event::Key(key) = event::read()? else {
            continue;
        };
        if key.kind != KeyEventKind::Press {
            continue;
        }
        let ctrl = key.modifiers.contains(KeyModifiers::CONTROL);

        match key.code {
            KeyCode::Esc => return Ok(false),
            KeyCode::Char('c') if ctrl => return Ok(false),
            KeyCode::Enter => return Ok(true),
            KeyCode::Tab | KeyCode::BackTab => picker.switch_list(),
            KeyCode::Up => picker.move_by(-1),
            KeyCode::Char('p' | 'k') if ctrl => picker.move_by(-1),
            KeyCode::Down => picker.move_by(1),
            KeyCode::Char('n' | 'j') if ctrl => picker.move_by(1),
            KeyCode::Char('u') if ctrl => picker.edit_query(String::clear),
            KeyCode::Char('w') if ctrl => picker.edit_query(|q| {
                let cut = q.trim_end().rfind(' ').map_or(0, |i| i + 1);
                q.truncate(cut);
            }),
            KeyCode::Backspace => picker.edit_query(|q| {
                q.pop();
            }),
            KeyCode::Char(c) if !ctrl => picker.edit_query(|q| q.push(c)),
            _ => {}
        }
    }
}

// Mirrors fff's directory scoring (fff-core score.rs): match score plus a
// frecency boost proportional to it, a 40% bonus for an exact name match, and
// fff's combo boost for the entry last picked with this query
fn filter(entries: &[Entry], query: &str, last_pick: Option<(&Path, u32)>) -> Vec<Item> {
    if query.is_empty() {
        // entries are already ranked
        return (0..entries.len())
            .map(|entry| Item {
                entry,
                score: 0,
                combo: 0,
                indices: Vec::new(),
            })
            .collect();
    }

    // every word must match, and fzf-style `!` / `^` / `$` work. fff allows at
    // least 2 typos, fine for thousands of paths but too loose for short names,
    // so this uses frizbee's suggested budget of 1 typo per 4 chars
    let patterns: Vec<Pattern> = Pattern::parse_query(query)
        .into_iter()
        .map(|pattern| {
            let max_typos = (pattern.needle.len() as u16 / 4).min(6);
            pattern.max_typos(Some(max_typos))
        })
        .collect();
    let has_uppercase = query.chars().any(char::is_uppercase);
    let config = Config {
        sort: SortStrategy::Unsorted,
        scoring: Scoring {
            capitalization_bonus: if has_uppercase { 8 } else { 0 },
            matching_case_bonus: if has_uppercase { 4 } else { 0 },
            ..Default::default()
        },
        ..Default::default()
    };

    let haystacks: Vec<&str> = entries.iter().map(|e| e.haystack.as_str()).collect();
    let mut items: Vec<Item> = Matcher::from_patterns(&patterns, &config)
        .match_list_indices(&haystacks)
        .into_iter()
        .map(|m| {
            let entry = &entries[m.index as usize];
            let base = m.score as i32;
            let frecency_boost = base.saturating_mul(entry.frecency) / 100;
            let exact_bonus = if entry.name.eq_ignore_ascii_case(query) {
                base / 5 * 2
            } else {
                0
            };
            let combo = match last_pick {
                Some((key, count)) if key == Path::new(&entry.key) => count,
                _ => 0,
            };
            let combo_boost = if combo >= MIN_COMBO_COUNT {
                combo as i32 * COMBO_MULTIPLIER
            } else {
                combo as i32 * 5
            };
            Item {
                entry: m.index as usize,
                score: base + frecency_boost + exact_bonus + combo_boost,
                combo,
                indices: m.indices,
            }
        })
        .collect();

    // like fff's current-file penalty, the current session/window sinks to the bottom
    items.sort_by_key(|item| (entries[item.entry].current, Reverse(item.score)));
    items
}

// Like choose-tree: each session's windows together in index order, with
// sessions ordered by their best-ranked window
fn group_by_session(items: &mut [Item], windows: &[Entry]) {
    let mut sessions: Vec<&str> = Vec::new();
    for item in items.iter() {
        if let Some(window) = &windows[item.entry].window
            && !sessions.contains(&window.session.as_str())
        {
            sessions.push(&window.session);
        }
    }
    items.sort_by_key(|item| {
        let window = windows[item.entry].window.as_ref();
        window.map(|w| (sessions.iter().position(|s| *s == w.session), w.index))
    });
}

// Splits `text` into runs so matched characters stand out; `offset` is where
// `text` starts in the haystack the indices refer to
fn highlight(text: &str, indices: &[u32], offset: u32, style: Style) -> Vec<Span<'static>> {
    let mut spans = Vec::new();
    let mut run = String::new();
    let mut run_matched = false;
    let styled = |run: String, matched: bool| {
        Span::styled(run, if matched { style.fg(MATCHED) } else { style })
    };

    for (i, c) in text.chars().enumerate() {
        let matched = indices.contains(&(offset + i as u32));
        if matched != run_matched && !run.is_empty() {
            spans.push(styled(mem::take(&mut run), run_matched));
        }
        run_matched = matched;
        run.push(c);
    }
    if !run.is_empty() {
        spans.push(styled(run, run_matched));
    }
    spans
}

fn justify(mut left: Vec<Span<'static>>, right: Span<'static>, width: usize) -> Line<'static> {
    let used = left.iter().map(Span::width).sum::<usize>() + right.width() + 1;
    left.push(Span::raw(" ".repeat(width.saturating_sub(used))));
    left.push(right);
    left.push(Span::raw(" "));
    Line::from(left)
}

impl Picker {
    fn entries(&self) -> &[Entry] {
        if self.showing_windows {
            &self.windows
        } else {
            &self.sessions
        }
    }

    // combo history is kept per list, the way fff keeps it per project
    fn list_name(&self) -> &'static Path {
        Path::new(if self.showing_windows { "windows" } else { "sessions" })
    }

    fn selected_entry(&self) -> Option<&Entry> {
        self.items
            .get(self.selected)
            .map(|item| &self.entries()[item.entry])
    }

    fn refilter(&mut self) {
        let query = self.query.trim();
        let last_pick = self
            .queries
            .get_last_query_entry(query, self.list_name(), 0)
            .ok()
            .flatten();
        let last_pick = last_pick.as_ref().map(|p| (p.file_path.as_path(), p.open_count));
        self.items = filter(self.entries(), query, last_pick);

        let best = self.items.first().map(|item| item.entry);
        if self.showing_windows {
            group_by_session(&mut self.items, &self.windows);
        }
        // grouping can move the best match below its siblings, so select it directly
        self.selected = self
            .items
            .iter()
            .position(|item| Some(item.entry) == best)
            .unwrap_or(0);
    }

    fn edit_query(&mut self, edit: impl FnOnce(&mut String)) {
        edit(&mut self.query);
        self.refilter();
    }

    fn switch_list(&mut self) {
        self.showing_windows = !self.showing_windows;
        self.refilter();
    }

    fn move_by(&mut self, delta: isize) {
        let len = self.items.len() as isize;
        if len > 0 {
            self.selected = (self.selected as isize + delta).rem_euclid(len) as usize;
        }
    }

    fn render(&self, frame: &mut Frame) {
        let [prompt_area, list_area] =
            Layout::vertical([Constraint::Length(3), Constraint::Fill(1)]).areas(frame.area());
        let dim = Style::new().fg(DIM);
        let border = Style::new().fg(BORDER);

        // green like the current window in the flora status line
        let title_style = |active: bool| {
            if active {
                Style::new().fg(Color::Green).bold()
            } else {
                dim
            }
        };
        let tabs = Line::from(vec![
            Span::styled(" Sessions ", title_style(!self.showing_windows)),
            Span::styled(" Windows ", title_style(self.showing_windows)),
        ]);
        let count = format!(" {}/{} ", self.items.len(), self.entries().len());
        let prompt_block = Block::bordered()
            .border_style(border)
            .title(tabs)
            .title(Line::styled(count, dim).right_aligned());
        let prompt_inner = prompt_block.inner(prompt_area);
        frame.render_widget(prompt_block, prompt_area);

        let prompt = Line::from(vec!["> ".green(), Span::raw(self.query.as_str())]);
        let cursor_x = prompt_inner.x + prompt.width() as u16;
        frame.render_widget(Paragraph::new(prompt), prompt_inner);
        frame.set_cursor_position((cursor_x, prompt_inner.y));

        let list_block = Block::bordered().border_style(border);
        let list_inner = list_block.inner(list_area);
        frame.render_widget(list_block, list_area);

        if self.items.is_empty() {
            frame.render_widget(Paragraph::new(Span::styled(" No matches", dim)), list_inner);
            return;
        }

        let width = list_inner.width as usize;
        let mut lines = Vec::new();
        let mut selected_line = 0;
        let mut session = None;
        for (i, item) in self.items.iter().enumerate() {
            let entry = &self.entries()[item.entry];
            if let Some(window) = &entry.window
                && session != Some(&window.session)
            {
                session = Some(&window.session);
                lines.push(render_header(entry, window, item, width));
            }
            if i == self.selected {
                selected_line = lines.len();
            }
            lines.push(render_entry(entry, item, i == self.selected, width));
        }

        let height = list_inner.height as usize;
        let total = lines.len();
        let offset = selected_line.saturating_sub(height.saturating_sub(1));
        let visible: Vec<Line> = lines.into_iter().skip(offset).take(height).collect();
        frame.render_widget(Paragraph::new(visible), list_inner);

        if total > height {
            let mut state = ScrollbarState::new(total - height + 1).position(offset);
            let scrollbar = Scrollbar::new(ScrollbarOrientation::VerticalRight)
                .begin_symbol(None)
                .end_symbol(None)
                .track_symbol(None)
                .thumb_symbol("▐")
                .style(dim);
            let area = list_area.inner(Margin {
                vertical: 1,
                horizontal: 0,
            });
            frame.render_stateful_widget(scrollbar, area, &mut state);
        }
    }
}

// Session row above its windows, highlighting where the query matched the
// session part of the first window's haystack
fn render_header(entry: &Entry, window: &Window, item: &Item, width: usize) -> Line<'static> {
    let session_offset = entry.name.chars().count() as u32 + 1;
    let mut spans = vec![Span::raw(" ")];
    spans.extend(highlight(
        &window.session,
        &item.indices,
        session_offset,
        Style::new().bold(),
    ));
    let count = Span::styled(format!("{}w", window.session_windows), Style::new().fg(DIM));
    justify(spans, count, width)
}

fn render_entry(entry: &Entry, item: &Item, selected: bool, width: usize) -> Line<'static> {
    // dim text would vanish on the cursor's bright black, so it takes the row's colour
    let dim = if selected {
        Style::new()
    } else {
        Style::new().fg(DIM)
    };
    let name_style = match (entry.current, selected) {
        (true, false) => dim,
        (_, true) => Style::new().bold(),
        (false, false) => Style::new(),
    };

    let mut spans = match &entry.window {
        Some(window) => vec![
            Span::raw("   "),
            Span::styled(format!("{}: ", window.index), dim),
        ],
        None => vec![Span::raw(" ")],
    };
    spans.extend(highlight(&entry.name, &item.indices, 0, name_style));

    // fff.nvim labels its combo pick "Last Match (×N combo)"
    let detail = if item.combo >= MIN_COMBO_COUNT {
        Span::styled(format!("last match ×{}", item.combo), Style::new().fg(MATCHED))
    } else if entry.current {
        Span::styled(format!("current  {}", entry.detail), dim)
    } else {
        Span::styled(entry.detail.clone(), dim)
    };
    let line = justify(spans, detail, width);
    if selected {
        line.style(Style::new().fg(CURSOR_TEXT).bg(CURSOR))
    } else {
        line
    }
}
