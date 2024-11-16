# Override with local settings
export ZSH=${HOME}/.oh-my-zsh
export XDG_CONFIG_HOME=${HOME}/.config
export HISTFILE=${HOME}/.zsh_history
export HOMEBREW_BUNDLE_FILE=${XDG_CONFIG_HOME}/Brewfile
export FPATH=${XDG_CONFIG_HOME}/completions/zsh:${FPATH}
export ANSIBLE_HOME=${XDG_CONFIG_HOME}/ansible
export ANSIBLE_CONFIG=${ANSIBLE_HOME}/ansible.cfg

[ -f ~/.zshenv.local ] && source ~/.zshenv.local
