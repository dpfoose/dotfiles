#!/usr/bin/env bash
# Provision a new Apple OS X machine
# Author Ron. A @0xADADA

cd "$(dirname "${BASH_SOURCE}")"
echo "Updating this repo for latest changes..."
git pull origin master

function init_home() {
    rsync --exclude ".git/" \
        --exclude ".DS_Store" \
        --exclude "bootstrap.sh" \
        --exclude "defaults.sh" \
        --exclude "provision.sh" \
        --exclude "README.md" \
        --exclude "LICENSE-MIT.txt" \
        --exclude "Brewfile" \
        --exclude "Caskfile" \
        --exclude ".osx" \
        -av --no-perms . ~
    source ~/.bash_profile
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
    echo "Initializing home directory dotfiles"
    init_home
else
    read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Initializing home directory dotfiles"
        init_home
    fi
fi
unset init_home

# Install xcode command line toolz
xcode-select --install

# Setup some python development tools
if ! which pip >/dev/null; then
    echo "Installing Pip ..."
    easy_install pip
fi

# call homebrew and homebrew cask scripts (installs NPM, etc)
source brew.sh

# update / install npm packages
# Check for npm
if [ `type -P npm` ]; then
    echo "Installing Node.js packages..."

    # List of npm packages
    packages="node-inspector bower"

    # Install packages globally and quietly
    npm install $packages --global --quiet

    [[ $? ]] && echo "Done"
else
    printf "\n"
    echo "Error: npm not found."
    printf "Aborting... try installing node packages manually\n"
    exit
fi

# Install Node.js
nvm install v5.2

# Install Atom editor packages
if [ `type -P apm` ]; then
    apm install --packages-file .atom/packages.txt
fi

# Setup OSX system defaults
source defaults.sh

# finish up
echo "System defaults have been update, you probably should restart. Bye."
