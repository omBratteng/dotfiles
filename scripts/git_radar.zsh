#!/usr/bin/env zsh

DIR="${HOME}/.git-radar"

function install() {
	if [ -d $DIR ]; then
		false
	else
		git clone --quiet https://github.com/michaeldfallen/git-radar $DIR
		return
	fi
}

function upgrade() {
	if [ ! -d $DIR ]; then
		install
	else
		cd $DIR
		git pull --ff-only --quiet
		cd -
		return
	fi
}

if [ ! -z "$1" ]; then
	"$1"
else
	false
fi

unset DIR install upgrade
