#!/bin/bash

set -e

sudo xcodebuild -license

if [ ! -f "/usr/local/bin/brew" ]; then
  echo "Install homebrew"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  echo "Already installed homebrew"
fi

brew update

if [ ! -f "/usr/local/bin/ansible" ]; then
  brew install ansible
fi
