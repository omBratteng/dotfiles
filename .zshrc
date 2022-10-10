# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#	-------------------------------------------
#		ENVIRONMENT CONFIGURATION
#	-------------------------------------------
ZSH_THEME="powerlevel10k/powerlevel10k"
HIST_STAMPS="dd.mm.yyyy"

for zshrc_snipplet in $XDG_CONFIG_HOME/zsh.d/S[0-9][0-9]*[^~] ; do
    source "$zshrc_snipplet"
done


#	Enable Plugins
#	------------------------------------------------------------------------
plugins=(
	aliases
	colored-man-pages
	docker
	docker-compose
	docker-machine
	gh
	git
	gitignore
	helm
	kubectl
	kubectx
	pip
	poetry
	projects
	sublime
	sudo
	yarn
	zsh-autosuggestions
	zsh-completions
	zsh-plugin-pipx
	zsh-syntax-highlighting
)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

#	Enable oh-my-zsh
#	------------------------------------------------------------------------
source "$ZSH"/oh-my-zsh.sh

alias upgrade_dotfiles="$DOTFILES/bootstrap.sh --upgrade"
alias update_dotfiles="$DOTFILES/bootstrap.sh --sync"

#	---------------------------------------
#		SYSTEMS OPERATIONS & INFORMATION
#	---------------------------------------

if [ -x "$(command -v exa)" ]; then												# Replace default `ls` with `exa`
	alias ls="exa"
	alias la="exa --long --all --group --git"
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
if [ -f "$XDG_CONFIG_HOME"/lscolors/lscolors.sh ]; then
	. "$XDG_CONFIG_HOME/lscolors/lscolors.sh"
fi

#	Trigger a new load of autocompletions
#	-------------------------------------------------------------------
autoload -U compinit && compinit

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f $XDG_CONFIG_HOME/p10k.zsh ]] || source "$XDG_CONFIG_HOME"/p10k.zsh
