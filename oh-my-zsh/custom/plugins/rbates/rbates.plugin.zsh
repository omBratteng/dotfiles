
p() { cd ~/Prosjekter/$1; }
_p() { _files -W ~/Prosjekter -/; }
compdef _p p

h() { cd ~/$1; }
_h() { _files -W ~/ -/; }
compdef _h h
