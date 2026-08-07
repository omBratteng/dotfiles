#!/usr/bin/env zsh

_uname=$(uname -s)
_repo="can1357/oh-my-pi"
_bindir="${HOME}/.local/bin"

function command_exists() {
	command -v "$@" >/dev/null 2>&1
}

function _get_os() {
	if [[ "${_uname}" == "Darwin" ]]; then
		echo "darwin"
	elif [[ "${_uname:0:5}" == "Linux" ]]; then
		echo "linux"
	else
		echo ""
	fi
}

function _get_arch() {
	_m=$(uname -m)
	if [[ "${_m}" == "arm64" || "${_m}" == "aarch64" ]]; then
		echo "arm64"
	else
		echo "x64"
	fi
}

function _get_latest_version() {
	curl -s "https://api.github.com/repos/${_repo}/releases/latest" \
		| grep -oE '"tag_name":[[:space:]]*"[^"]+"' \
		| grep -oE 'v[0-9]+(\.[0-9]+)+'
}

function _get_installed_version() {
	omp --version 2>/dev/null \
		| grep -oE '[0-9]+(\.[0-9]+)+' \
		| head -n1
}

function _download_and_install() {
	_tag="$1"
	_os=$(_get_os)
	_arch=$(_get_arch)

	if [[ -z "${_os}" ]]; then
		echo "Unsupported OS: ${_uname}"
		false
		return
	fi

	_asset="omp-${_os}-${_arch}"
	_url="https://github.com/${_repo}/releases/download/${_tag}/${_asset}"

	mkdir -p "${_bindir}"

	_tmpdir=$(mktemp -d)
	cd "${_tmpdir}" || exit
	if curl -fLo omp "${_url}"; then
		# `command` is required: this script defines an install() function,
		# which would otherwise shadow /usr/bin/install and recurse.
		command install -m 0755 omp "${_bindir}/omp"
	else
		echo "Failed to download ${_url}"
		false
	fi
}

function install() {
	if ! command_exists curl; then
		echo "curl doesn't exist"
		false
		return
	fi

	if command_exists omp; then
		false
		return
	fi

	_latest_version=$(_get_latest_version)
	if [[ -z "${_latest_version}" ]]; then
		echo "Could not determine latest version"
		false
		return
	fi

	_download_and_install "${_latest_version}"
}

function upgrade() {
	if ! command_exists curl; then
		echo "curl doesn't exist"
		false
		return
	fi

	if ! command_exists omp; then
		install
		return
	fi

	_latest_version=$(_get_latest_version)
	if [[ -z "${_latest_version}" ]]; then
		echo "Could not determine latest version"
		false
		return
	fi

	_installed_version=$(_get_installed_version)
	if [[ -n "${_installed_version}" && "${_latest_version#v}" == "${_installed_version}" ]]; then
		return
	fi

	_download_and_install "${_latest_version}"
}

if [ -n "$1" ]; then
	"$1"
else
	false
fi

_status=$?

unset command_exists install upgrade _get_os _get_arch _get_latest_version _get_installed_version _download_and_install
unset _uname _repo _bindir _installed_version _latest_version _tmpdir _asset _url _tag _os _arch _m

exit ${_status}
