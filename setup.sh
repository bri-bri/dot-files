#!/bin/bash

command_exists () {
    type "$1" &> /dev/null
}

notify () {
    echo -e "\033[1m$1\033[0m"
}

err () {
    echo -e "\033[31m$1\033[0m"
}

success() {
    echo -e "\033[1m\033[32m$1\033[0m"
}

#----------------------------------
# Git & Github Setup
#----------------------------------

working_dir="$(pwd)"

notify "Checking git config."
echo "..."

if ! command_exists git; then
    err "Install Mac OSX command line dev tools before continuing"
    exit 1
fi

if [ -z "$(git config --global user.email)" ]; then
    echo "What is your github email?"
    echo -n "> "
    read email
    git config --global user.email "$email"
fi

if [ -z "$(git config --global user.name)" ]; then
    echo "What is your full name?"
    echo -n "> "
    read name
    git config --global user.name "$name"
fi

if [ -z "$(git config --global core.excludesfile)" ]; then
    git config --global core.excludesfile ~/.config/git/ignore
fi

github_response="$(ssh -o "StrictHostKeyChecking no" -T git@github.com 2>&1)"
case "$github_response" in
    *"Permission denied"*)
        cd ~/.ssh
        new_key=True
        keys="$(find ./ -name *.pub)"
        if ! [ -z $keys ]; then
            echo "Keys: $keys";
            notify "Enter a key from above to use for github (without the .pub extension), or blank to generate a new one:"
            echo -n "(filename or blank) > "
            read filename
            if [ ! -z $file ] && [ ! -z "$(find ./ -name \"$filename\")" ]; then
                new_key=False
            fi
        fi
        if $new_key; then
            notify "Generate a new ssh key for github?"
            echo -n "(Y/n) > "
            read confirm
            if [ ! $confirm == "Y" ] && [ ! $confirm == "y" ]; then
                new_key=False 
                err "Skipping Github authentication.\n"
            fi
        fi

        if $new_key; then
            notify "Enter key name (no extension)"
            echo -n "> "
            read filename
            if [ -z $filename ]; then
                filename="github"
            fi
            email="$(git config --global user.email)"
            ssh-keygen -t rsa -f "$filename" -b 4096 -C "$email"
            ssh-add ./$filename
            pbcopy < "$filename.pub"
        fi
        
        publickey="$(cat ./$filename.pub)"
        echo -e "\n$publickey\n" 

        notify "Please copy the key above (which is already added to your clipboard and saved in ~/.ssh/$filename.pub) to github.com."
        echo -n "Are you done adding the key on github? (Y/n) > "
        read confirmation
        success "SSH Key added to Github!\n" 
        ;;
    *"successful"*)
        success "You have access to Github!\n"
        ;;
    *)
        err "Unknown response from SSH'ing to Github:"
        echo -e "$github_response\n"
esac

cd $working_dir

#----------------------------------
# Copying Dotfiles
#----------------------------------

notify "Copying dotfiles"
echo "..."

notify "Symlink dotfiles to the current repo?"
echo -n "(Y-Symlink, n-copy) > "
read should_symlink

if [ ! $should_symlink == "y" ] && [ ! $should_symlink == "Y" ]; then
    should_symlink=False
else
    should_symlink=True
fi

mkdir -p ~/old_dotfiles

case "$working_dir" in
    *"dot-files"*)
        ;;
    *)
        err "Cloning dot-files git repo"
        git clone git@github.com:bri-bri/dot-files.git && cd dot-files
esac

for x in $(find ./ -regex "\.//\.[^/]*" ! -path "*.git*"); do
    if [ "${x:0:3}" == ".//" ]; then
        dotfile=${x:3}
    else
        dotfile=$x
    fi
    
    should_replace=True
    file_exists=False
    if [ -f ~/$dotfile ] || [ -d ~/$dotfile ]; then
        file_exists=True
        err "$dotfile exists, do you want to replace it?"
        echo -n "(Y/n) > "
        read confirm
        if [ ! $confirm == "y" ] && [ ! $confirm == "Y" ]; then
            should_replace=False
        fi
    fi

    if $should_replace; then
        if $file_exists; then
            if ! [ -L ~/$dotfile ]; then
                scp -r ~/$dotfile ~/old_dotfiles/
            fi
            rm -r ~/$dotfile
        fi
        if $should_symlink; then
            ln -sf "$(pwd)/$dotfile" "$HOME/$dotfile"
            if ! [ -z $XDG_CONFIG_HOME ] && [ "${dotfile:0:7}" == ".config" ]; then
                rm -r $XDG_CONFIG_HOME
                ln -sf "$(pwd)/$dotfile" "$XDG_CONFIG_HOME"
            fi
            echo "export DOTFILES_CONFIG_DIR=$(pwd)" > ~/.dotfiles_config
        else
            scp -r "./$dotfile" ~/
            if ! [ -z $XDG_CONFIG_HOME ] && [ "${dotfile:0:7}" == ".config" ]; then
                rm -r $XDG_CONFIG_HOME
                mkdir -p $XDG_CONFIG_HOME
                scp -r ./$dotfile/* "$XDG_CONFIG_HOME/"
            fi
        fi
    fi
done

ln -sf "$(pwd)/$dotfile/bin" "$HOME/$bin";
success "Dotfiles copied!\n"

#----------------------------------
# Homebrew
#----------------------------------

# Quit now if it's not Mac
if ! [ "$(uname)" == "Darwin" ]; then
    success "SETUP COMPLETE\n"
    exit 0
fi

notify "Checking homebrew install"
echo "..."

if ! command_exists brew; then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" ;
else
    success "Homebrew installed!\n"
fi

notify "Installing cask"
command brew tap caskroom/cask
command brew install caskroom/cask/brew-cask
command brew tap caskroom/versions

notify "Installing common utilities"
echo "..."

command brew install $(<brew_packages.txt)
command brew cask install $(<cask_apps.txt)

success "Done installing utilities!\n"

#----------------------------------
# Python Stuff
#----------------------------------

notify "Installing pip and python packages"
echo "..."

brew install wget
if ! command_exists pip; then
    wget https://bootstrap.pypa.io/get-pip.py 
    python get-pip.py
    rm get-pip.py
fi

sudo chmod -R 0777 /Library

pip install -Ur python_packages.txt
success "Done installing python stuff!\n"

success "SETUP COMPLETE\n"
