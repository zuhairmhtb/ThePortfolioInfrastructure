#!/bin/bash
MY_HOME="/home/ubuntu"
export DEBIAN_FRONTEND=noninteractive
# Install prereqs
apt update
apt install -y python3-pip apt-transport-https ca-certificates curl software-properties-common
# Install docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt install -y docker-ce
# Install docker-compose
su ubuntu -c "mkdir -p $MY_HOME/.local/bin"
su ubuntu -c "pip3 install docker-compose --upgrade --user && chmod 754 $MY_HOME/.local/bin/docker-compose"
usermod -aG docker ubuntu
# Create docker network
docker network create -d bridge my-portfolio-network
# Add PATH
printf "\nexport PATH=\$PATH:$MY_HOME/.local/bin\n" >> $MY_HOME/.bashrc
exit 0