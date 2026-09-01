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
#	  S26      vendor lib gates        (DISABLE_LS_COLORS when eza owns `ls`)
#	  S28      compinit
#	  S30-S31  vendored oh-my-zsh libs (they call compdef)
#	  S40-S50  vendored oh-my-zsh plugins, then the projects plugin
#	  S60      zsh-autosuggestions / you-should-use / syntax-highlighting
#
#	See .config/zsh.d/vendor/VENDOR.md for what was kept from oh-my-zsh.
for zshrc_snipplet in $XDG_CONFIG_HOME/zsh.d/S[0-9][0-9]*[^~] ; do
    # Skip the .zwc wordcode files scripts/zsh_compile.zsh drops next to the
    # snippets; `source` finds them on its own via the matching .zsh-free name.
    [[ "${zshrc_snipplet}" == *.zwc ]] && continue
    source "${zshrc_snipplet}"
done
unset zshrc_snipplet

#	---------------------------------------
#		SYSTEMS OPERATIONS & INFORMATION
#	---------------------------------------

# Replace default `ls` with `eza`
if (( $+commands[eza] )) && [[ -z "${_DISABLE_EZA}" ]]; then
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
if (( $+commands[duf] )) && [[ -z "${_DISABLE_DUF}" ]]; then
	alias df="duf"
fi

# Replace default `cat` with `bat`
if [ -z "${_DISABLE_BAT}" ]; then
	if (( $+commands[bat] )); then
		alias cat="bat"
	elif (( $+commands[batcat] )); then
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

if (( $+commands[vault] )); then
	complete -o nospace -C "$commands[vault]" vault
fi

#	Enable atuin for history sync
#	-------------------------------------------------------------------
#	`atuin init` costs a fork plus a ~60ms binary run per shell, so cache its
#	output and only regenerate when the binary or config.toml changes. The
#	zcompile pass picks up the cache automatically via its .zwc.
if (( $+commands[atuin] )) && [[ -z "${_DISABLE_ATUIN}" ]]; then
	_atuin_init="${ZSH_CACHE_DIR}/atuin-init.zsh"
	if [[ -s "${_atuin_init}" \
		&& "${_atuin_init}" -nt "${commands[atuin]}" \
		&& "${_atuin_init}" -nt "${XDG_CONFIG_HOME}/atuin/config.toml" ]]; then
		source "${_atuin_init}"
	else
		atuin init zsh --disable-up-arrow >| "${_atuin_init}" && source "${_atuin_init}"
	fi
	unset _atuin_init
fi

#	Prompt
#	-------------------------------------------------------------------
#	Loaded last, the way oh-my-zsh loaded $ZSH_THEME last.
if [ -f "${ZSH_PLUGIN_DIR}/powerlevel10k/powerlevel10k.zsh-theme" ]; then
	source "${ZSH_PLUGIN_DIR}/powerlevel10k/powerlevel10k.zsh-theme"
fi

# To customize prompt, run `p10k configure` or edit ~/.config/p10k.zsh.
[[ ! -f "${XDG_CONFIG_HOME}/p10k.zsh" ]] || source "${XDG_CONFIG_HOME}"/p10k.zsh

#	zcompile self-heal
#	-----------------------------------------------------------------------
#	scripts/zsh_compile.zsh keeps a .zwc next to everything sourced above;
#	`source` prefers the newer .zwc automatically. The check is stat-only
#	and runs in the background so it never blocks the prompt.
[[ -f "${DOTFILES:-$HOME/.dotfiles}/scripts/zsh_compile.zsh" ]] &&
	{ zsh "${DOTFILES:-$HOME/.dotfiles}/scripts/zsh_compile.zsh" compile } &!

if [[ -n "$ZSH_DEBUGRC" ]]; then
  typeset -F elapsed=$((EPOCHREALTIME - _zshrc_start))

  if (( elapsed > 1.0 )); then
    zprof
	echo "took more than 1 second to load ~/.zshrc: ${elapsed}s"
  fi
fi
