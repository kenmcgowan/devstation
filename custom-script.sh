#!/usr/bin/env bash

set -eux

################################################################################
# Initial Setup & Configuration
################################################################################

# Accept the Oracle Java 8 license agreement in advance to avoid requiring
# user interaction during the setup. https://askubuntu.com/questions/190582/installing-java-automatically-with-silent-option
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections

# Possible fix for bug that prevents apt-transport-https from being installed
sudo systemctl start NetworkManager

sudo apt-get install -y -q apt-transport-https ca-certificates curl software-properties-common

################################################################################
# Downloads & Repo Updates
################################################################################

# Get the Google Chrome package
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list

# Prep for installing Docker.
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Prep for installing Java 8
sudo add-apt-repository -y ppa:webupd8team/java

# Prep for installing .NET Core 2
sudo apt-get install -y -q libunwind8 liblttng-ust0 libcurl3 libssl1.0.0 libuuid1 libkrb5-3 zlib1g libicu57
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-artful-prod artful main" > /etc/apt/sources.list.d/dotnetdev.list'

# Prep for installing sbt
echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823

# Prep for installing the Atom text editor
sudo add-apt-repository -y ppa:webupd8team/atom

# Prep for installing VS Code
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

################################################################################
# Update apt repos
################################################################################

# Make sure everything is up to date, including system updates.
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y

################################################################################
# apt installs
################################################################################
sudo apt-get install -y -q docker-ce
sudo apt-get install -y -q dotnet-sdk-2.1.4
sudo apt-get install -y -q oracle-java8-installer
sudo apt-get install -y -q oracle-java8-set-default
sudo apt-get install -y -q sbt
sudo apt-get install -y -q nodejs
sudo apt-get install -y -q npm
sudo apt-get install -y -q google-chrome-stable
sudo apt-get install -y -q atom
sudo apt-get install -y -q code
sudo apt-get install -y -q git

################################################################################
# NPM installs
################################################################################

sudo npm install -g create-react-app

################################################################################
# Post-Install Initializations
################################################################################

# Trigger download of sbt libraries in advance so it's all ready to go the
# first time we use it.
sbt exit

################################################################################
# Cruft removal
################################################################################

# Remove LibreOffice apps
sudo apt-get remove -y --purge libreoffice*


################################################################################
# System Cleanup
################################################################################
sudo apt-get clean -y
sudo apt-get autoremove -y
