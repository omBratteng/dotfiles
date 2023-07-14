#!/usr/bin/env zsh

_uname=$(uname -s)

function command_exists() {
	command -v "$@" >/dev/null 2>&1
}

function install() {
	if command_exists -v bat; then
		false
	else
		if [[ "$_uname" == "Darwin" ]]; then
			if command_exists -v brew; then
				brew install bat
			else
				echo "Homebrew doesn't exist"
				false
			fi
		elif [[ "${_uname:0:5}" == "Linux" ]]; then
			if command_exists -v apt-get; then
				sudo apt-get install bat
			elif command_exists -v dnf; then
				sudo dnf install bat
			else
				echo "Could not find a valid package manager"
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

if [ -n "$1" ]; then
	"$1"
else
	false
fi

unset command_exists install upgrade _uname
