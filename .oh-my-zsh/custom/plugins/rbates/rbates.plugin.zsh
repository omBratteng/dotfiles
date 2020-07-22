if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	p() { cd /srv/$1; }
	_p() { _files -W /srv -/; }
	compdef _p p
elif [[ "$OSTYPE" == "darwin"* ]]; then
	p() { cd ~/Projects/$1; }
	_p() { _files -W ~/Projects -/; }
	compdef _p p

	ph() { cd ~/Projects/http/$1; }
	_ph() { _files -W ~/Projects/http -/; }
	compdef _ph ph
fi;

h() { cd ~/$1; }
_h() { _files -W ~/ -/; }
compdef _h h
