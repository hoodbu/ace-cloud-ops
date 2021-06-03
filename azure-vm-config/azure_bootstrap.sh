#!/bin/bash

sudo hostnamectl set-hostname ${name}
sudo apt update -y
sudo apt upgrade -y

#install test packages
sudo apt-get -y install traceroute unzip build-essential git gcc hping3 chrony apache2
sudo apt autoremove

git clone https://github.com/Microsoft/ntttcp-for-linux
cd ntttcp-for-linux/src
make; make install

cp ntttcp /usr/local/bin/
