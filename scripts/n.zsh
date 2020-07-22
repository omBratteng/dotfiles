#!/usr/bin/env zsh

function command_exists() {
	command -v "$@" >/dev/null 2>&1
}

function install() {
	if command_exists -v n; then
		false
	else
		_tmpdir=$(mktemp -d)
		git clone --quiet https://github.com/tj/n.git $_tmpdir
		cd $_tmpdir
		sudo make install >/dev/null 2>&1
		cd -
		rm -rf $_tmpdir
		unset _tmpdir
		return
	fi
}

function upgrade() {
	if command_exists -v n; then
		_tmpdir=$(mktemp -d)
		git clone --quiet https://github.com/tj/n.git $_tmpdir
		cd $_tmpdir

		_latest=$(git describe --abbrev=0 | sed -En 's/v(.*)/\1/p')
		_current=$(n --version)

		if [ ! $_latest = $_current ]; then
			sudo make install >/dev/null 2>&1
		fi

		cd -
		rm -rf $_tmpdir
		unset _tmpdir _latest _current
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
