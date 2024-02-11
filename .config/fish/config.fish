set -gx XDG_CACHE_HOME $HOME/.cache
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_STATE_HOME $HOME/.local/state

set -gx PNPM_HOME "$XDG_DATA_HOME/pnpm"
set -gx PATH "$PNPM_HOME" $PATH
set -gx CARGO_HOME "$XDG_DATA_HOME/cargo"

set -gx EDITOR nvim

# disable analytics of commonly used tools
set HOMEBREW_NO_ANALYTICS 1
set NEXT_TELEMETRY_DISABLED 1

# pfetch
set PF_INFO "title os host uptime pkgs shell editor wm de"

fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin
fish_add_path $HOME/.cargo/bin

# enable vi mode
fish_vi_key_bindings

# disable fish greeting
set fish_greeting

function fish_title
    echo (string split -- / $PWD)[-1]
end

function fish_prompt
    set -g fish_prompt_pwd_dir_length 0
    printf '%s%s> ' (prompt_pwd)
end

function fish_right_prompt
    set -g __fish_git_prompt_showupstream verbose
    set -g __fish_git_prompt_char_upstream_ahead ' ↑'
    set -g __fish_git_prompt_char_upstream_behind ' ↓'
    set -g __fish_git_prompt_char_upstream_diverged ' ↕'
    set -g __fish_git_prompt_char_upstream_equal
    set -g __fish_git_prompt_char_upstream_prefix
    printf '%s %s' (set_color yellow; fish_git_prompt;)
end

function fish_mode_prompt
end

# aliases
alias ls='eza --group-directories-first'
alias la='eza --group-directories-first -a'
alias ll='eza --group-directories-first -la'
alias lt='eza --git-ignore -Ta'
alias vim='nvim'
alias rm='trash'
alias reload='exec $SHELL -l'
alias code='code-insiders'
alias connect='kitty +kitten ssh'
alias tmr='transmission-remote'

alias ,fish='$EDITOR ~/.config/fish/config.fish'
alias ,kitty='$EDITOR ~/.config/kitty/kitty.conf'
alias ,nvim='$EDITOR ~/.config/nvim/init.lua'

# abbreviations
abbr ta 'tmux attach'
abbr tn 'tmux new -s (basename (pwd))'
abbr ts 'tmux ls'

abbr g git
abbr v nvim
abbr lg lazygit
abbr p pnpm
abbr mkdir 'mkdir -vp'

zoxide init fish | source

# pnpm
set -gx PNPM_HOME "/Users/mm/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
