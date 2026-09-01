#!/usr/bin/env zsh

DIR="${HOME}/.oh-my-zsh"

function install() {
	if [ -d "${DIR}" ]; then
		false
	else
		git clone --quiet https://github.com/robbyrussell/oh-my-zsh.git "${DIR}"
		return
	fi
}

function upgrade() {
	if [ -d "${DIR}" ]; then
		install
	else
		env ZSH="${DIR}" sh "${DIR}/tools/upgrade.sh" >/dev/null 2>&1
		command rm -rf "${DIR}/log/update.lock"
	fi
}


if [ -n "$1" ]; then
	"$1"
else
	false
fi

unset DIR install upgrade
