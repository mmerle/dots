import type { ExtensionUIContext } from '@earendil-works/pi-coding-agent';
import {
  Container,
  Input,
  isKeyRelease,
  isKeyRepeat,
  Key,
  matchesKey,
  SelectList,
  Text,
} from '@earendil-works/pi-tui';

export type AskQuestion = {
  question: string;
  context?: string;
  options?: { title: string; description?: string }[];
  allowMultiple?: boolean;
  allowFreeform?: boolean;
};
type AskAnswer = { question: string; selections: string[]; text?: string; notes?: string };
export type AskResult = { cancelled: boolean; answers: AskAnswer[] };

const SHORTCUTS = [
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  'a',
  'b',
  'c',
  'd',
  'e',
  'f',
] as const;

type PromptRow = {
  label: string;
  description?: string;
  action:
    | { kind: 'choice'; title: string }
    | { kind: 'write' }
    | { kind: 'question'; index: number }
    | { kind: 'submit' };
};

function answerText(answer: AskAnswer): string {
  return [...answer.selections, answer.text].filter(Boolean).join(', ') || '(No options selected)';
}

export function formatAnswers(result: AskResult): string {
  const lines = result.answers.map((answer) =>
    [answer.question, answerText(answer), answer.notes ? `Notes: ${answer.notes}` : undefined]
      .filter(Boolean)
      .join('\n'),
  );
  if (result.cancelled)
    lines.push('Cancelled. These answers were not submitted; do not treat them as approval.');
  return lines.join('\n\n');
}

