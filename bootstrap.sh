#!/usr/bin/env zsh

_uname=$(uname -s)

if which tput >/dev/null 2>&1; then
    ncolors=$(tput colors)
fi
if [ -t 1 ] && [ -n "${ncolors}" ] && [ "${ncolors}" -ge 8 ]; then
	RED="$(tput setaf 1)"
	GREEN="$(tput setaf 2)"
	YELLOW="$(tput setaf 3)"
	BLUE="$(tput setaf 4)"
	BOLD="$(tput bold)"
	RESET="$(tput sgr0)"
else
	RED=""
	GREEN=""
	YELLOW=""
	BLUE=""
	BOLD=""
	RESET=""
fi

quit() {
	echo "${BOLD}${YELLOW}>> Quitting${RESET}"
	exit 1
}
command_exists() {
	command -v "$@" >/dev/null 2>&1
}
yes_no="${RESET}(${GREEN}y${RESET}/${RED}n${RESET}/${YELLOW}q${RESET}) "

write_zshenv_local() {
	print -r -- "$1" >> ~/.zshenv.local
}

write_quoted_zshenv_local() {
	local name="$1"
	local value="$2"
	local escaped_value="${value//\\/\\\\}"
	escaped_value="${escaped_value//\"/\\\"}"
	write_zshenv_local "export ${name}=\"${escaped_value}\""
}

write_bootstrap_conf() {
	print -r -- "$1" >> "$bootstrap_conf"
}

record_bootstrap_decision() {
	local name="$1"
	local decision="$2"
	write_bootstrap_conf "export ${name}=${decision}"
}

prompt_env_var() {
	local name="$1"
	local default_value="$2"
	local write_default_value="$3"
	local prompt_text="$4"
	local value="${(P)name}"
	local write_value

	if [[ -n "$value" ]]; then
		return 0
	fi

	read -r "?$prompt_text [${default_value}]: " value
	if [[ -z "$value" ]]; then
		value="$default_value"
		write_value="$write_default_value"
	else
		write_value="$value"
	fi

	export "$name=$value"
	write_quoted_zshenv_local "$name" "$write_value"
}

prompt_optional_env_var() {
	local name="$1"
	local prompt_text="$2"
	local value="${(P)name}"

	if [[ -n "$value" ]]; then
		return 0
	fi

	read -r "?$prompt_text (leave blank to skip): " value
	if [[ -z "$value" ]]; then
		return 0
	fi

	export "$name=$value"
	write_quoted_zshenv_local "$name" "$value"
}

prompt_projects_envs() {
	if [[ "${_uname}" == "Darwin" ]]; then
		prompt_env_var _PD_DIR "$HOME/Developer" '${HOME}/Developer' "Where should project directories live?"
	else
		prompt_env_var _PD_DIR "/srv" "/srv" "Where should project directories live?"
	fi
	prompt_optional_env_var _PD_WORK_DIR "Optional work subdirectory for pd"
}

cd "$(dirname "${(%):-%N}")";
if [ "$1" != "--sync" -a "$1" != "-s" ]; then
	git pull origin main --ff-only --quiet
fi

if [[ ! -v DOTFILES ]]; then
	export DOTFILES="$HOME/.dotfiles"
	write_quoted_zshenv_local DOTFILES '$HOME/.dotfiles'
fi

bootstrap_conf="${DOTFILES}/dotfiles.conf"
if [[ -f "$bootstrap_conf" ]]; then
	source "$bootstrap_conf"
fi

function syncDotfiles() {
	echo ""
	echo "${BOLD}${BLUE}>> Syncing dotfiles${RESET}"
	rsync \
		--exclude ".git/" \
		--exclude "scripts/" \
		--exclude ".DS_Store" \
		--exclude ".gitignore" \
		--exclude "bootstrap.sh" \
		--exclude "README.md" \
		--exclude "LICENSE" \
		--exclude "Rakefile" \
		--exclude "dotfiles.conf" \
		--include ".local/" \
		--exclude "*.local" \
		--exclude ".vscode/" \
		--exclude "Library/" \
		--exclude "macos_defaults" \
		-avh --no-perms . ~;

	if [[ "${_uname}" == "Darwin" ]] && [ -d "Library" ]; then
		for macOsDir in Library; do
			rsync -avh --no-perms ${macOsDir} ~;
		done
	fi

	echo "${GREEN}>> Done${RESET}"

	source ~/.zshrc
	source "${XDG_CONFIG_HOME}"/p10k.zsh
}

function switch_to_zsh() {
	if [ "$(basename "${SHELL}")" = "zsh" ]; then
		return
	else
		if ! command_exists -v chsh; then
			cat <<-EOF
				>> I can't change your shell automatically because this system does not have chsh.
				${BLUE}>> Please manually change your default shell to zsh${RESET}
			EOF
			return
		fi

		if [[ "${_uname:0:5}" == "Linux" ]]; then
			if ! grep "$(whoami)" /etc/passwd | grep -q zsh; then
				echo "${BLUE}>> Changing default shell to zsh${RESET}"
				chsh -s $(which zsh)
				return
			else
				echo "${YELLOW}>> Default shell is already zsh${RESET}"
				return
			fi
		fi

		chsh -s $(which zsh)
		return
	fi
}

