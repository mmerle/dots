set -gx XDG_CACHE_HOME $HOME/.cache
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_STATE_HOME $HOME/.local/state

set -gx PNPM_HOME "$XDG_DATA_HOME/pnpm"
set -gx PATH "$PNPM_HOME" $PATH
set -gx CARGO_HOME "$XDG_DATA_HOME/cargo"
set -gx GOPATH $XDG_DATA_HOME/go

set -gx EDITOR nvim
set -gx FZF_DEFAULT_OPTS "--color=16"
set -gx PRETTIERD_LOCAL_PRETTIER_ONLY false
set -gx HOMEBREW_NO_ENV_HINTS 1

# disable analytics of commonly used tools
set -gx HOMEBREW_NO_ANALYTICS 1
set -gx NEXT_TELEMETRY_DISABLED 1

fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin
fish_add_path $CARGO_HOME/bin
fish_add_path $GOPATH/bin

# enable vi mode
fish_vi_key_bindings

# disable fish greeting
set fish_greeting

function fish_title
    echo (string split -- / $PWD)[-1]
end

function fish_prompt
    # set -g fish_prompt_pwd_dir_length 0
    # printf '%s%s> ' (prompt_pwd)
    set -gx __fish_git_prompt_showdirtystate 1
    set -g __fish_git_prompt_showupstream verbose
    set -g __fish_git_prompt_char_upstream_ahead ' ↑'
    set -g __fish_git_prompt_char_upstream_behind ' ↓'
    set -g __fish_git_prompt_char_upstream_diverged ' ↕'
    set -g __fish_git_prompt_char_upstream_equal
    set -g __fish_git_prompt_char_upstream_prefix
    printf '%s%s> ' (fish_prompt_pwd_dir_length=0 prompt_pwd)(set_color brblack; fish_git_prompt; set_color normal)
end

function fish_mode_prompt
end

# aliases
alias ls='eza --group-directories-first'
alias la='eza --group-directories-first -a'
alias ll='eza --group-directories-first -la'
alias lt='eza --git-ignore -Ta'
alias vim='nvim'
alias reload='exec $SHELL -l'
alias code='code-insiders'
alias connect='kitty +kitten ssh'
alias tmr='transmission-remote'
alias npm='pnpm'
alias npx='pnpm dlx'

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
