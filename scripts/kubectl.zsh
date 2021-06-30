#!/usr/bin/env zsh

function command_exists() {
	command -v "$@" >/dev/null 2>&1
}

function install() {
	if command_exists -v kubectl; then
		false
	else
		if [[ "$(uname)" == "Darwin" ]]; then
			if command_exists -v brew; then
				brew install kubernetes-cli
			else
				echo "Homebrew doesn't exist"
				false
			fi
		elif [[ "$(expr substr $(uname -s) 1 5)" == "Linux" ]]; then
			if command_exists -v apt-get; then
				sudo apt-get install kubectl
			else
				echo "apt-get doesn't exist"
				false
			fi
		fi
		return
	fi
}

function upgrade() {
	if command_exists -v kubectl; then
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
