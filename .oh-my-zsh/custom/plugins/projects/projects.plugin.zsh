if [[ -z "$_PD_DIR" ]]; then
	if [[ "$OSTYPE" == "linux-gnu"* ]]; then
		_PD_DIR=/srv
	elif [[ "$OSTYPE" == "darwin"* ]]; then
		_PD_DIR=~/Developer
	fi
fi

p() { cd "$_PD_DIR/$1"; }
_p() { _files -W "$_PD_DIR" -/; }
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
	_files -W "$_PD_DIR/$_PD_WORK_DIR" -/
}
compdef _pd pd