export async function askQuestions(
  ui: ExtensionUIContext,
  heading: string | undefined,
  questions: AskQuestion[],
  signal?: AbortSignal,
): Promise<AskResult> {
  const answers: AskAnswer[] = questions.map(({ question }) => ({ question, selections: [] }));
  const answered = new Set<number>();
  const result = (cancelled: boolean): AskResult => ({
    cancelled,
    answers: answers.filter((_, index) => answered.has(index)),
  });
  if (signal?.aborted) return result(true);
  let onAbort: (() => void) | undefined;
  try {
    const response = await ui.custom<AskResult>(
      (tui, theme, keys, done) => {
        let page = 0;
        let mode: 'choices' | 'answer' | 'notes' = 'choices';
        let focused = false;
        let parked = false;
        let error = '';
        const positions = questions.map(() => 0).concat(0);
        const input = new Input({
          placeholder: 'Your answer…',
          placeholderStyle: (text) => theme.fg('dim', text),
        });
        let list: SelectList;
        let rows: PromptRow[];
        let visibleRows = 6;

        function refresh() {
          error = '';
          input.focused = focused && mode !== 'choices';
          rebuildList();
        }

        function moveTo(index: number) {
          page = Math.max(0, Math.min(index, questions.length));
          mode = 'choices';
          parked = false;
          refresh();
        }

        function edit(field: 'answer' | 'notes') {
          mode = field;
          if (field === 'answer') positions[page] = (questions[page].options ?? []).length;
          input.setValue((field === 'notes' ? answers[page].notes : answers[page].text) ?? '');
          refresh();
        }

        function choiceLabel(title: string, selected: boolean) {
          const [empty, checked] = questions[page].allowMultiple ? ['[ ]', '[x]'] : ['(○)', '(●)'];
          const marker = theme.fg(selected ? 'accent' : 'muted', selected ? checked : empty);
          return `${marker} ${theme.fg('text', title)}`;
        }

        function buildRows(): PromptRow[] {
          const question = questions[page];
          if (!question)
            return [
              {
                action: { kind: 'submit' },
                label: 'Submit answers',
                description: `${answered.size}/${questions.length} answered`,
              },
              ...answers.map((answer, index): PromptRow => ({
                action: { kind: 'question', index },
                label: `${index + 1}. ${answer.question}`,
                description: answered.has(index)
                  ? [answerText(answer), answer.notes ? `Notes: ${answer.notes}` : undefined]
                      .filter(Boolean)
                      .join(' · ')
                  : 'Not answered',
              })),
            ];

          const choices: PromptRow[] = (question.options ?? []).map((option, index) => ({
            action: { kind: 'choice', title: option.title },
            label: `${SHORTCUTS[index] ?? ' '} ${choiceLabel(option.title, answers[page].selections.includes(option.title))}`,
            description: option.description,
          }));
          if (question.allowFreeform !== false)
            choices.push({
              action: { kind: 'write' },
              label: `z ${choiceLabel('Type your answer', mode === 'answer' || Boolean(answers[page].text))}`,
              description: mode === 'answer' ? undefined : answers[page].text,
            });
          return choices;
        }

        function rebuildList() {
          rows = buildRows();
          list = new SelectList(
            rows.map((row, index) => ({
              value: String(index),
              label: row.label,
              description: index === positions[page] ? undefined : row.description,
            })),
            visibleRows,
            {
              selectedPrefix: (text) => theme.fg('muted', text),
              selectedText: (text) => (parked ? text : theme.bold(text)),
              description: (text) => theme.fg('muted', text),
              scrollInfo: (text) => theme.fg('dim', text),
              noMatch: (text) => theme.fg('warning', text),
            },
          );
          list.setSelectedIndex(positions[page]);
          list.onSelectionChange = (item) => {
            positions[page] = Number(item.value);
            rebuildList();
          };
        }

        function choose(action: 'toggle' | 'confirm') {
          const row = rows[positions[page]];
          if (!row) return;
          switch (row.action.kind) {
            case 'question':
              moveTo(row.action.index);
              return;
            case 'submit':
              if (answered.size === questions.length) done(result(false));
              else {
                moveTo(questions.findIndex((_, index) => !answered.has(index)));
                error = 'Answer this question before submitting.';
              }
              return;
            case 'write':
              edit('answer');
              return;
            case 'choice': {
              const question = questions[page];
              const answer = answers[page];
              const title = row.action.title;
              if (!question.allowMultiple) {
                answer.selections = [title];
                delete answer.text;
              } else if (action === 'toggle') {
                const selected = new Set(answer.selections);
                if (selected.has(title)) selected.delete(title);
                else selected.add(title);
                answer.selections = (question.options ?? [])
                  .filter((option) => selected.has(option.title))
                  .map((option) => option.title);
              }
              answered.add(page);
              if (action === 'toggle') refresh();
              else moveTo(page + 1);
            }
          }
        }

        function saveInput(action: 'advance' | 'back') {
          const value = input.getValue().trim();
          const answer = answers[page];
          if (mode === 'notes') {
            if (value) answer.notes = value;
            else delete answer.notes;
            mode = 'choices';
            refresh();
            return;
          }

          const question = questions[page];
          const canBeEmpty = Boolean(question.allowMultiple && question.options?.length);
          if (action === 'advance' && !value && !answer.selections.length && !canBeEmpty) {
            error = 'Write an answer, or press Esc to go back.';
            return;
          }
          if (value) {
            answer.text = value;
            if (!question.allowMultiple) answer.selections = [];
          } else delete answer.text;
          if (
            value ||
            answer.selections.length ||
            (canBeEmpty && (action === 'advance' || answered.has(page)))
          ) {
            answered.add(page);
          } else answered.delete(page);
          if (action === 'advance') moveTo(page + 1);
          else {
            mode = 'choices';
            refresh();
          }
        }

        function moveFocus(delta: number, wrap = false) {
          const index = positions[page] + delta;
          positions[page] = wrap
            ? (index + rows.length) % rows.length
            : Math.max(0, Math.min(index, rows.length - 1));
          rebuildList();
        }

        function escapeChoices() {
          if (questions[page] && answered.has(page)) {
            answers[page].selections = [];
            delete answers[page].text;
            answered.delete(page);
          } else parked = true;
          refresh();
        }

        rebuildList();
        onAbort = () => done(result(true));
        signal?.addEventListener('abort', onAbort, { once: true });
        if (signal?.aborted) onAbort();

        return {
          get capturesViewportInput() {
            return !parked;
          },
          get focused() {
            return focused;
          },
          set focused(value: boolean) {
            focused = value;
            input.focused = value && mode !== 'choices';
          },
          invalidate() {
            input.invalidate();
            rebuildList();
          },
          render(width) {
            const question = questions[page];
            const container = new Container();
            if (heading) container.addChild(new Text(theme.fg('dim', heading), 1, 0));
            container.addChild(
              new Text(theme.fg('text', question?.question ?? 'Review answers'), 1, 1),
            );
            if (question?.context)
              container.addChild(new Text(theme.fg('muted', question.context), 1, 0));

            const tail = new Container();
            const description = rows[positions[page]]?.description;
            if (description) tail.addChild(new Text(theme.fg('muted', description), 3, 0));
            if (question && answers[page].notes && mode !== 'notes') {
              tail.addChild(new Text(theme.fg('muted', `Notes: ${answers[page].notes}`), 1, 0));
            }
            if (mode !== 'choices') {
              tail.addChild(
                new Text(
                  theme.fg('muted', mode === 'notes' ? 'Notes (optional)' : 'Your answer'),
                  1,
                  0,
                ),
              );
              tail.addChild(input);
            }
            if (error) tail.addChild(new Text(theme.fg('warning', error), 1, 0));

            const progress = question
              ? `[${page + 1}/${questions.length}]`
              : `[${answered.size}/${questions.length} answered]`;
            const confirm = keys
              .getKeys(mode === 'choices' ? 'tui.select.confirm' : 'tui.input.submit')
              .join('/');
            const row = rows[positions[page]];
            const action =
              row?.action.kind === 'write'
                ? 'edit'
                : row?.action.kind === 'submit'
                  ? 'submit'
                  : !question
                    ? 'edit'
                    : question.allowMultiple
                      ? 'next'
                      : 'select';
            const escape = question && answered.has(page) ? 'unselect' : 'scrollback';
            let hint: string;
            if (parked) hint = 'Scrollback · PgUp/PgDn scroll · Tab/Space return · Shift+X dismiss';
            else if (mode !== 'choices') hint = `${confirm} save · Esc keep text · Ctrl+C dismiss`;
            else if (!question)
              hint = `${progress} ← back · ↑/↓/Tab move · ${confirm} ${action} · Esc scrollback · Shift+X dismiss`;
            else {
              const shortcuts =
                question.allowFreeform !== false ? '1–9 choose · z text' : '1–9 choose';
              hint =
                width < 65
                  ? `${progress} ←/→ · ↑/↓/Tab · ${confirm} ${action}\n${shortcuts} · n notes · Esc ${escape} · Shift+X dismiss`
                  : `${progress} ←/→ question · ↑/↓/Tab answers · ${confirm} ${action}\n${shortcuts} · n notes · Esc ${escape} · Shift+X dismiss`;
            }
            tail.addChild(new Text(theme.fg('dim', hint), 1, 1));

            const height = Math.min(
              6,
              Math.max(
                1,
                tui.terminal.rows - container.render(width).length - tail.render(width).length - 4,
              ),
            );
            if (height !== visibleRows) {
              visibleRows = height;
              rebuildList();
            }
            container.addChild(list);
            container.addChild(tail);
            return container.render(width);
          },
          handleInput(data) {
            if (isKeyRelease(data)) return;
            if (
              matchesKey(data, 'ctrl+c') ||
              (mode === 'choices' && matchesKey(data, Key.shift('x')))
            ) {
              done(result(true));
            } else if (mode !== 'choices') {
              if (matchesKey(data, Key.escape)) saveInput('back');
              else if (keys.matches(data, 'tui.input.submit')) saveInput('advance');
              else input.handleInput(data);
            } else if (parked) {
              if (matchesKey(data, Key.tab) || matchesKey(data, Key.space)) {
                parked = false;
                refresh();
              }
            } else if (matchesKey(data, Key.escape)) escapeChoices();
            else if (matchesKey(data, Key.left) || matchesKey(data, 'h')) moveTo(page - 1);
            else if (matchesKey(data, Key.right) || matchesKey(data, 'l')) moveTo(page + 1);
            else if (matchesKey(data, Key.tab)) moveFocus(1, true);
            else if (matchesKey(data, Key.shift('tab'))) moveFocus(-1, true);
            else if (keys.matches(data, 'tui.select.up') || matchesKey(data, 'k')) moveFocus(-1);
            else if (keys.matches(data, 'tui.select.down') || matchesKey(data, 'j')) moveFocus(1);
            else if (matchesKey(data, 'n') && page < questions.length) edit('notes');
            else if (
              matchesKey(data, 'z') &&
              questions[page]?.allowFreeform !== false &&
              page < questions.length
            )
              edit('answer');
            else if (keys.matches(data, 'tui.select.confirm')) choose('confirm');
            else if (matchesKey(data, Key.space)) {
              if (!isKeyRepeat(data)) choose('toggle');
            } else {
              const shortcut = SHORTCUTS.findIndex((key) => matchesKey(data, key));
              if (shortcut >= 0 && !isKeyRepeat(data)) {
                if (page === questions.length) {
                  if (shortcut < questions.length) moveTo(shortcut);
                } else if (shortcut < (questions[page].options?.length ?? 0)) {
                  positions[page] = shortcut;
                  rebuildList();
                  choose(questions[page].allowMultiple ? 'toggle' : 'confirm');
                }
              } else list.handleInput(data);
            }
            tui.requestRender();
          },
        };
      },
      {
        blocked: {
          kind: 'question',
          message: `Waiting on answers for ${questions.length} question${questions.length === 1 ? '' : 's'}`,
        },
      },
    );
    return signal?.aborted ? { ...response, cancelled: true } : response;
  } finally {
    if (onAbort) signal?.removeEventListener('abort', onAbort);
  }
}
