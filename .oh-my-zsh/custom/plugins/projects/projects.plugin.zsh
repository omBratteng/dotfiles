if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	p() { cd /srv/"$1"; }
	_p() { _files -W /srv -/; }
	compdef _p p
elif [[ "$OSTYPE" == "darwin"* ]]; then
	p() { cd ~/Developer/"$1"; }
	_p() { _files -W ~/Developer -/; }
	compdef _p p
	pd() { cd ~/Developer/dailydotdev/"$1"; }
	_pd() { _files -W ~/Developer/dailydotdev -/; }
	compdef _pd pd
fi;
