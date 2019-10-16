# Copyright (c) 2018 Ole-Martin Bratteng. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#     1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#
#     2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in
#     the documentation and/or other materials provided with the
#     distribution.
#
#     3. All advertising materials mentioning features or use of this
#     software must display the following acknowledgement: This product
#     includes software developed by Ole-Martin Bratteng.
#
#     4. Neither the name of Ole-Martin Bratteng nor the names of its
#     contributors may be used to endorse or promote products derived
#     from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY OLE-MARTIN BRATTENG "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL OLE-MARTIN BRATTENG LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require "rake"
require "fileutils"

task :default => :install

desc "Install the dotfiles into user's home directory"
task :install do
	install_n
	install_nanorc
	install_git_radar
	install_tmux_tpm
	install_oh_my_zsh
	install_zsh_autosuggestions
	install_zsh_syntax_highlighting
	install_zsh_completions
	switch_to_zsh

	replace_all = false

	# Fixes symbolic link issue later
	if File.exist?(File.join(ENV['HOME'], ".oh-my-zsh"))
		system %Q{mkdir -p "$HOME/.oh-my-zsh/custom/lib/"}
	end

	files = Dir['*'] - %w[Rakefile README LICENSE oh-my-zsh tools]
	files << "oh-my-zsh/custom/lib/misc.zsh"
	files << "oh-my-zsh/custom/themes/clean.zsh-theme"
	files << "oh-my-zsh/custom/plugins/rbates"
	files << "oh-my-zsh/custom/plugins/dotfiles"
	files << "oh-my-zsh/custom/plugins/gpg-agent"
	files << "oh-my-zsh/custom/plugins/codestats"
	files.each do |file|
		next if FileTest.symlink?(File.join(ENV['HOME'], ".#{file}"))

		# handle .local versions; only copy if DNE
		if file.match('\.local$')
			if !File.exist?(File.join(ENV['HOME'], ".#{file}"))
				FileUtils.copy(file, File.join(ENV['HOME'], ".#{file}"))
			end
			next
		end

		# handle normal dotfiles
		if File.exist?(File.join(ENV['HOME'], ".#{file}"))
			if replace_all
				replace_file(file)
			else
				print "Do you want overwrite ~/.#{file}? [ynaq] "
				case $stdin.gets.chomp
				when 'a'
					replace_all = true
					replace_file(file)
				when 'y'
					replace_file(file)
				when 'q'
					exit
				else
					puts "Skipping ~/.#{file}"
				end
			end
		else
			link_file(file)
		end
	end
end

def replace_file(file)
	system %Q{rm -rf "$HOME/.#{file.sub(/\.erb$/, '')}"}
	link_file(file)
end

def link_file(file)
	puts "Linking ~/.#{file} to home directory"
	system %Q{ln -s "$PWD/#{file}" "$HOME/.#{file}"}
end

def command?(command)
	system("which #{ command} > /dev/null 2>&1")
end

def switch_to_zsh
	if ENV["SHELL"] =~ /zsh/
		puts "You are already using zsh".green
	else
		print "Do you want to switch to zsh? (recommended) [ynq] "
		case $stdin.gets.chomp
		when 'y'
			puts "Switching to zsh..."
			system %Q{chsh -s `which zsh`}
		when 'q'
			exit
		else
			puts "Skipping zsh".red
		end
	end
end

