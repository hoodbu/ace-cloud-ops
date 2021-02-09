#!/bin/bash

# allow Linux access by password 
sudo hostnamectl set-hostname ${name}
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo echo 'ubuntu:${password}' | /usr/sbin/chpasswd
sudo /etc/init.d/ssh restart