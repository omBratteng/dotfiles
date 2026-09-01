#!/usr/bin/env zsh

if [[ -n "${ZSH_DEBUGRC}" ]]; then
  zmodload zsh/zprof
  zmodload zsh/datetime
  typeset -F _zshrc_start=$EPOCHREALTIME

fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#	-------------------------------------------
#		ENVIRONMENT CONFIGURATION
#	-------------------------------------------

typeset -gU fpath path

#	Everything lives in numbered snippets under $XDG_CONFIG_HOME/zsh.d.
#	The numbering encodes the load order that used to be implicit in
#	oh-my-zsh.sh:
#
#	  S00-S21  options, variables, aliases, functions
#	  S25      ~/.zshrc.local          (PATH and FPATH, before compinit)
#	  S28      compinit
#	  S30-S31  vendored oh-my-zsh libs (they call compdef)
#	  S40-S50  vendored oh-my-zsh plugins, then the projects plugin
#	  S60      zsh-autosuggestions / you-should-use / syntax-highlighting
#
#	See .config/zsh.d/vendor/VENDOR.md for what was kept from oh-my-zsh.
for zshrc_snipplet in $XDG_CONFIG_HOME/zsh.d/S[0-9][0-9]*[^~] ; do
    source "${zshrc_snipplet}"
done
unset zshrc_snipplet

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

#	LS_COLORS:	Fancy ls colors
#	-------------------------------------------------------------------
if [ -f "${XDG_CONFIG_HOME}"/lscolors/lscolors.sh ]; then
	. "${XDG_CONFIG_HOME}/lscolors/lscolors.sh"
fi

# Match completion menu colouring to $LS_COLORS. oh-my-zsh did this as the last
# thing it ran; here it has to follow lscolors.sh, which is what sets LS_COLORS.
[[ -z "$LS_COLORS" ]] || zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

if [ -x "$(command -v vault)" ]; then
	complete -o nospace -C $(command -v vault) vault
fi

#	Enable atuin for history sync
#	-------------------------------------------------------------------
if [ -x "$(command -v atuin)" ] && [ -z "${_DISABLE_ATUIN}" ]; then
	eval "$(atuin init zsh --disable-up-arrow)"
fi

#	Prompt
#	-------------------------------------------------------------------
#	Loaded last, the way oh-my-zsh loaded $ZSH_THEME last.
if [ -f "${ZSH_PLUGIN_DIR}/powerlevel10k/powerlevel10k.zsh-theme" ]; then
	source "${ZSH_PLUGIN_DIR}/powerlevel10k/powerlevel10k.zsh-theme"
fi

# To customize prompt, run `p10k configure` or edit ~/.config/p10k.zsh.
[[ ! -f "${XDG_CONFIG_HOME}/p10k.zsh" ]] || source "${XDG_CONFIG_HOME}"/p10k.zsh

if [[ -n "$ZSH_DEBUGRC" ]]; then
  typeset -F elapsed=$((EPOCHREALTIME - _zshrc_start))

  if (( elapsed > 1.0 )); then
    zprof
	echo "took more than 1 second to load ~/.zshrc: ${elapsed}s"
  fi
fi
