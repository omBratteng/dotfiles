#!/usr/bin/env zsh

_uname=$(uname -s)
_extension_id="jetbrains.kotlin"
_repo="Kotlin/kotlin-lsp"

function command_exists() {
	command -v "$@" >/dev/null 2>&1
}

function _get_os() {
	if [[ "${_uname}" == "Darwin" ]]; then
		echo "mac"
	elif [[ "${_uname:0:5}" == "Linux" ]]; then
		echo "linux"
	else
		echo ""
	fi
}

function _get_arch() {
	_m=$(uname -m)
	if [[ "${_m}" == "arm64" || "${_m}" == "aarch64" ]]; then
		echo "aarch64"
	else
		echo "x64"
	fi
}

function _get_latest_version() {
	curl -s "https://api.github.com/repos/${_repo}/releases/latest" \
		| grep -oE '"tag_name": "[^"]+"' \
		| grep -oE '[0-9]+(\.[0-9]+)+'
}

function _get_installed_version() {
	code --list-extensions --show-versions 2>/dev/null \
		| grep -i "^${_extension_id}@" \
		| head -n1 \
		| cut -d'@' -f2
}

function _download_and_install() {
	_version="$1"
	_os=$(_get_os)
	_arch=$(_get_arch)

	if [[ -z "${_os}" ]]; then
		echo "Unsupported OS: ${_uname}"
		false
		return
	fi

	_tmpdir=$(mktemp -d)
	_vsix="kotlin-lsp-${_version}-${_os}-${_arch}.vsix"
	_url="https://download-cdn.jetbrains.com/kotlin-lsp/${_version}/${_vsix}"

	cd "${_tmpdir}" || exit
	if curl -fLO "${_url}"; then
		code --install-extension "${_tmpdir}/${_vsix}" --force
	else
		echo "Failed to download ${_url}"
		false
	fi
}

function install() {
	if ! command_exists code; then
		echo "VS Code CLI ('code') is not available in PATH"
		false
		return
	fi

	if ! command_exists curl; then
		echo "curl doesn't exist"
		false
		return
	fi

	_installed_version=$(_get_installed_version)
	if [[ -n "${_installed_version}" ]]; then
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
	if ! command_exists code; then
		echo "VS Code CLI ('code') is not available in PATH"
		false
		return
	fi

	if ! command_exists curl; then
		echo "curl doesn't exist"
		false
		return
	fi

	_installed_version=$(_get_installed_version)
	if [[ -z "${_installed_version}" ]]; then
		install
		return
	fi

	_latest_version=$(_get_latest_version)
	if [[ -z "${_latest_version}" ]]; then
		echo "Could not determine latest version"
		false
		return
	fi

	if [[ "${_installed_version}" == "${_latest_version}" ]]; then
		return
	fi

	_download_and_install "${_latest_version}"
}

if [ -n "$1" ]; then
	"$1"
else
	false
fi

unset command_exists install upgrade _get_os _get_arch _get_latest_version _get_installed_version _download_and_install
unset _uname _extension_id _repo _installed_version _latest_version _tmpdir _vsix _url _version _os _arch _m
