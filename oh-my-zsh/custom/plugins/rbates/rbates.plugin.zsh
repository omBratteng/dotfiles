
c() { cd ~/Prosjekter/$1; }
_c() { _files -W ~/Prosjekter -/; }
compdef _c c

h() { cd ~/$1; }
_h() { _files -W ~/ -/; }
compdef _h h
