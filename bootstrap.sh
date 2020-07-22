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
#UNCOMMENTgit pull origin main --ff-only --quiet


function syncDotfiles() {
	echo ""
	echo "${BOLD}${BLUE}>> Syncing dotfiles${RESET}"
	rsync \
		--exclude ".git/" \
		--exclude "tools/" \
		--exclude ".DS_Store" \
		--exclude "bootstrap.sh" \
		--exclude "README.md" \
		--exclude "LICENSE" \
		--exclude "Rakefile" \
		--exclude "*.local" \
		-avh --no-perms . ~;
	echo "${GREEN}>> Done${RESET}"

	#UNCOMMENTsource ~/.zshrc
}

function install_n() {
	if command_exists -v n; then
		false
	else
		_tmpdir=$(mktemp -d)
		git clone --quiet https://github.com/tj/n.git $_tmpdir
		cd $_tmpdir
		sudo make install >/dev/null 2>&1
		cd -
		rm -rf $_tmpdir
		unset _tmpdir
		return
	fi
}

function install_nanorc() {
	dir="$HOME/.nano"
	if [ -d $dir ]; then
		false
	else
		git clone --quiet https://github.com/scopatz/nanorc.git $dir
		return
	fi
}

function install_git_radar() {
	dir="$HOME/.git-radar"
	if [ -d $dir ]; then
		false
	else
		git clone --quiet https://github.com/michaeldfallen/git-radar $dir
		return
	fi
}

function install_zsh_autosuggestions() {
	dir="$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
	if [ -d $dir ]; then
		false
	else
		git clone --quiet https://github.com/zsh-users/zsh-autosuggestions.git $dir
		return
	fi
}

function install_zsh_syntax_highlighting() {
	dir="$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
	if [ -d $dir ]; then
		false
	else
		git clone --quiet https://github.com/zsh-users/zsh-syntax-highlighting.git $dir
		return
	fi
}

function install_zsh_completions() {
	dir="$HOME/.oh-my-zsh/custom/plugins/zsh-completions"
	if [ -d $dir ]; then
		false
	else
		git clone --quiet https://github.com/zsh-users/zsh-completions.git $dir
		return
	fi
}


function install_oh_my_zsh() {
	dir="${HOME}/.oh-my-zsh"
	if [ -d $dir ]; then
		false
	else
		git clone --quiet https://github.com/robbyrussell/oh-my-zsh.git $dir
		return
	fi
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
		if install_$1; then
			echo "${GREEN}>> Done${RESET}"
		else
			echo "${YELLOW}>> Already installed${RESET}"
		fi
	else
		read "?Do you want to install ${1}? ${yes_no}"
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			echo "${BOLD}${BLUE}>> Installing ${1}${RESET}"
			if install_$1; then
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

if [ "$1" = "--force" -o "$1" = "-f" ]; then
	install n true
	install nanorc true
	install git_radar true
	install oh_my_zsh true
	install zsh_autosuggestions true
	install zsh_syntax_highlighting true
	install zsh_completions true
	switch_to_zsh;

	syncDotfiles;
elif [ "$1" = "--upgrade" -o "$1" = "-u" ]; then
	echo "TODO: Upgrade"
else
	install n
	install nanorc
	install git_radar
	install oh_my_zsh
	install zsh_autosuggestions
	install zsh_syntax_highlighting
	install zsh_completions

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
printf "${BLUE}%s\n" "Hooray! .dotfiles has been updated and/or is at the current version."
