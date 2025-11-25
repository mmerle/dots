set -gx XDG_CACHE_HOME $HOME/.cache
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_STATE_HOME $HOME/.local/state

set -gx PNPM_HOME "$XDG_DATA_HOME/pnpm"
set -gx PATH "$PNPM_HOME" $PATH
set -gx CARGO_HOME "$XDG_DATA_HOME/cargo"

set -gx EDITOR nvim
set -gx MANPAGER "nvim -c +Man!"
set -gx FZF_DEFAULT_OPTS "--color=16,border:#3d4249 --layout=reverse --gutter=' '"
set -gx PRETTIERD_LOCAL_PRETTIER_ONLY false
set -gx HOMEBREW_NO_ENV_HINTS 1

# disable analytics of commonly used tools
set -gx HOMEBREW_NO_ANALYTICS 1
set -gx NEXT_TELEMETRY_DISABLED 1

fish_add_path "$HOME/.local/bin"
fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin
fish_add_path $CARGO_HOME/bin

# enable vi mode
fish_vi_key_bindings

if status is-interactive
    # disable fish greeting
    set fish_greeting

    # auto attach to tmux
    if not set -q TMUX; and test "$TERM_PROGRAM" != vscode
        tmux new -A -s (basename (pwd) | tr . _)
    end
end

function fish_title
    echo (string split -- / $PWD)[-1]
end

function fish_prompt
    set -g __fish_git_prompt_showdirtystate 1

    set -l full_path (string replace -r "^$HOME" "~" "$PWD")
    set -l path_parts (string split "/" "$full_path")
    set -l display_path "$full_path"
    set -l path_count (count $path_parts)

    if test $path_count -ge 8
        # Start with the first component (usually ~)
        set display_path $path_parts[1]

        # Shorten intermediate directories, keeping the last 2 full
        for i in (seq 2 (math $path_count - 2))
            set display_path "$display_path/"(string sub -l 1 "$path_parts[$i]")
        end

        # Add the last two components in full
        if test $path_count -ge 2
            set display_path "$display_path/"$path_parts[-2]"/"$path_parts[-1]
        end
    end

    # Git info
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1
        set -l git_branch (git symbolic-ref --short HEAD 2>/dev/null; or git rev-parse --short HEAD 2>/dev/null)
        set -l git_dirty (git status --porcelain 2>/dev/null)

        set -l git_display $git_branch
        if test -n "$git_dirty"
            set git_display "$git_display*"
        end

        printf '%s:%s> ' "$display_path" "$git_display"
    else
        printf '%s> ' "$display_path"
    end
end

function fish_mode_prompt
end

# aliases
alias ls='ls -F --color=auto'
alias la='ls -aF --color=auto'
alias ll='ls -lavF --color=auto'
alias vim='nvim'
alias reload='exec $SHELL -l'
alias connect='kitty +kitten ssh'
alias tmr='transmission-remote'
alias npm='pnpm'
alias npx='pnpm dlx'

# abbreviations
abbr ta 'tmux attach'
abbr tn 'tmux new -A -s (basename (pwd) | tr . _)'
abbr ts 'tmux ls'
abbr g git
abbr v nvim
abbr lg lazygit
abbr p pnpm
abbr mkdir 'mkdir -vp'

# generated
zoxide init fish | source
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
