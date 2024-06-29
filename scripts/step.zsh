#!/usr/bin/env zsh

_uname=$(uname -s)

function command_exists() {
	command -v "$@" >/dev/null 2>&1
}

function install() {
	if command_exists -v step; then
		false
	else
		if [[ "${_uname}" == "Darwin" ]]; then
			if command_exists -v brew; then
				brew install step
			else
				echo "Homebrew doesn't exist"
				false
			fi
		elif [[ "${_uname:0:5}" == "Linux" ]]; then
			if command_exists -v curl; then
				_tmpdir=$(mktemp -d)
				_step_latest_version=$(curl -s https://api.github.com/repos/smallstep/cli/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
				_step_latest_version=${_step_latest_version:1}
				_arch="amd64"
				if [[ "$(uname -m)" == "aarch64" ]]; then
					_arch="arm64"
				fi

				# If _FORCE_INSTALL is set, add the -y flag to the package manager
				if [[ -n "${_FORCE_INSTALL}" ]]; then
					_args="-y"
				fi

				cd "$_tmpdir" || exit
				if command_exists -v dpkg; then
					curl -LO "https://dl.smallstep.com/gh-release/cli/docs-ca-install/v${_step_latest_version}/step-cli_${_step_latest_version}_${_arch}.deb"
					sudo dpkg -i $_args "step-cli_${_step_latest_version}_${_arch}.deb"
				elif command_exists -v dnf; then
					curl -LO "https://dl.smallstep.com/gh-release/cli/docs-ca-install/v${_step_latest_version}/step-cli_${_step_latest_version}_${_arch}.rpm"
					sudo dnf install $_args "step-cli_${_step_latest_version}_${_arch}.rpm"
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
	if command_exists -v step; then
		if [[ "${_uname}" == "Darwin" ]]; then
			# upgrade is handled by the package manager
			return
		elif [[ "${_uname:0:5}" == "Linux" ]]; then
			if command_exists -v curl; then
				# Check if the step version is the latest, prefix is "Smallstep CLI/"
				_step_latest_version=$(curl -s https://api.github.com/repos/smallstep/cli/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
				_step_latest_version=${_step_latest_version:1}
				_step_version=$(step version | grep -oP '(?<=Smallstep CLI/)(.*)(?= )')
				if [[ "${_step_latest_version}" == "$_step_version" ]]; then
					return
				else
					_step_version=${_step_latest_version}
				fi

				_tmpdir=$(mktemp -d)
				cd "${_tmpdir}" || exit

				if command_exists -v dpkg; then
					curl -sLO "https://dl.smallstep.com/gh-release/cli/docs-ca-install/v${_step_version}/step-cli_${_step_version}_amd64.deb"
					sudo dpkg -i "step-cli_${_step_version}_amd64.deb"
				elif command_exists -v dnf; then
					curl -sLO "https://dl.smallstep.com/gh-release/cli/docs-ca-install/v${_step_version}/step-cli_${_step_version}_amd64.rpm"
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

unset command_exists install upgrade _uname _step_latest_version _step_version _args
