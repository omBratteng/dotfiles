#!/usr/bin/env zsh

_lscolors_data_dir=$HOME/.config/lscolors

function install() {
	if [ -f $_lscolors_data_dir/lscolors.sh ]; then
		false
	else
		_tmpdir=$(mktemp -d)
		git clone --quiet https://github.com/trapd00r/LS_COLORS.git $_tmpdir
		cd $_tmpdir
		mkdir -p $HOME/.config/lscolors
		if dircolors -b LS_COLORS > lscolors.sh && dircolors -c LS_COLORS > lscolors.csh ; then
			if mv -t "${_lscolors_data_dir}" lscolors.sh lscolors.csh ; then
				cat <<EOF
To enable the colors, add the following line to your shell's start-up script:
For Bourne shell (e.g. ~/.bashrc or ~/.zshrc):
  . "${_lscolors_data_dir}/lscolors.sh"
For C shell (e.g. ~/.cshrc):
  . "${_lscolors_data_dir}/lscolors.csh"
EOF
			fi
		fi
		cd - || exit
		rm -rf $_tmpdir
		unset _tmpdir
		return
	fi
}

function upgrade() {
	if [ -f $_lscolors_data_dir/lscolors.sh ]; then
		_tmpdir=$(mktemp -d)
		git clone --quiet https://github.com/trapd00r/LS_COLORS.git $_tmpdir
		cd $_tmpdir
		if dircolors -b LS_COLORS > lscolors.sh && dircolors -c LS_COLORS > lscolors.csh ; then
			if mv -t "${_lscolors_data_dir}" lscolors.sh lscolors.csh ; then
			fi
		fi
		cd - || exit
		rm -rf $_tmpdir
		unset _tmpdir
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

unset _lscolors_data_dir install upgrade
