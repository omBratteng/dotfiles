#!/usr/bin/env zsh

DIR="${ZSH_PLUGIN_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins}/powerlevel10k"

function install() {
	if [ -d "${DIR}" ]; then
		false
	else
		git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${DIR}"
		return
	fi
}

function upgrade() {
	if [ ! -d "${DIR}" ]; then
		install
	else
		cd "${DIR}" || exit
		git pull --ff-only --quiet
		cd - || exit
		return
	fi
}


if [ -n "$1" ]; then
	"$1"
else
	false
fi

unset DIR install upgrade
