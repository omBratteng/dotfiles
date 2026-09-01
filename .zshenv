#!/usr/bin/env zsh

# Override with local settings
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
export HISTFILE="${HOME}/.zsh_history"

# Where third party plugins get cloned, and where generated completions and the
# compdump are cached. Set here rather than in .zshrc so scripts/*.zsh can see
# them too.
export ZSH_PLUGIN_DIR="${XDG_DATA_HOME}/zsh/plugins"
export ZSH_CACHE_DIR="${XDG_CACHE_HOME}/zsh"

export HOMEBREW_BUNDLE_FILE="${XDG_CONFIG_HOME}/Brewfile"
export FPATH="${XDG_CONFIG_HOME}/completions/zsh:${FPATH}"
export ANSIBLE_HOME="${XDG_CONFIG_HOME}/ansible"
export ANSIBLE_CONFIG="${ANSIBLE_HOME}/ansible.cfg"
export PULUMI_HOME="${XDG_CONFIG_HOME}/pulumi"

[ -f ~/.zshenv.local ] && source ~/.zshenv.local
