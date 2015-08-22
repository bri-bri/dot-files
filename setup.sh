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

cd ~/

#----------------------------------
# Copying Dotfiles
#----------------------------------
find ./ -regex "\.//\.[^\.g/]*" | while read x; do
    if [ ${$x:0:3} == ".//" ]; then
        dotfile=${$x:3}
    else
        dotfile=$x
    fi
    
    replace_bool=True
    if [ -f ~/$x ]; then
        err "$x exists, do you want to replace it?"
        echo -n "(Y/n) > "
        read confirm
        if [ $confirm != "y" ] && [ $confirm != "Y" ]; then
            replace_bool=False
        fi
    fi

    if replace_bool; then
        scp -r ./$dotfile ~/
    fi


#----------------------------------
# Homebrew
#----------------------------------

notify "Checking homebrew install"
echo "..."

if ! command_exists brew; then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" ;
else
    success "Homebrew installed!\n"
fi

notify "Installing common utilities"
echo "..."

brew install wget
brew install ngrep
brew install htop

success "Done installing utilities!\n"

success "SETUP COMPLETE\n"
