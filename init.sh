#!/bin/bash

sudo apt update
sudo apt full-upgrade -y

# Установка Certbot
sudo apt install -y software-properties-common
sudo apt install -y certbot

# Установка Docker
sudo apt install -y apt-transport-https ca-certificates curl
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y docker-ce
sudo apt install -y make

# Перезагрузка Docker
sudo systemctl restart docker

