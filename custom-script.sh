#!/usr/bin/env bash

set -eux

# Accept the Oracle Java 8 license agreement in advance to avoid requiring
# user interaction during the setup. https://askubuntu.com/questions/190582/installing-java-automatically-with-silent-option
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections

# Possible fix for bug that prevents apt-transport-https from being installed
sudo systemctl start NetworkManager

sudo apt-get install -y -q apt-transport-https ca-certificates curl software-properties-common

# Get the Google Chrome package
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list

# Prep for installing Docker.
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Prep for installing Java 8
sudo add-apt-repository -y ppa:webupd8team/java

# Prep for installing the Atom text editor
sudo add-apt-repository -y ppa:webupd8team/atom

# Make sure everything is up to date, including system updates.
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y

# Now actually do all the installs
sudo apt-get install -y -q oracle-java8-installer
sudo apt-get install -y -q oracle-java8-set-default
sudo apt-get install -y -q docker-ce
sudo apt-get install -y -q google-chrome-stable
sudo apt-get install -y -q atom
sudo apt-get install -y -q git

# Remove LibreOffice apps
sudo apt-get remove -y --purge libreoffice*

sudo apt-get clean -y
sudo apt-get autoremove -y
