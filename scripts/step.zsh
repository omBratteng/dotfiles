#!/usr/bin/env zsh

_uname=$(uname -s)
_step_version="0.25.0"

function command_exists() {
	command -v "$@" >/dev/null 2>&1
}

function install() {
	if command_exists -v yq; then
		false
	else
		if [[ "$_uname" == "Darwin" ]]; then
			if command_exists -v brew; then
				brew install step
			else
				echo "Homebrew doesn't exist"
				false
			fi
		elif [[ "${_uname:0:5}" == "Linux" ]]; then
			if command_exists -v curl; then
				_tmpdir=$(mktemp -d)
				cd "$_tmpdir" || exit
				if command_exists -v dpkg; then
					curl -LO "https://dl.smallstep.com/gh-release/cli/docs-ca-install/v${_step_version}/step-cli_${_step_version}_amd64.deb"
					sudo dpkg -i "step-cli_${_step_version}_amd64.deb"
				elif command_exists -v dnf; then
					curl -LO "https://dl.smallstep.com/gh-release/cli/docs-ca-install/v${_step_version}/step-cli_${_step_version}_amd64.rpm"
					sudo dnf install "step-cli_${_step_version}_amd64.rpm"
				else
					echo "Could not find a valid package manager"
					false
				fi
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
			if command_exists -v curl; then
				_tmpdir=$(mktemp -d)
				cd "$_tmpdir" || exit
				if command_exists -v dpkg; then
					curl -LO "https://dl.smallstep.com/gh-release/cli/docs-ca-install/v${_step_version}/step-cli_${_step_version}_amd64.deb"
					sudo dpkg -i "step-cli_${_step_version}_amd64.deb"
				elif command_exists -v dnf; then
					curl -LO "https://dl.smallstep.com/gh-release/cli/docs-ca-install/v${_step_version}/step-cli_${_step_version}_amd64.rpm"
					sudo dnf install "step-cli_${_step_version}_amd64.rpm"
				else
					echo "Could not find a valid package manager"
					false
				fi
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

unset command_exists install upgrade _uname _step_version
