set -gx XDG_CACHE_HOME $HOME/.cache
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_DATA_HOME $HOME/.local/share

set -gx EDITOR nvim

fish_add_path /opt/homebrew/bin
fish_add_path $HOME/.cargo/bin

# enable vi mode
fish_vi_key_bindings

set fish_greeting

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
alias ls='exa'
alias la='exa -a'
alias lla='exa -la'
alias lt='exa -T --git-ignore'
alias vim='nvim'
alias rm='rm -i'
alias reload='exec $SHELL -l'
alias code='code-insiders'

alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gca='git commit -am'
alias go='git checkout'
alias gu='git push'
alias gp='git pull'
alias gb='git branch'
alias gm='git merge'
alias gl='git log -n 10 --graph --decorate --oneline --no-merges'

alias ,fish='$EDITOR ~/.config/fish'
alias ,kitty='$EDITOR ~/.config/kitty/kitty.conf'
alias ,nvim='$EDITOR ~/.config/nvim/init.lua'

# abbreviations
abbr -a v nvim
abbr -a r ranger
abbr -a lg lazygit
abbr -a y yarn
abbr -a p pnpm
