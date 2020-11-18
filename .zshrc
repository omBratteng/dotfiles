#	-------------------------------------------
#		ENVIRONMENT CONFIGURATION
#	-------------------------------------------

#	Enable oh-my-zsh
#	------------------------------------------------------------------------
export ZSH=$HOME/.oh-my-zsh
export XDG_CONFIG_HOME=$HOME/.config
ZSH_THEME="clean"
HIST_STAMPS="dd.mm.yyyy"

#	Shell settings
#	------------------------------------------------------------------------
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export GPG_TTY=$(tty)

export EDITOR='vim'
export GIT_EDITOR='vim'

export GIT_RADAR_FETCH_TIME=30
export LESS=eFRX

export COMPOSER_ALLOW_SUPERUSER=1


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
source $ZSH/oh-my-zsh.sh

for zshrc_snipplet in $XDG_CONFIG_HOME/zsh.d/S[0-9][0-9]*[^~] ; do
    source $zshrc_snipplet
done

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
