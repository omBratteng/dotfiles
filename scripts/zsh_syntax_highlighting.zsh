#!/usr/bin/env zsh

DIR="${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"

function install() {
	if [ -d $DIR ]; then
		false
	else
		git clone --quiet https://github.com/zsh-users/zsh-syntax-highlighting.git $DIR
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
