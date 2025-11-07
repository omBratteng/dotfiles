#!/usr/bin/env zsh

_uname=$(uname -s)

function command_exists() {
	command -v "$@" >/dev/null 2>&1
}

function install() {
	if command_exists -v atuin; then
		false
	else
		if [[ "${_uname}" == "Darwin" ]]; then
			if command_exists -v brew; then
				brew install atuin
			else
				echo "Homebrew doesn't exist"
				false
			fi
		elif [[ "${_uname:0:5}" == "Linux" ]]; then
			if command_exists -v curl; then
				_tmpdir=$(mktemp -d)
				_atuin_latest_version=$(curl -s https://api.github.com/repos/atuinsh/atuin/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
				cd "${_tmpdir}" || exit
				curl -sL "https://github.com/atuinsh/atuin/releases/download/${_atuin_latest_version}/atuin-x86_64-unknown-linux-gnu.tar.gz" | tar -xz
				sudo install -o root -g root -m 0755 atuin-x86_64-unknown-linux-gnu/atuin /usr/local/bin/atuin
			else
				echo "curl doesn't exist"
				false
			fi
		fi
		return
	fi
}

function upgrade() {
	if command_exists -v atuin; then
		if [[ "${_uname}" == "Darwin" ]]; then
			# upgrade is handled by the package manager
			return
		elif [[ "${_uname:0:5}" == "Linux" ]]; then
			if command_exists -v curl; then
				# Check if the atuin version is the latest, prefix is "version "
				_atuin_latest_version=$(curl -s https://api.github.com/repos/atuinsh/atuin/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
				_atuin_version=$(atuin --version | sed -n '1p' | awk '{print $2}')

				# Remove the "v" prefix from the latest version
				_atuin_latest_version_no_prefix="${_atuin_latest_version#v}"

				if [[ "${_atuin_latest_version_no_prefix}" == "${_atuin_version}" ]]; then
					return
				fi

				_tmpdir=$(mktemp -d)
				cd "$_tmpdir" || exit

				curl -sL "https://github.com/atuinsh/atuin/releases/download/${_atuin_latest_version}/atuin-x86_64-unknown-linux-gnu.tar.gz" | tar -xz
				sudo install -o root -g root -m 0755 atuin-x86_64-unknown-linux-gnu/atuin /usr/local/bin/atuin
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

unset command_exists install upgrade _uname
