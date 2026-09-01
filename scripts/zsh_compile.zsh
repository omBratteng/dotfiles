#!/usr/bin/env zsh
#
# zcompile everything ~/.zshrc sources so `source` can mmap the .zwc instead
# of re-parsing the text every shell. zshbuiltins: `.`/`source` automatically
# prefer a newer `file.zwc` and silently fall back to the text once it goes
# stale, so this pass is all the maintenance the wordcode cache needs.
#
# Called as `install`/`upgrade` from bootstrap.sh, as `compile` in the
# background from ~/.zshrc, and by hand after editing any target. A mkdir
# lock in $ZSH_CACHE_DIR keeps concurrent shells from racing; a lock left
# behind by a dead shell is broken after an hour.

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
ZSH_CACHE_DIR="${ZSH_CACHE_DIR:-$XDG_CACHE_HOME/zsh}"
ZSH_PLUGIN_DIR="${ZSH_PLUGIN_DIR:-$XDG_DATA_HOME/zsh/plugins}"

targets=(
	"${XDG_CONFIG_HOME}"/zsh.d/S[0-9][0-9]*(.N)
	"${XDG_CONFIG_HOME}"/zsh.d/vendor/lib/*.zsh(.N)
	"${XDG_CONFIG_HOME}"/zsh.d/vendor/plugins/*.zsh(.N)
	"${XDG_CONFIG_HOME}"/lscolors/lscolors.sh(.N)
	"${XDG_CONFIG_HOME}"/p10k.zsh(.N)
	"$HOME"/.zshrc.local(.N)
	"${ZSH_PLUGIN_DIR}"/zsh-autosuggestions/zsh-autosuggestions.zsh(.N)
	"${ZSH_PLUGIN_DIR}"/zsh-you-should-use/you-should-use.plugin.zsh(.N)
	"${ZSH_PLUGIN_DIR}"/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh(.N)
	"${ZSH_PLUGIN_DIR}"/zsh-syntax-highlighting/highlighters/*/*.zsh(.N)
	"${ZSH_CACHE_DIR}"/atuin-init.zsh(.N)
)

run() {
	mkdir -p "${ZSH_CACHE_DIR}"
	lock="${ZSH_CACHE_DIR}/zcompile.lock"
	if ! mkdir "${lock}" 2>/dev/null; then
		# Another shell holds the lock, or a dead one left it behind (an
		# hour old counts as dead). Array-glob staleness check: the
		# `[[ -n x(#q...) ]]` form needs extendedglob to actually apply.
		local -a lock_old
		lock_old=( "${lock}"(N.mh+1) )
		(( $#lock_old )) || return 0
		rmdir "${lock}" 2>/dev/null || return 0
		mkdir "${lock}" 2>/dev/null || return 0
	fi

	local target rc=0
	for target in "${targets[@]}"; do
		[[ "${target}" == *.zwc ]] && continue
		[[ "${target}.zwc" -nt "${target}" ]] && continue
		zcompile "${target}" || rc=1
	done
	rmdir "${lock}" 2>/dev/null
	return "${rc}"
}

function install() { run }
function upgrade() { run }
function compile() { run }

if [ -n "$1" ]; then
	"$1"
else
	false
fi

unset targets lock XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME ZSH_CACHE_DIR ZSH_PLUGIN_DIR install upgrade compile run
