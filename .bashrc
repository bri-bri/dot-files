# -----------------------------------------------------------------
# BASH SPECIFIC SETTINGS
# -----------------------------------------------------------------

source ~/.shellrc

# BASH PROMPT
parse_git_branch() {
	git_branch=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
	if [ $git_branch ]; then
	echo "•$git_branch"
	fi
}

# Prompt with git branch
export PS1='[\[\033[0;35m\]\h\[\033[0;36m\] \w\[\033[00m\]\[\033[33m\]$(parse_git_branch)\[\033[00m\]]\$ '

export PATH=$PATH:~/bin/
# -----------------------------------------------------------------
# SOURCING LOCAL .BASHRC
# -----------------------------------------------------------------

if [ -f ~/.bashrc.local ]; then
    source ~/.bashrc.local
fi
