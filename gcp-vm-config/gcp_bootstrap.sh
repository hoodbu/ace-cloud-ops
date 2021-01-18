#!/bin/bash

# allow linuix access by password 
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo echo 'ubuntu:Password123!' | /usr/sbin/chpasswd
sudo /etc/init.d/ssh restart