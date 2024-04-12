# Autocompletion for pipx.
if (( ! $+commands[pipx] )); then
  return
fi

# If the completion file doesn't exist yet, we need to autoload it and
# bind it to `pipx`. Otherwise, compinit will have already done that.
if [[ ! -f "${ZSH_CACHE_DIR}/completions/_pipx" ]]; then
  typeset -g -A _comps
  autoload -Uz _pipx
  _comps[pipx]=_pipx
fi

register-python-argcomplete pipx >| "${ZSH_CACHE_DIR}/completions/_pipx" &|
