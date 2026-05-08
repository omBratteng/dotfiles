#!/usr/bin/env zsh

if [[ -z "$_PD_DIR" ]]; then
	if [[ "$OSTYPE" == "linux-gnu"* ]]; then
		_PD_DIR=/srv
	elif [[ "$OSTYPE" == "darwin"* ]]; then
		_PD_DIR=~/Developer
	fi
fi

_p_init_colors() {
	[[ -n "$_PD_COLORS_INITED" ]] && return
	typeset -g _PD_COLORS_INITED=1

	local ncolors=0
	if [[ -t 1 && -n "$TERM" && "$TERM" != "dumb" ]] && which tput >/dev/null 2>&1; then
		ncolors=$(tput colors 2>/dev/null || echo 0)
	fi
	if (( ncolors >= 8 )); then
		typeset -g _PD_RED="$(tput setaf 1)"
		typeset -g _PD_GREEN="$(tput setaf 2)"
		typeset -g _PD_YELLOW="$(tput setaf 3)"
		typeset -g _PD_BLUE="$(tput setaf 4)"
		typeset -g _PD_BOLD="$(tput bold)"
		typeset -g _PD_RESET="$(tput sgr0)"
	else
		typeset -g _PD_RED="" _PD_GREEN="" _PD_YELLOW="" _PD_BLUE="" _PD_BOLD="" _PD_RESET=""
	fi
}

# Shared
: ${_PD_DEPTH:=3}
: ${_PD_STOP_AT:=.git}        # colon-separated, e.g. ".git:docker-compose.yml"

# Per-command SCM/clone config. _P_* applies to `p`, _PD_* to `pd`.
local _scope
for _scope in _P _PD; do
	: ${(P)${:-${_scope}_SCM}:=}
	: ${(P)${:-${_scope}_SCM_HOST}:=}
	: ${(P)${:-${_scope}_SCM_SSH_PORT}:=}
	: ${(P)${:-${_scope}_SCM_PROTO}:=ssh}
	: ${(P)${:-${_scope}_SCM_SSH_USER}:=git}
	: ${(P)${:-${_scope}_SCM_URL_TEMPLATE}:=}
	: ${(P)${:-${_scope}_CLONE}:=0}
	: ${(P)${:-${_scope}_CLONE_PROMPT}:=1}
	: ${(P)${:-${_scope}_CLONE_ARGS}:=}
done
unset _scope

_p_err()  { _p_init_colors; echo "${_PD_RED}${_PD_BOLD}pd:${_PD_RESET} ${_PD_RED}$*${_PD_RESET}" >&2; }
_p_warn() { _p_init_colors; echo "${_PD_YELLOW}${_PD_BOLD}pd:${_PD_RESET} ${_PD_YELLOW}$*${_PD_RESET}" >&2; }
_p_info() { _p_init_colors; echo "${_PD_BLUE}${_PD_BOLD}pd:${_PD_RESET} $*"; }
_p_ok()   { _p_init_colors; echo "${_PD_GREEN}${_PD_BOLD}pd:${_PD_RESET} ${_PD_GREEN}$*${_PD_RESET}"; }

# Read a scoped config var by name. $1=scope (e.g. _P), $2=suffix (e.g. SCM_HOST).
_p_cfg() {
	local var="${1}_${2}"
	echo "${(P)var}"
}

_p_is_leaf() {
	local dir=$1 entry
	for entry in ${(s.:.)_PD_STOP_AT}; do
		[[ -e "$dir/$entry" ]] && return 0
	done
	return 1
}

