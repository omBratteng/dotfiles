#!/usr/bin/env zsh
#
# Vendored from oh-my-zsh @ ff1df9a0399d56b9f6e957bb62a2d4ba6bc0ef4c
# Upstream: plugins/gitignore/gitignore.plugin.zsh
# Local changes: none
#
# DO NOT EDIT BY HAND -- see .config/zsh.d/vendor/VENDOR.md

# gitignore plugin for oh-my-zsh
# Uses gitignore.io CDN endpoint
function _gi_curl() {
  curl -sfL "https://www.gitignore.io/api/$1"
}

function gi() {
  local query="${(j:,:)@}"
  _gi_curl "$query" || return 1
}

_gitignoreio_get_command_list() {
  _gi_curl "list" | tr "," "\n"
}

_gitignoreio () {
  compset -P '*,'
  compadd -S '' $(_gitignoreio_get_command_list)
}

compdef _gitignoreio gi