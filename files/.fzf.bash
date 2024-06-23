# Setup fzf
# ---------
if [[ ! "$PATH" == */home/adamska/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/adamska/.fzf/bin"
fi

eval "$(fzf --bash)"
