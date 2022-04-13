#!/usr/bin/env zsh

function command_exists() {
	command -v "$@" >/dev/null 2>&1
}

function install() {
	if command_exists -v n; then
		false
	else
		if [[ "$(uname)" == "Darwin" ]]; then
			if command_exists -v brew; then
				brew install n
			else
				echo "Homebrew doesn't exist"
				false
			fi
		fi
	fi
}

function upgrade() {
	if command_exists -v n; then
		# upgrade is handled by the package manager
		return
	else
		install
	fi
}

if [ -n "$1" ]; then
	"$1"
else
	false
fi

unset command_exists install upgrade
