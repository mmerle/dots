export ZSH="/Users/merle/.oh-my-zsh"

ZSH_THEME="geometry/geometry"

GEOMETRY_SYMBOL_PROMPT="✻"                  # default prompt symbol
GEOMETRY_SYMBOL_RPROMPT="✻"                 # multiline prompts
GEOMETRY_SYMBOL_EXIT_VALUE="✻"              # displayed when exit value is != 0
GEOMETRY_SYMBOL_ROOT="✻"                    # when logged in user is root

# Colors
GEOMETRY_COLOR_EXIT_VALUE="magenta"         # prompt symbol color when exit value is != 0
GEOMETRY_COLOR_PROMPT="white"               # prompt symbol color
GEOMETRY_COLOR_ROOT="red"                   # root prompt symbol color
GEOMETRY_COLOR_DIR="blue"                   # current directory color


PROMPT_GEOMETRY_RPROMPT_ASYNC="false"

unsetopt PROMPT_SP

DISABLE_AUTO_TITLE="true"

plugins=(git)
plugins=(tmux)
plugins=(npm)
plugins=(yarn)
plugins=(colored-man-pages)

source $ZSH/oh-my-zsh.sh

# Key binds
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

# Aliases
alias tsm="transmission-remote"
alias la="ls -A"
alias vim="nvim"
alias rm="rm -i"
alias g="git"
alias gs="git status"
alias yt-dl="youtube-dl -f 140"

# Other
code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}

# Scripts
function colortest(){
  T='gYw'   # The test text

  echo -e "\n                 40m     41m     42m     43m\
      44m     45m     46m     47m";

  for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' \
            '1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' \
            '  36m' '1;36m' '  37m' '1;37m';
    do FG=${FGs// /}
    echo -en " $FGs \033[$FG  $T  "
    for BG in 40m 41m 42m 43m 44m 45m 46m 47m;
      do echo -en "$EINS \033[$FG\033[$BG  $T  \033[0m";
    done
    echo;
  done
  echo
}