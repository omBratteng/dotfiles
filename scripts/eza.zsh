#!/usr/bin/env zsh

_uname=$(uname -s)

function command_exists() {
	command -v "$@" >/dev/null 2>&1
}

function install() {
	if command_exists -v eza; then
		false
	else
		if [[ "${_uname}" == "Darwin" ]]; then
			if command_exists -v brew; then
				brew install eza
			else
				echo "Homebrew doesn't exist"
				false
			fi
		elif [[ "${_uname:0:5}" == "Linux" ]]; then
			if command_exists -v curl; then
				_tmpdir=$(mktemp -d)
				_eza_latest_version=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
				cd "${_tmpdir}" || exit
				curl -sL "https://github.com/eza-community/eza/releases/download/${_eza_latest_version}/eza_x86_64-unknown-linux-gnu.tar.gz" | tar -xz
				sudo install -o root -g root -m 0755 eza /usr/local/bin/eza
			else
				echo "curl doesn't exist"
				false
			fi
		fi
		return
	fi
}

function upgrade() {
	if command_exists -v eza; then
		if [[ "${_uname}" == "Darwin" ]]; then
			# upgrade is handled by the package manager
			return
		elif [[ "${_uname:0:5}" == "Linux" ]]; then
			if command_exists -v curl; then
				# Check if the eza version is the latest, prefix is "version "
				_eza_latest_version=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
				_eza_version=$(eza --version | sed -n '2p' | awk '{print $1}')

				if [[ "${_eza_latest_version}" == "${_eza_version}" ]]; then
					return
				fi

				_tmpdir=$(mktemp -d)
				cd "$_tmpdir" || exit

				curl -sL "https://github.com/eza-community/eza/releases/download/${_eza_latest_version}/eza_x86_64-unknown-linux-gnu.tar.gz" | tar -xz
				sudo install -o root -g root -m 0755 eza /usr/local/bin/eza
			else
				echo "curl doesn't exist"
				false
			fi
		fi
	else
		install
	fi
}

if [ -n "$1" ]; then
	"$1"
else
	false
fi

unset command_exists install upgrade _uname _eza_latest_version _eza_version
