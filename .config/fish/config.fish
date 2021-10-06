set fish_greeting

# enable vi mode
fish_vi_key_bindings

# aliases
alias ls='exa'
alias la='exa -a'
alias vim='nvim'
alias rm='rm -i'
alias reload='exec $SHELL -l'

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

alias ,fish='code ~/.config/fish'
alias ,kitty='code ~/.config/kitty/kitty.conf'

# abbreviations
abbr v 'nvim'
abbr y 'yarn'