function install() {
	local script="$1"
	local force_install="$2"
	local decision_var="${(U)script}"
	local configured_decision="${(P)decision_var}"

	if [[ "$force_install" != true && "$BOOTSTRAP_REINSTALL" != true && -n "$configured_decision" ]]; then
		if [[ "$configured_decision" == skip ]]; then
			echo "${BLUE}>> Skipping ${script} installation${RESET}"
		fi
		return
	fi

	if $force_install; then
		echo "${BOLD}${BLUE}>> Installing ${1}${RESET}"
		export _FORCE_INSTALL=true
		if zsh ./scripts/"$1".zsh install; then
			echo "${GREEN}>> Done${RESET}"
		else
			echo "${YELLOW}>> Already installed${RESET}"
		fi
		record_bootstrap_decision "$decision_var" install
	else
		read "?Do you want to install ${1}? ${yes_no}"
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			echo "${BOLD}${BLUE}>> Installing ${1}${RESET}"
			if zsh ./scripts/"$1".zsh install; then
				echo "${GREEN}>> Done${RESET}"
			else
				echo "${YELLOW}>> Already installed${RESET}"
			fi
			record_bootstrap_decision "$decision_var" install
		elif [[ $REPLY =~ ^[Qq]$ ]]; then
			quit
		else
			echo "${BLUE}>> Skipping ${1} installation${RESET}"
			record_bootstrap_decision "$decision_var" skip
		fi;
	fi
}

function upgrade() {
	echo "${BOLD}${BLUE}>> Upgrading ${1}${RESET}"
	if zsh ./scripts/"$1".zsh upgrade; then
		echo "${GREEN}>> Done${RESET}"
	else
		echo "${RED}>> An error occured when upgrading ${1}, please check manually${RESET}"
	fi
}

scripts=(
	atuin
	bat
	eza
	ls_colors
	nanorc
	oh_my_zsh
	powerlevel10k
	step
	yq
	zsh_autosuggestions
	zsh_completions
	zsh_syntax_highlighting
	zsh_you_should_use
)

if [[ "${_uname}" == "Darwin" ]]; then
	scripts+=(
		kubectl
		kubectx
		n
	)
fi


BOOTSTRAP_REINSTALL=false

if [ "$1" = "--force" -o "$1" = "-f" ]; then
	for script in "${scripts[@]}";
	do
		install "${script}" true
	done
	switch_to_zsh;
	prompt_projects_envs;
	syncDotfiles;
elif [ "$1" = "--reinstall" -o "$1" = "-r" ]; then
	BOOTSTRAP_REINSTALL=true
	for script in "${scripts[@]}";
	do
		install "${script}" false
	done
	switch_to_zsh;
	prompt_projects_envs;
	syncDotfiles;
elif [ "$1" = "--upgrade" -o "$1" = "-u" ]; then
	syncDotfiles;
	# If second argument is given, upgrade only that script
	if [ -n "$2" ]; then
		upgrade "$2"
	else
		for script in "${scripts[@]}";
		do
			upgrade "${script}"
		done
	fi
	syncDotfiles;
elif [ "$1" = "--sync" -o "$1" = "-s" ]; then
	syncDotfiles;
elif [ "$1" = "--update" -o "$1" = "-u" ]; then
	syncDotfiles;
else
	for script in "${scripts[@]}";
	do
		install "${script}" false
	done

	if [ ! "$(basename "${SHELL}")" = "zsh" ]; then
		read "?Do you want to switch to zsh? (${YELLOW}recommended${RESET}) ${yes_no}"
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			switch_to_zsh;
		elif [[ $REPLY =~ ^[Qq]$ ]]; then
			quit
		else
			echo "${BLUE}>> Skipping switching to zsh${RESET}"
		fi;
	fi

	prompt_projects_envs;

	read "?Do you want to sync the dotfiles? ${RED}This may overwrite existing files in your home directory.${RESET} ${yes_no}"
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		syncDotfiles;
	elif [[ $REPLY =~ ^[Qq]$ ]]; then
		quit
	else
		echo "${BLUE}>> Skipping dotfile sync${RESET}"
	fi;
fi

printf '%s' "${GREEN}"
printf '%s\n' '         __      __  _____ __            '
printf '%s\n' '    ____/ /___  / /_/ __(_) /__  _____   '
printf '%s\n' '   / __  / __ \/ __/ /_/ / / _ \/ ___/   '
printf '%s\n' ' _/ /_/ / /_/ / /_/ __/ / /  __(__  )    '
printf '%s\n' '(_)__,_/\____/\__/_/ /_/_/\___/____/     '
printf '%s\n' ''
printf "${BLUE}%s\n" "Hooray! .dotfiles has been updated and/or is at the current version.${RESET}"

unset _uname
