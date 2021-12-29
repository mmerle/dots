set fish_greeting
set -gx EDITOR nvim

# enable vi mode
fish_vi_key_bindings

# aliases
alias ls='exa'
alias la='exa -a'
alias lla='exa -la'
alias lt='exa -T --git-ignore'
alias vim='nvim'
alias rm='rm -i'
alias reload='exec $SHELL -l'
alias r='ranger'
alias lg='lazygit'

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

alias ,fish='nvim ~/.config/fish'
alias ,kitty='nvim ~/.config/kitty/kitty.conf'
alias ,nvim='nvim ~/.config/nvim/init.lua'

# abbreviations
abbr v nvim
abbr y yarn
