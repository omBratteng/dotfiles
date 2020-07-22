#!/usr/bin/env zsh

DIR="${HOME}/.oh-my-zsh"

function install() {
	if [ -d $DIR ]; then
		false
	else
		git clone --quiet https://github.com/robbyrussell/oh-my-zsh.git $DIR
		return
	fi
}

function upgrade() {
	if [ -d $DIR ]; then
		install
	else
		env ZSH="$ZSH" sh "$ZSH/tools/upgrade.sh" >/dev/null 2>&1
		command rm -rf "$ZSH/log/update.lock"
	fi
}


if [ ! -z "$1" ]; then
	"$1"
else
	false
fi

unset DIR install upgrade
