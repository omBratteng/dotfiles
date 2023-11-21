#!/usr/bin/env zsh

_uname=$(uname -s)
_yq_latest_version=$(curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')

function command_exists() {
	command -v "$@" >/dev/null 2>&1
}

function install() {
	if command_exists -v yq; then
		false
	else
		if [[ "$_uname" == "Darwin" ]]; then
			if command_exists -v brew; then
				brew install yq
			else
				echo "Homebrew doesn't exist"
				false
			fi
		elif [[ "${_uname:0:5}" == "Linux" ]]; then
			if command_exists -v curl; then
				_tmpdir=$(mktemp -d)
				cd "$_tmpdir" || exit
				curl -LO "https://github.com/mikefarah/yq/releases/download/v4.40.2/yq_linux_amd64"
				sudo install -o root -g root -m 0755 yq_linux_amd64 /usr/local/bin/yq
			else
				echo "curl doesn't exist"
				false
			fi
		fi
		return
	fi
}

function upgrade() {
	if command_exists -v yq; then
		if [[ "$_uname" == "Darwin" ]]; then
			# upgrade is handled by the package manager
			return
		elif [[ "${_uname:0:5}" == "Linux" ]]; then
			# Check if the yq version is the latest, prefix is "version "
			_yq_version=$(yq --version | grep -oP '(?<=version )(.*)')
			if [[ "${_yq_latest_version}" == "$_yq_version" ]]; then
				return
			fi
			if command_exists -v curl; then
				_tmpdir=$(mktemp -d)
				cd "$_tmpdir" || exit
				curl -LO "https://github.com/mikefarah/yq/releases/download/v4.40.2/yq_linux_amd64"
				sudo install -o root -g root -m 0755 yq_linux_amd64 /usr/local/bin/yq
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

unset command_exists install upgrade _uname _yq_latest_version _yq_version
