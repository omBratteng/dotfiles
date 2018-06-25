# Copyright (c) 2018, Ole-Martin Bratteng
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the <organization> nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
require "rake"
require "fileutils"

task :default => :install

desc "Install the dotfiles into user's home directory"
task :install do
	install_nanorc
	install_oh_my_zsh
	install_zsh_syntax_highlighting
	switch_to_zsh

	replace_all = false

	files = Dir['*'] - %w[Rakefile README LICENSE oh-my-zsh]
	files << "oh-my-zsh/custom/themes/clean.zsh-theme"
	files << "oh-my-zsh/custom/plugins/rbates"
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

def switch_to_zsh
	if ENV["SHELL"] =~ /zsh/
		puts "You are already using zsh"
	else
		print "Do you want to switch to zsh? (recommended) [ynq] "
		case $stdin.gets.chomp
		when 'y'
			puts "Switching to zsh..."
			system %Q{chsh -s `which zsh`}
		when 'q'
			exit
		else
			puts "Skipping zsh"
		end
	end
end

def install_oh_my_zsh
	if File.exist?(File.join(ENV['HOME'], ".oh-my-zsh"))
		puts "You are already using oh-my-zsh"
	else
		print "Do you want to install oh-my-zsh? [ynq] "
		case $stdin.gets.chomp
		when 'y'
			puts "Installing oh-my-zsh..."
			system %Q{git clone https://github.com/robbyrussell/oh-my-zsh.git "$HOME/.oh-my-zsh"}
		when 'q'
			exit
		else
			puts "Skipping oh-my-zsh, you will need to change ~/.zshrc manually"
		end
	end
end

def install_zsh_syntax_highlighting
	if File.exist?(File.join(ENV['HOME'], ".oh-my-zsh/custom/plugins/zsh-syntax-highlighting"))
		puts "You are already using zsh syntax highlighting"
	else
		print "Do you want to install zsh-syntax-highlighting? [ynq] "
		case $stdin.gets.chomp
		when 'y'
			puts "Installing zsh-syntax-highlighting..."
			system %Q{git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"}
		when 'q'
			exit
		else
			puts "Skipping zsh-syntax-highlighting, you will need to change ~/.zshrc manually"
		end
	end
end

def install_nanorc
	if File.exist?(File.join(ENV['HOME'], ".nano"))
		puts "Found ~/.nano and updates nanorc to latest commit"
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
			puts "Skipping nanorc, you will need to change ~/.nanorc manually"
		end
	end
end
