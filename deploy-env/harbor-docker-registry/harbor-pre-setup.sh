#/bin/bash
# This has no sudo since its supposed to be run as root by the custom script extension of azure
# Shell script to install basic libraries for harbor - https://github.com/goharbor/harbor/blob/master/docs/installation_guide.md
# Python	version 2.7 or higher	Note that you may have to install Python on Linux distributions (Gentoo, Arch) that do not come with a Python interpreter installed by default
# Docker engine	version 1.10 or higher	For installation instructions, please refer to: https://docs.docker.com/engine/installation/
# Docker Compose	version 1.6.0 or higher	For installation instructions, please refer to: https://docs.docker.com/compose/install/
# Openssl	latest is prefered	Generate certificate and keys for Harbor

# updating
echo "Updating and install apt stuff"
apt-get update 
apt -y install \
    python-pip \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

echo "Installed stuff now getting docker gpg"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

echo "Adding right repo for docker ce"

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable" -y

apt-get update 

echo "Installing docker-ce"

apt-get -y install docker-ce

echo "Downloading docker compose"

curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

docker-compose --version

echo "upgrad open ssl"

apt -y upgrade openssl