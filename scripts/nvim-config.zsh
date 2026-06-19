#!/usr/bin/env zsh

DIR="${HOME}/.config/nvim"

function install() {
	if [ -d "${DIR}" ]; then
		false
	else
		git clone --quiet https://github.com/omBratteng/nvim-config.git "${DIR}"
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
