set -o vi

alias v='nvim'
alias g='git'
alias lg='lazygit'
alias p='pnpm'
alias ls='ls -F --color=auto'
alias la='ls -aF --color=auto'
alias ll='ls -F -lav --color=auto'
alias reload='exec $SHELL -l'
alias ta='tmux attach'
alias tn='tmux new -A -s (basename (pwd) | tr . _)'
alias ts='tmux ls'

export PS1="\[\033[01;34m\]\w>\[\033[00m\] "

eval "$(zoxide init bash)"
