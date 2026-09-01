#!/usr/bin/env zsh
#
# Vendored from oh-my-zsh @ ff1df9a0399d56b9f6e957bb62a2d4ba6bc0ef4c
# Upstream: plugins/docker/docker.plugin.zsh
# Local changes:
#   - the background completion generator now only runs when the cached
#     _docker is missing or older than 24h; upstream respawned
#     `docker --version` (~200ms) and `docker completion zsh` on every shell
#
# DO NOT EDIT BY HAND -- see .config/zsh.d/vendor/VENDOR.md

alias dbl='docker build'
alias dcin='docker container inspect'
alias dcls='docker container ls'
alias dclsa='docker container ls -a'
alias dcprune='docker container prune'
alias dib='docker image build'
alias dii='docker image inspect'
alias dils='docker image ls'
alias dipu='docker image push'
alias dipru='docker image prune -a'
alias dirm='docker image rm'
alias dit='docker image tag'
alias dlo='docker container logs'
alias dnc='docker network create'
alias dncn='docker network connect'
alias dndcn='docker network disconnect'
alias dni='docker network inspect'
alias dnls='docker network ls'
alias dnprune='docker network prune'
alias dnrm='docker network rm'
alias dpo='docker container port'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dpu='docker pull'
alias dr='docker container run'
alias drit='docker container run -it'
alias drm='docker container rm'
alias 'drm!'='docker container rm -f'
alias dsprune='docker system prune'
alias dst='docker container start'
alias drs='docker container restart'
alias dsta='docker stop $(docker ps -q)'
alias dstp='docker container stop'
alias dsts='docker stats'
alias dtop='docker top'
alias dvi='docker volume inspect'
alias dvls='docker volume ls'
alias dvprune='docker volume prune'
alias dxc='docker container exec'
alias dxcit='docker container exec -it'

if (( ! $+commands[docker] )); then
  return
fi

# Standardized $0 handling
# https://zdharma-continuum.github.io/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# If the completion file doesn't exist yet, we need to autoload it and
# bind it to `docker`. Otherwise, compinit will have already done that.
if [[ ! -f "$ZSH_CACHE_DIR/completions/_docker" ]]; then
  typeset -g -A _comps
  autoload -Uz _docker
  _comps[docker]=_docker
fi

# Regenerate the cached completion at most once a day, in the background,
# mirroring the day gate in S28_compinit. The staleness check uses an array
# glob because the `[[ -n x(#q...) ]]` form needs extendedglob to work.
_docker_stale=( "${ZSH_CACHE_DIR}/completions/_docker"(N.mh+24) )
if [[ ! -f "$ZSH_CACHE_DIR/completions/_docker" ]] || (( $#_docker_stale )); then
  {
    # `docker completion` is only available from 23.0.0 on
    # docker version returns `Docker version 24.0.2, build cb74dfcd85`
    # with `s:,:` remove the comma after the version, and select third word of it
    if zstyle -t ':omz:plugins:docker' legacy-completion || \
      ! is-at-least 23.0.0 ${${(s:,:z)"$(command docker --version)"}[3]}; then
          command cp "${0:h}/completions/_docker" "$ZSH_CACHE_DIR/completions/_docker"
        else
          command docker completion zsh | tee "$ZSH_CACHE_DIR/completions/_docker" > /dev/null
    fi
  } &|
fi

unset _docker_stale
