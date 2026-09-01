#!/usr/bin/env zsh
#
# Vendored from oh-my-zsh @ ff1df9a0399d56b9f6e957bb62a2d4ba6bc0ef4c
# Upstream: plugins/direnv/direnv.plugin.zsh
# Local changes: none
#
# DO NOT EDIT BY HAND -- see .config/zsh.d/vendor/VENDOR.md

# If direnv is not found, don't continue and print a warning
if (( ! $+commands[direnv] )); then
  echo "Warning: direnv not found. Please install direnv and ensure it's in your PATH before using this plugin."
  return
fi

_direnv_hook() {
  trap -- '' SIGINT;
  eval "$(direnv export zsh)";
  trap - SIGINT;
}
typeset -ag precmd_functions;
if [[ -z "${precmd_functions[(r)_direnv_hook]+1}" ]]; then
  precmd_functions=( _direnv_hook ${precmd_functions[@]} )
fi
typeset -ag chpwd_functions;
if [[ -z "${chpwd_functions[(r)_direnv_hook]+1}" ]]; then
  chpwd_functions=( _direnv_hook ${chpwd_functions[@]} )
fi
