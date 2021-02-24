#!/usr/bin/env zsh

if which tput >/dev/null 2>&1; then
    ncolors=$(tput colors)
fi
if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
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

cd "$(dirname "${(%):-%N}")";
git pull origin main --ff-only --quiet

if [[ ! -v DOTFILES ]]; then
	echo 'export DOTFILES="$HOME/.dotfiles"' >> ~/.zshenv.local
fi


function syncDotfiles() {
	echo ""
	echo "${BOLD}${BLUE}>> Syncing dotfiles${RESET}"
	rsync \
		--exclude ".git/" \
		--exclude "scripts/" \
		--exclude ".DS_Store" \
		--exclude "bootstrap.sh" \
		--exclude "README.md" \
		--exclude "LICENSE" \
		--exclude "Rakefile" \
		--exclude "*.local" \
		--exclude ".vscode/" \
		-avh --no-perms . ~;
	echo "${GREEN}>> Done${RESET}"

	source ~/.zshrc
	source $XDG_CONFIG_HOME/p10k.zsh
}

function switch_to_zsh() {
	if [ "$(basename "$SHELL")" = "zsh" ]; then
		return
	else
		if ! command_exists -v chsh; then
			cat <<-EOF
				>> I can't change your shell automatically because this system does not have chsh.
				${BLUE}>> Please manually change your default shell to zsh${RESET}
			EOF
			return
		fi

		chsh -s $(which zsh)
		return
	fi
}

function install() {
	if $2; then
		echo "${BOLD}${BLUE}>> Installing ${1}${RESET}"
		if zsh ./scripts/$1.zsh install; then
			echo "${GREEN}>> Done${RESET}"
		else
			echo "${YELLOW}>> Already installed${RESET}"
		fi
	else
		read "?Do you want to install ${1}? ${yes_no}"
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			echo "${BOLD}${BLUE}>> Installing ${1}${RESET}"
			if zsh ./scripts/$1.zsh install; then
				echo "${GREEN}>> Done${RESET}"
			else
				echo "${YELLOW}>> Already installed${RESET}"
			fi
		elif [[ $REPLY =~ ^[Qq]$ ]]; then
			quit
		else
			echo "${BLUE}>> Skipping ${1} installation${RESET}"
		fi;
	fi
}

function upgrade() {
	echo "${BOLD}${BLUE}>> Upgrading ${1}${RESET}"
	if zsh ./scripts/$1.zsh upgrade; then
		echo "${GREEN}>> Done${RESET}"
	else
		echo "${RED}>> An error occured when upgrading ${1}, please check manually${RESET}"
	fi
}

scripts=(
	n
	httpie
	nanorc
	ls_colors
	git_radar
	oh_my_zsh
	powerlevel10k
	zsh_autosuggestions
	zsh_syntax_highlighting
	zsh_completions
)

if [ "$1" = "--force" -o "$1" = "-f" ]; then
	for script in "${scripts[@]}";
	do
		install $script true
	done
	switch_to_zsh;
	syncDotfiles;
elif [ "$1" = "--upgrade" -o "$1" = "-u" ]; then
	for script in "${scripts[@]}";
	do
		upgrade $script
	done
	syncDotfiles;
elif [ "$1" = "--sync" -o "$1" = "-s" ]; then
	syncDotfiles;
else
	for script in "${scripts[@]}";
	do
		install $script false
	done

	if [ ! "$(basename "$SHELL")" = "zsh" ]; then
		read "?Do you want to switch to zsh? (${YELLOW}recommended${RESET}) ${yes_no}"
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			switch_to_zsh;
		elif [[ $REPLY =~ ^[Qq]$ ]]; then
			quit
		else
			echo "${BLUE}>> Skipping switching to zsh${RESET}"
		fi;
	fi

	read "?Do you want to sync the dotfiles? ${RED}This may overwrite existing files in your home directory.${RESET} ${yes_no}"
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		syncDotfiles;
	elif [[ $REPLY =~ ^[Qq]$ ]]; then
		quit
	else
		echo "${BLUE}>> Skipping dotfile sync${RESET}"
	fi;
fi

printf '%s' "$GREEN"
printf '%s\n' '         __      __  _____ __            '
printf '%s\n' '    ____/ /___  / /_/ __(_) /__  _____   '
printf '%s\n' '   / __  / __ \/ __/ /_/ / / _ \/ ___/   '
printf '%s\n' ' _/ /_/ / /_/ / /_/ __/ / /  __(__  )    '
printf '%s\n' '(_)__,_/\____/\__/_/ /_/_/\___/____/     '
printf '%s\n' ''
printf "${BLUE}%s\n" "Hooray! .dotfiles has been updated and/or is at the current version.${RESET}"
sed -i "s|XDG_CONFIG_HOME|$XDG_CONFIG_HOME|" $HOME/.tldrrc
