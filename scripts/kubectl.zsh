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
			if command_exists -v curl; then
				_tmpdir=$(mktemp -d)
				cd "$_tmpdir"
				curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
				sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
			else
				echo "curl doesn't exist"
				false
			fi
		fi
		return
	fi
}

function upgrade() {
	if command_exists -v kubectl; then
		if [[ "$(uname)" == "Darwin" ]]; then
			# upgrade is handled by the package manager
			return
		elif [[ "$(expr substr $(uname -s) 1 5)" == "Linux" ]]; then
			if command_exists -v curl; then
				_tmpdir=$(mktemp -d)
				cd "$_tmpdir"
				curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
				sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
			else
				echo "curl doesn't exist"
				false
			fi
		fi
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
