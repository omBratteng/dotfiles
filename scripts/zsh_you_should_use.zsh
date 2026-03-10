#!/usr/bin/env zsh

DIR="${HOME}/.oh-my-zsh/custom/plugins/zsh-you-should-use"

function install() {
	if [ -d "${DIR}" ]; then
		false
	else
		git clone --quiet https://github.com/MichaelAquilina/zsh-you-should-use.git "${DIR}"
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