def install_oh_my_zsh
	if File.exist?(File.join(ENV['HOME'], ".oh-my-zsh"))
		puts "You are already using oh-my-zsh".green
	else
		print "Do you want to install oh-my-zsh? [ynq] "
		case $stdin.gets.chomp
		when 'y'
			puts "Installing oh-my-zsh..."
			system %Q{git clone https://github.com/robbyrussell/oh-my-zsh.git "$HOME/.oh-my-zsh"}
		when 'q'
			exit
		else
			puts "Skipping oh-my-zsh, you will need to change ~/.zshrc manually".red
		end
	end
end

def install_zsh_autosuggestions
	if File.exist?(File.join(ENV['HOME'], ".oh-my-zsh/custom/plugins/zsh-autosuggestions"))
		puts "You are already using zsh-autosuggestions".green
	else
		print "Do you want to install zsh-autosuggestions? [ynq] "
		case $stdin.gets.chomp
		when 'y'
			puts "Installing zsh-autosuggestions..."
			system %Q{git clone https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"}
		when 'q'
			exit
		else
			puts "Skipping zsh-autosuggestions, you will need to change ~/.zshrc manually".red
		end
	end
end

def install_zsh_syntax_highlighting
	if File.exist?(File.join(ENV['HOME'], ".oh-my-zsh/custom/plugins/zsh-syntax-highlighting"))
		puts "You are already using zsh-syntax-highlighting".green
	else
		print "Do you want to install zsh-syntax-highlighting? [ynq] "
		case $stdin.gets.chomp
		when 'y'
			puts "Installing zsh-syntax-highlighting..."
			system %Q{git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"}
		when 'q'
			exit
		else
			puts "Skipping zsh-syntax-highlighting, you will need to change ~/.zshrc manually".red
		end
	end
end

def install_zsh_completions
	if File.exist?(File.join(ENV['HOME'], ".oh-my-zsh/custom/plugins/zsh-completions"))
		puts "You are already using zsh-completions".green
	else
		print "Do you want to install zsh-completions? [ynq] "
		case $stdin.gets.chomp
		when 'y'
			puts "Installing zsh-completions..."
			system %Q{git clone https://github.com/zsh-users/zsh-completions.git "$HOME/.oh-my-zsh/custom/plugins/zsh-completions"}
		when 'q'
			exit
		else
			puts "Skipping zsh-completions, you will need to change ~/.zshrc manually".red
		end
	end
end

def install_nanorc
	if File.exist?(File.join(ENV['HOME'], ".nano"))
		puts "Found ~/.nano and updates nanorc to latest commit".green
		system %Q{cd $HOME/.nano/; git fetch; git reset --hard origin/master}
		system %Q{cat $HOME/.nano/nanorc >> $HOME/.nanorc}
	else
		print "Install nanorc? [ynq] "
		case $stdin.gets.chomp
		when 'y'
			puts "Installing nanorc..."
			system %Q{git clone https://github.com/scopatz/nanorc.git "$HOME/.nano"}
			system %Q{cat $HOME/.nano/nanorc >> $HOME/.nanorc}
		when 'q'
			exit
		else
			puts "Skipping nanorc, you will need to change ~/.nanorc manually".red
		end
	end
end

def install_git_radar
	if File.exist?(File.join(ENV['HOME'], ".git-radar"))
		puts "Found ~/.git-radar and updates git-radar to latest commit".green
		system %Q{cd $HOME/.git-radar/; git fetch; git reset --hard origin/master}
		puts "Remeber to add .git-radar to your $PATH"
	else
		print "Install git-radar? [ynq] "
		case $stdin.gets.chomp
		when 'y'
			puts "Installing git-radar..."
			system %Q{git clone https://github.com/michaeldfallen/git-radar "$HOME/.git-radar"}
		when 'q'
			exit
		else
			puts "Skipping git-radar, you will need to install ~/.git-radar manually".red
		end
	end
end

def install_n
	if command?("n")
		puts "Found n".green
	else
		print "Install n? [ynq] "
		case $stdin.gets.chomp
		when 'y'
			puts "Installing n..."
			system %Q{git clone https://github.com/tj/n.git}
			system %Q{cd n; make install; cd ..; rm -rf n}
		when 'q'
			exit
		else
			puts "Skipping n, you will need to install n manually".red
		end
	end
end

def install_tmux_tpm
	if File.exist?(File.join(ENV['HOME'], ".tmux/plugins/tpm"))
		puts "Found tmux-tpm and updates tmux-tpm to latest commit".green
		system %Q{cd $HOME/.tmux/plugins/tpm; git fetch; git reset --hard origin/master}
	else
		print "Install tmux-tpm? [ynq] "
		case $stdin.gets.chomp
		when 'y'
			puts "Installing tmux-tpm..."
			system %Q{git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"}
		when 'q'
			exit
		else
			puts "Skipping tmux-tpm, you will need to install ~/.tmux-tpm manually".red
		end
	end
end

class String
	def black;          "\e[30m#{self}\e[0m" end
	def red;            "\e[31m#{self}\e[0m" end
	def green;          "\e[32m#{self}\e[0m" end
	def brown;          "\e[33m#{self}\e[0m" end
	def blue;           "\e[34m#{self}\e[0m" end
	def magenta;        "\e[35m#{self}\e[0m" end
	def cyan;           "\e[36m#{self}\e[0m" end
	def gray;           "\e[37m#{self}\e[0m" end

	def bg_black;       "\e[40m#{self}\e[0m" end
	def bg_red;         "\e[41m#{self}\e[0m" end
	def bg_green;       "\e[42m#{self}\e[0m" end
	def bg_brown;       "\e[43m#{self}\e[0m" end
	def bg_blue;        "\e[44m#{self}\e[0m" end
	def bg_magenta;     "\e[45m#{self}\e[0m" end
	def bg_cyan;        "\e[46m#{self}\e[0m" end
	def bg_gray;        "\e[47m#{self}\e[0m" end

	def bold;           "\e[1m#{self}\e[22m" end
	def italic;         "\e[3m#{self}\e[23m" end
	def underline;      "\e[4m#{self}\e[24m" end
	def blink;          "\e[5m#{self}\e[25m" end
	def reverse_color;  "\e[7m#{self}\e[27m" end
end

module OS
	def OS.windows?
		(/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
	end

	def OS.mac?
		(/darwin/ =~ RUBY_PLATFORM) != nil
	end

	def OS.unix?
		!OS.windows?
	end

	def OS.linux?
		OS.unix? and not OS.mac?
	end

	def OS.jruby?
		RUBY_ENGINE == 'jruby'
	end
end
