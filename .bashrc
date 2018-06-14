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

set show-all-if-ambiguous on
set show-all-if-unmodified on


# Python stuff
VIRTUALENVPATH=`which virtualenvwrapper.sh`
if [ -n "$VIRTUALENVPATH" ];
then
    source "$VIRTUALENVPATH"
fi
export PYTHONDONTWRITEBYTECODE=1 # recommended, but not required

if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
        host="[REMOTE]"
fi
# Prompt with git branch
#export PS1='[\[\033[0;35m\]\h\[\033[0;36m\] \w\[\033[00m\]\[\033[33m\]$(parse_git_branch)\[\033[00m\]]\$ '
export PS1='\[\033[0;31m\033[1m\]$host\[\033[00m\][\[\033[0;35m\]\h\[\033[0;36m\] \w\[\033[00m\]\[\033[33m\]$(parse_git_branch)\[\033[00m\]]\$ '

export PATH=$PATH:~/bin/
export PATH=$PATH:/usr/local/lib/node_modules

github() {
    base_url="$(git config --get remote.origin.url | sed -E 's/git@github\.com:([^.]*)(\.git)?/https:\/\/github\.com\/\1/g')"
    url_path=""

    if ! [ -z $1 ] ; then
        branch="$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')"
        case $1 in
            pr)
                url_path="compare/$branch?expand=1"
                ;;
            *)
                if [ -f $1 ] || [ -d $1 ] ; then
                    repo="$(sed -E 's/.*\/(.*)$/\1/' <<< $base_url)"
                    file_path="$(cd $(dirname "$1") && pwd -P)/$(basename "$1")"
                    url_path="tree/$branch/$(sed -E "s/.*\\/$repo\\/(.*)$/\1/" <<< $file_path)"
                fi
                ;;
        esac
    fi

    if ! [ -z $base_url ]; then
        open "$base_url/$url_path"
    fi
}



# -----------------------------------------------------------------
# SOURCING LOCAL .BASHRC
# -----------------------------------------------------------------

if [ -f ~/.bashrc.local ]; then
    source ~/.bashrc.local
fi

alias ipaddress="ipconfig getifaddr en0"

if [ -f ~/Library/Android/sdk/platform-tools/adb ]; then
    PATH=$PATH:~/Library/Android/sdk/platform-tools
fi

# ----
# History settings
# -----
# Avoid duplicates
export HISTCONTROL=ignoredups:erasedups  
# When the shell exits, append to the history file instead of overwriting it
shopt -s histappend

# After each command, append to the history file and reread it
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"
