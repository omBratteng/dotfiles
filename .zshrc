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
    source "${zshrc_snipplet}"
done


#	Enable Plugins
#	------------------------------------------------------------------------
plugins=(
	aliases
	colored-man-pages
	docker
	docker-compose
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
	zsh-syntax-highlighting
)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

#	Enable oh-my-zsh
#	------------------------------------------------------------------------
source "${ZSH}"/oh-my-zsh.sh

#	---------------------------------------
#		SYSTEMS OPERATIONS & INFORMATION
#	---------------------------------------

# Replace default `ls` with `eza`
if [ -x "$(command -v eza)" ] && [ -z "${_DISABLE_EZA}" ]; then
	_eza_flags=""
	alias ls="eza ${_eza_flags}"

	_eza_flags+="--long --group --git --header --mounts "
	alias l="eza ${_eza_flags}"

	_eza_flags+="--all "
	alias la="eza ${_eza_flags}"
	alias laz="eza ${_eza_flags} --context"
	alias lao="eza ${_eza_flags} --octal-permissions"
fi

# Replace default `df` with `duf`
if [ -x "$(command -v duf)" ] && [ -z "${_DISABLE_DUF}" ]; then
	alias df="duf"
fi

# Replace default `cat` with `bat`
if [ -z "${_DISABLE_BAT}" ]; then
	if [ -x "$(command -v bat)" ]; then
		alias cat="bat"
	elif [ -x "$(command -v batcat)" ]; then
		alias cat="batcat"
	fi
fi

#	neofetch:	Fancy boot info
#	-------------------------------------------------------------------
if [ -x "$(command -v neofetch)" ] && [ -z "${_DISABLE_NEOFETCH}" ]; then
	neofetch
fi

#	LS_COLORS:	Fancy ls colors
#	-------------------------------------------------------------------
if [ -f "${XDG_CONFIG_HOME}"/lscolors/lscolors.sh ]; then
	. "${XDG_CONFIG_HOME}/lscolors/lscolors.sh"
fi

#	Trigger a new load of autocompletions
#	-------------------------------------------------------------------
autoload -U compinit && compinit
autoload -U bashcompinit && bashcompinit

if [ -x "$(command -v vault)" ]; then
	complete -o nospace -C $(command -v vault) vault
fi

#	Enable atuin for history sync
#	-------------------------------------------------------------------
if [ -x "$(command -v atuin)" ] && [ -z "${_DISABLE_ATUIN}" ]; then
	eval "$(atuin init zsh --disable-up-arrow)"
fi

# To customize prompt, run `p10k configure` or edit ~/.config/p10k.zsh.
[[ ! -f "${XDG_CONFIG_HOME}/p10k.zsh" ]] || source "${XDG_CONFIG_HOME}"/p10k.zsh
