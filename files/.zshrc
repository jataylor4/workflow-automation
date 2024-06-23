# Transient font - add to top
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set ZINIT_HOME for plugins etc
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download ZINIT if not already there
if [ ! -d "$ZINIT_HOME" ]; then
	mkdir -p "$(dirname $ZINIT_HOME)"
	git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k - ice is add to next command, light is load
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Syntax highlighting
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::aws
zinit snippet OMZP::command-not-found
zinit snippet OMZP::cp
zinit snippet OMZP::rsync
zinit snippet OMZP::ubuntu
zinit snippet OMZP::vscode

# Load completions
autoload -U compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Enable Vim keybindings
bindkey -v

# Custom keybindings
bindkey '^P' up-line-or-history      # Ctrl+P to navigate up in history
bindkey '^N' down-line-or-history    # Ctrl+N to navigate down in history

# Ensure history navigation works in Normal mode
function zle-keymap-select {
    if [[ ${KEYMAP} == vicmd ]] ||
       [[ $1 = 'block' ]]; then
        bindkey '^P' up-line-or-history
        bindkey '^N' down-line-or-history
    else
        bindkey '^P' vi-up-line-or-history
        bindkey '^N' vi-down-line-or-history
    fi
}
zle -N zle-keymap-select

# History
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='ls --color'

# Path
export PATH=$PATH:~/.local/lib/python3.10/site-packages/../../../bin
export PATH=$PATH:/opt/rocm/llvm/bin
export PATH=$PATH:~/Dev/scripts/install/nvim/nvim-linux64/bin

# Exports
export CPLUS_INCLUDE_PATH=/usr/include/c++/11:/usr/include/x86_64-linux-gnu/c++/11:/opt/rocm/llvm/include:/opt/rocm/include/hip
export PYTHONPATH=~/.local/lib/python3.10/site-packages:$PYTHONPATH

# Ensure fzf is installed and configured
if [[ ! -d ~/.fzf ]]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --all --no-bash --no-fish
fi

# Load fzf key bindings and completion
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Silence Powerlevel10k instant prompt warning
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

if [ -f ~/docker_functions.sh ]; then
  source ~/docker_functions.sh
fi

source /usr/share/doc/fzf/examples/key-bindings.zsh
source /usr/share/doc/fzf/examples/completion.zsh