_p_complete_dirs() {
	local base=$1 skip=$2
	local -a dirs
	local d1 d2 d3 n1 n2

	for d1 in "$base"/*(N/); do
		n1="${d1#$base/}"
		[[ -n "$skip" && "$n1" == "$skip" ]] && continue
		dirs+=("$n1/")
		(( _PD_DEPTH < 2 )) && continue
		_p_is_leaf "$d1" && continue

		for d2 in "$d1"/*(N/); do
			n2="${d2#$base/}"
			dirs+=("$n2/")
			(( _PD_DEPTH < 3 )) && continue
			_p_is_leaf "$d2" && continue

			for d3 in "$d2"/*(N/); do
				dirs+=("${d3#$base/}/")
			done
		done
	done

	compadd -S '' -M 'l:|=* r:|=*' -a dirs
}

_p_confirm_clone() {
	_p_init_colors
	local scope=$1 url=$2
	[[ "$(_p_cfg $scope CLONE_PROMPT)" != "1" ]] && return 0

	[[ ! -t 0 ]] && {
		_p_err "no TTY, refusing to clone ${_PD_BOLD}${url}${_PD_RESET}"
		return 1
	}

	local reply
	read -q "reply?${_PD_YELLOW}${_PD_BOLD}pd:${_PD_RESET} clone ${_PD_BOLD}${url}${_PD_RESET}? [${_PD_GREEN}y${_PD_RESET}/${_PD_RED}${_PD_BOLD}N${_PD_RESET}] "
	echo
	[[ "$reply" == "y" ]]
}

_p_clone_url() {
	local scope=$1 project=$2 repo=$3
	local scm=$(_p_cfg $scope SCM)
	local host=$(_p_cfg $scope SCM_HOST)
	local port=$(_p_cfg $scope SCM_SSH_PORT)
	local proto=$(_p_cfg $scope SCM_PROTO)
	local user=$(_p_cfg $scope SCM_SSH_USER)
	local tmpl=$(_p_cfg $scope SCM_URL_TEMPLATE)
	local url

	case "$scm" in
		bitbucket-dc)
			if [[ "$proto" == "ssh" ]]; then
				echo "ssh://${user}@${host}:${port}/${project}/${repo}.git"
			else
				echo "https://${host}/scm/${project}/${repo}.git"
			fi
			;;
		github|gitlab)
			if [[ "$proto" == "ssh" ]]; then
				echo "${user}@${host}:${project}/${repo}.git"
			else
				echo "https://${host}/${project}/${repo}.git"
			fi
			;;
		generic)
			url=$tmpl
			url=${url//\{proto\}/$proto}
			url=${url//\{user\}/$user}
			url=${url//\{host\}/$host}
			url=${url//\{port\}/$port}
			url=${url//\{project\}/$project}
			url=${url//\{repo\}/$repo}
			echo "$url"
			;;
		*)
			return 1
			;;
	esac
}

_p_check_clone_config() {
	local scope=$1
	local scm=$(_p_cfg $scope SCM)
	local host=$(_p_cfg $scope SCM_HOST)
	local port=$(_p_cfg $scope SCM_SSH_PORT)
	local proto=$(_p_cfg $scope SCM_PROTO)
	local tmpl=$(_p_cfg $scope SCM_URL_TEMPLATE)
	local -a missing

	case "$scm" in
		bitbucket-dc)
			[[ -z "$host" ]] && missing+=("${scope}_SCM_HOST")
			[[ "$proto" == "ssh" && -z "$port" ]] && missing+=("${scope}_SCM_SSH_PORT")
			;;
		github|gitlab)
			[[ -z "$host" ]] && missing+=("${scope}_SCM_HOST")
			;;
		generic)
			[[ -z "$tmpl" ]] && missing+=("${scope}_SCM_URL_TEMPLATE")
			;;
		*)
			_p_err "unknown ${scope}_SCM '${_PD_BOLD}${scm}${_PD_RESET}${_PD_RED}' (expected: bitbucket-dc|github|gitlab|generic)"
			return 1
			;;
	esac
	if (( ${#missing} )); then
		_p_err "cannot clone, unset: ${_PD_BOLD}${missing[*]}${_PD_RESET}"
		return 1
	fi
	return 0
}

# Args: scope, base_dir, relative_path
_p_cd_or_clone() {
	local scope=$1 base=$2 rel=$3
	local target="$base/$rel"
	local project repo url parent clone_args_str
	local -a clone_args

	if [[ -d "$target" ]]; then
		cd "$target"
		return
	fi

	if [[ "$(_p_cfg $scope CLONE)" != "1" ]]; then
		_p_err "'${_PD_BOLD}${rel}${_PD_RESET}${_PD_RED}' not found (set ${_PD_BOLD}${scope}_CLONE=1${_PD_RESET}${_PD_RED} to auto-clone)"
		return 1
	fi

	_p_check_clone_config "$scope" || return 1

	rel=${rel%/}
	project=${rel%%/*}
	repo=${rel#*/}

	if [[ -z "$project" || -z "$repo" || "$project" == "$repo" ]]; then
		_p_err "'${_PD_BOLD}${rel}${_PD_RESET}${_PD_RED}' is not <project>/<repo>, cannot clone"
		return 1
	fi

	url=$(_p_clone_url "$scope" "$project" "$repo")
	_p_confirm_clone "$scope" "$url" || { _p_warn "aborted"; return 1; }

	parent="$base/$project"
	mkdir -p "$parent" || return 1

	clone_args_str=$(_p_cfg $scope CLONE_ARGS)
	if [[ -n "$clone_args_str" ]]; then
		local a
		eval 'for a in '"$clone_args_str"'; do clone_args+=("$a"); done'
	fi
	clone_args+=("$url" "$repo")

	_p_info "cloning ${_PD_BOLD}${url}${_PD_RESET} -> ${_PD_BOLD}${parent}/${repo}${_PD_RESET}"
	GIT_TERMINAL_PROMPT=0 SSH_ASKPASS_REQUIRE=never \
		git -C "$parent" clone "${clone_args[@]}" || { _p_err "clone failed"; return 1; }
	_p_ok "cloned ${_PD_BOLD}${project}/${repo}${_PD_RESET}"
	cd "$parent/$repo"
}

p()  { _p_cd_or_clone _P  "$_PD_DIR" "$1"; }
_p() { _p_complete_dirs "$_PD_DIR" "$_PD_WORK_DIR"; }
compdef _p p

pd() {
	if [[ -z "$_PD_WORK_DIR" ]]; then
		_p_err "${_PD_BOLD}_PD_WORK_DIR${_PD_RESET}${_PD_RED} is not set"
		return 1
	fi
	_p_cd_or_clone _PD "$_PD_DIR/$_PD_WORK_DIR" "$1"
}
_pd() {
	if [[ -z "$_PD_WORK_DIR" ]]; then
		compadd -x "Error: _PD_WORK_DIR is not set"
		return 1
	fi
	_p_complete_dirs "$_PD_DIR/$_PD_WORK_DIR"
}
compdef _pd pd
