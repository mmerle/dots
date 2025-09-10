set -o vi

alias v='nvim'
alias g='git'
alias lg='lazygit'
alias p='pnpm'
alias ls='ls -F --color=auto'
alias ll='ls -F -lav'
alias reload='exec $SHELL -l'
alias ta='tmux attach'
alias tn='tmux new -s'
alias ts='tmux ls'

export PS1="\[\033[01;34m\]\w>\[\033[00m\] "

eval "$(zoxide init bash)"
