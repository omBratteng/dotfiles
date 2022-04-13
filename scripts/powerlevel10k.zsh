#!/usr/bin/env zsh

DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

function install() {
	if [ -d "$DIR" ]; then
		false
	else
		git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k
		return
	fi
}

function upgrade() {
	if [ ! -d "$DIR" ]; then
		install
	else
		cd "$DIR" || exit
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
