set -o vi

alias v='nvim'
alias vim='nvim'
alias g='git'
alias lg='lazygit'
alias p='pnpm'
alias ls='ls --color=auto'
alias ll='ls -lav'
alias reload='exec $SHELL -l'

alias ta='tmux attach'
alias tn='tmux new -s'
alias ts='tmux ls'

eval "$(zoxide init bash)"

export PS1="\[\033[01;34m\]\w>\[\033[00m\] "


export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
