#!/usr/bin/env zsh

function command_exists() {
	command -v "$@" >/dev/null 2>&1
}

function install() {
	if command_exists -v bat; then
		false
	else
		if [[ "$(uname)" == "Darwin" ]]; then
			if command_exists -v brew; then
				brew install bat
			else
				echo "Homebrew doesn't exist"
				false
			fi
		elif [[ "$(expr substr $(uname -s) 1 5)" == "Linux" ]]; then
			if command_exists -v apt-get; then
				sudo apt-get install bat
			else
				echo "Homebrew doesn't exist"
				false
			fi
		fi
		return
	fi
}

function upgrade() {
	if command_exists -v bat; then
		# upgrade is handled by the package manager
		return
	else
		install
	fi
}

if [ ! -z "$1" ]; then
	"$1"
else
	false
fi

unset command_exists install upgrade