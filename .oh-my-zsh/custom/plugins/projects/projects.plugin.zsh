if [[ -z "$_PD_DIR" ]]; then
	if [[ "$OSTYPE" == "linux-gnu"* ]]; then
		_PD_DIR=/srv
	elif [[ "$OSTYPE" == "darwin"* ]]; then
		_PD_DIR=~/Developer
	fi
fi

: ${_PD_DEPTH:=3}
: ${_PD_STOP_AT:=.git}  # colon-separated list, e.g. ".git:docker-compose.yml"

# Returns 0 if $1 should be treated as a leaf (stop descending).
_p_is_leaf() {
	local dir=$1 entry
	for entry in ${(s.:.)_PD_STOP_AT}; do
		[[ -e "$dir/$entry" ]] && return 0
	done
	return 1
}

# Collect dirs up to $_PD_DEPTH levels, stopping at leaf dirs.
# Args: base, [skip_top_entry]
_p_complete_dirs() {
	local base=$1 skip=$2
	local -a dirs
	local d1 d2 d3

	for d1 in "$base"/*(N/); do
		local n1="${d1#$base/}"
		[[ -n "$skip" && "$n1" == "$skip" ]] && continue
		dirs+=("$n1/")
		(( _PD_DEPTH < 2 )) && continue
		_p_is_leaf "$d1" && continue

		for d2 in "$d1"/*(N/); do
			local n2="${d2#$base/}"
			dirs+=("$n2/")
			(( _PD_DEPTH < 3 )) && continue
			_p_is_leaf "$d2" && continue

			for d3 in "$d2"/*(N/); do
				dirs+=("${d3#$base/}/")
			done
		done
	done

	compadd -S '' -a dirs
}

p() { cd "$_PD_DIR/$1"; }
_p() { _p_complete_dirs "$_PD_DIR" "$_PD_WORK_DIR"; }
compdef _p p

pd() {
	if [[ -z "$_PD_WORK_DIR" ]]; then
		echo "Error: _PD_WORK_DIR is not set" >&2
		return 1
	fi
	cd "$_PD_DIR/$_PD_WORK_DIR/$1"
}
_pd() {
	if [[ -z "$_PD_WORK_DIR" ]]; then
		compadd -x "Error: _PD_WORK_DIR is not set"
		return 1
	fi
	_p_complete_dirs "$_PD_DIR/$_PD_WORK_DIR"
}
compdef _pd pd
