# ~/.zshrc — Aurora default skeleton, no framework

## History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt APPEND_HISTORY

## Completion
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # case-insensitive matching

## Basic options
setopt AUTO_CD              # type a dir name to cd into it
setopt CORRECT              # command spelling correction
setopt INTERACTIVE_COMMENTS # allow # comments in interactive shell
bindkey -e                  # emacs-style keybindings (drop this line for vi mode)

## Plugins (installed as RPM packages, not git-cloned)
# zsh-autosuggestions
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# zsh-syntax-highlighting — must be sourced LAST
if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

## Aliases
alias ls='ls --color=auto'
alias ll='ls -lah'
alias grep='grep --color=auto'
alias update='rpm-ostree upgrade'
alias status='rpm-ostree status'

## Prompt
eval "$(starship init zsh)"
