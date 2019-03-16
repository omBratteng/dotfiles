
p() { cd ~/Projects/$1; }
_p() { _files -W ~/Projects -/; }
compdef _p p

h() { cd ~/$1; }
_h() { _files -W ~/ -/; }
compdef _h h
