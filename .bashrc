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

# Key Bindings
stty werase undef
bind '\C-w:backward-kill-word'
bind -r '\C-k'
bind '\C-k:kill-word'
bind -r '\C-i'
bind '\C-i:end-of-line'

# Prompt with git branch
export PS1='[\[\033[0;35m\]\h\[\033[0;36m\] \w\[\033[00m\]\[\033[33m\]$(parse_git_branch)\[\033[00m\]]\$ '

export PATH=$PATH:~/bin/
# -----------------------------------------------------------------
# SOURCING LOCAL .BASHRC
# -----------------------------------------------------------------

if [ -f ~/.bashrc.local ]; then
    source ~/.bashrc.local
fi
