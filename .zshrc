#	-------------------------------------------
#		ENVIRONMENT CONFIGURATION
#	-------------------------------------------
export ZSH=$HOME/.oh-my-zsh
export XDG_CONFIG_HOME=$HOME/.config
ZSH_THEME="clean"
HIST_STAMPS="dd.mm.yyyy"

for zshrc_snipplet in $XDG_CONFIG_HOME/zsh.d/S[0-9][0-9]*[^~] ; do
    source $zshrc_snipplet
done


#	Enable Plugins
#	------------------------------------------------------------------------
plugins=(
	colored-man-pages
	git
	encode64
	sudo
	zsh-syntax-highlighting
	zsh-autosuggestions
	yarn
	sublime
	docker
	docker-compose
	docker-machine
	kubectl
	helm
	rbates
)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

#	Enable oh-my-zsh
#	------------------------------------------------------------------------
source $ZSH/oh-my-zsh.sh

alias upgrade_dotfiles="$DOTFILES/bootstrap.sh --upgrade"
alias update_dotfiles="$DOTFILES/bootstrap.sh --sync"

#	---------------------------------------
#		SYSTEMS OPERATIONS & INFORMATION
#	---------------------------------------

if [ -x "$(command -v exa)" ]; then												# Replace default `ls` with `exa`
	alias ls="exa"
	alias la="exa --long --all --group"
fi

if [ -x "$(command -v duf)" ]; then												# Replace default `df` with `duf`
	alias df="duf"
fi

if [ -x "$(command -v bat)" ]; then												# Replace default `df` with `duf`
	alias cat="bat"
fi

#	neofetch:	Fancy boot info
#	-------------------------------------------------------------------
if [ -x "$(command -v neofetch)" ]; then
	neofetch
fi

#	LS_COLORS:	Fancy ls colors
#	-------------------------------------------------------------------
if [ -f $XDG_CONFIG_HOME/lscolors/lscolors.sh ]; then
	. "$XDG_CONFIG_HOME/lscolors/lscolors.sh"
fi

#	Trigger a new load of autocompletions
#	-------------------------------------------------------------------
autoload -U compinit && compinit
