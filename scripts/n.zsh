#!/usr/bin/env zsh

_uname=$(uname -s)

function command_exists() {
	command -v "$@" >/dev/null 2>&1
}

function install() {
	if command_exists -v n; then
		false
	else
		if [[ "${_uname}" == "Darwin" ]]; then
			if command_exists -v brew; then
				brew install n
				if [[ ! -v DOTFILES ]]; then
					echo 'export N_PREFIX="$HOME/.config/n"' >> ~/.zshenv.local
					echo 'export PATH="$HOME/.config/n/bin:$PATH"' >> ~/.zshenv.local
				fi
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

unset command_exists install upgrade _uname
