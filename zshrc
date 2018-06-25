#  ---------------------------------------------------------------------------
#
#  Description:  This file holds all my BASH configurations and aliases
#
#  Sections:
#  1.   Environment Configuration
#  2.   Make Terminal Better (remapping defaults and adding functionality)
#  3.   File and Folder Management
#  4.   Make Git better
#  5.   Networking
#  6.   System Operations & Information
#  7.   OS Exports and Aliases
#
#  ---------------------------------------------------------------------------

#   -------------------------------
#   1.  ENVIRONMENT CONFIGURATION
#   -------------------------------

#   Enable oh-my-zsh
#   ------------------------------------------------------------
	export ZSH=$HOME/.oh-my-zsh
	ZSH_THEME="clean"
	HIST_STAMPS="dd.mm.yyyy"

#   Homebrew settings
#   ------------------------------------------------------------
	export LANG=en_US.UTF-8
	export LC_ALL=en_US.UTF-8
	export LANGUAGE=en_US.UTF-8
	export GPG_TTY=$(tty)

	export GIT_RADAR_FETCH_TIME=30
	export LESS=eFRX

	export COMPOSER_ALLOW_SUPERUSER=1

#   Set Paths
#   ------------------------------------------------------------
	export PATH=${PATH}:/bin
	export PATH=${PATH}:/usr/bin
	export PATH=/usr/local/bin:${PATH}
	export PATH=${PATH}:/sbin
	export PATH=${PATH}:/usr/sbin
	export PATH=${PATH}:/usr/local/sbin
	export PATH=${PATH}:~/.composer/vendor/bin

	[ -f ~/.zshrc.local ] && source ~/.zshrc.local

#   Enable Plugins
#   ------------------------------------------------------------
	plugins=(
		git
		encode64
		sudo
		zsh-syntax-highlighting
		yarn
		sublime
		docker
		docker-compose
		docker-machine
	)
	source $ZSH/oh-my-zsh.sh

#   -----------------------------
#   2.  MAKE TERMINAL BETTER
#   -----------------------------

	alias cp="cp -iv"                                               # Preferred 'cp' implentation
	alias mv="mv -iv"                                               # Preferred 'mv' implentation
	alias mkdir="mkdir -pv"                                         # Preferred 'mkdir' implentation
	alias cd..='cd ../'                                             # Go back 1 directory level (for fast typers)
	alias ..='cd ../'                                               # Go back 1 directory level
	alias ...='cd ../../'                                           # Go back 2 directory levels
	alias .3='cd ../../../'                                         # Go back 3 directory levels
	alias .4='cd ../../../../'                                      # Go back 4 directory levels
	alias .5='cd ../../../../../'                                   # Go back 5 directory levels
	alias .6='cd ../../../../../../'                                # Go back 6 directory levels
	alias ~="cd ~"                                                  # ~:            Go Home
	alias c='clear'                                                 # c:            Clear terminal display
	alias path='echo -e ${PATH//:/\\n}'                             # path:         Echo all executable Paths
	alias zshEdit='edit ~/.zshrc'

	if [ -x "$(command -v exa)" ]; then
        alias ls="exa"
        alias la="exa -la"
    fi

	alias wp="wp --allow-root"

	alias nr="npm run"

#   -------------------------------
#   3.  FILE AND FOLDER MANAGEMENT
#   -------------------------------
	zipf () { zip -r "$1".zip "$1" ; }                              # zipf:             To create a ZIP archive of a folder

#   extract:  Extract most know archives with one command
#   ---------------------------------------------------------
	extract () {
		if [ -f $1 ] ; then
		  case $1 in
			*.tar.bz2)   tar xjf $1     ;;
			*.tar.gz)    tar xzf $1     ;;
			*.bz2)       bunzip2 $1     ;;
			*.rar)       unrar e $1     ;;
			*.gz)        gunzip $1      ;;
			*.tar)       tar xf $1      ;;
			*.tbz2)      tar xjf $1     ;;
			*.tgz)       tar xzf $1     ;;
			*.zip)       unzip $1       ;;
			*.Z)         uncompress $1  ;;
			*.7z)        7z x $1        ;;
			*)     echo "'$1' cannot be extracted via extract()" ;;
			 esac
		 else
			 echo "'$1' is not a valid file"
		 fi
	}

#   ---------------------------
#   4.  MAKE GIT BETTER
#   ---------------------------
	alias status='git status'
	alias s='git status'
	alias add='git add'
	alias commit="git commit"
	alias push="git push"
	alias clone="git clone"

#   ---------------------------
#   5.  NETWORKING
#   ---------------------------
	alias myip='curl -4 icanhazip.com; curl -6 icanhazip.com'       # myip:             Public facing IP Address
	alias netCons='lsof -i'                                         # netCons:          Show all open TCP/IP sockets
	alias flushDNS='sudo killall -HUP mDNSResponder'                # flushDNS:         Flush out the DNS Cache
	alias lsock='sudo /usr/sbin/lsof -i -P'                         # lsock:            Display open sockets
	alias lsockU='sudo /usr/sbin/lsof -nP | grep UDP'               # lsockU:           Display only open UDP sockets
	alias lsockT='sudo /usr/sbin/lsof -nP | grep TCP'               # lsockT:           Display only open TCP sockets
	alias ipInfo0='ipconfig getpacket en0'                          # ipInfo0:          Get info on connections for en0
	alias ipInfo1='ipconfig getpacket en1'                          # ipInfo1:          Get info on connections for en1
	alias openPorts='sudo lsof -i | grep LISTEN'                    # openPorts:        All listening connections
	alias showBlocked='sudo ipfw list'                              # showBlocked:      All ipfw rules inc/ blocked IPs

#   ---------------------------------------
#   6.  SYSTEMS OPERATIONS & INFORMATION
#   ---------------------------------------

#   cleanupDS:  Recursively delete .DS_Store files
#   -------------------------------------------------------------------
	alias cleanupDS="find . -type f -name '*.DS_Store' -ls -delete"

	function mkcd {
		if [ ! -n "$1" ]; then
			echo "Enter a directory name"
		elif [ -d $1 ]; then
			echo "\`$1' already exists"
		else
			mkdir $1 && cd $1
		fi
	}

# 	Kopy.io CLI tool || Usage >
# 	echo "Hello World" | kopy
	kopy() {
		a=$(cat);
		curl -X POST -s -d "raw:$a" http://kopy.io/documents | awk -F '"' '{print "http://kopy.io/"$4}';
	}

#   ---------------------------------------
#   Fancy boot info
#   ---------------------------------------
test -e "/usr/local/bin/pyarchey" && "/usr/local/bin/pyarchey" -z
