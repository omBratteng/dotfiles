if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	p() { cd /srv/"$1"; }
	_p() { _files -W /srv -/; }
	compdef _p p
elif [[ "$OSTYPE" == "darwin"* ]]; then
	p() { cd ~/Developer/"$1"; }
	_p() { _files -W ~/Developer -/; }
	compdef _p p

	pd() {
		if [[ -z "$_PD_WORK_DIR" ]]; then
			echo "Error: _PD_WORK_DIR is not set" >&2
			return 1
		fi
		cd ~/Developer/"$_PD_WORK_DIR"/"$1"
	}
	_pd() {
		if [[ -z "$_PD_WORK_DIR" ]]; then
			compadd -x "Error: _PD_WORK_DIR is not set"
			return 1
		fi
		_files -W ~/Developer/"$_PD_WORK_DIR" -/
	}
	compdef _pd pd
fi
