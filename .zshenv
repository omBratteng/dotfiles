# Override with local settings
export ZSH=$HOME/.oh-my-zsh
export XDG_CONFIG_HOME=$HOME/.config
export HISTFILE=$HOME/.zsh_history
export HOMEBREW_BUNDLE_FILE=$XDG_CONFIG_HOME/Brewfile

[ -f ~/.zshenv.local ] && source ~/.zshenv.local
