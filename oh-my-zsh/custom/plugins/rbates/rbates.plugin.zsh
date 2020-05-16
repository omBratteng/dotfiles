h() { cd ~/$1; }
_h() { _files -W ~/ -/; }
compdef _h h
