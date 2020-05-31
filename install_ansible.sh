#!/bin/sh

sudo yum -y install ansible
sudo cp /etc/ansible/ansible.cfg ~/.ansible.cfg
sudo chown $USER:$USER ~/.ansible.cfg
sed -i -e "s/#log_path = \/var\/log\/ansible\.log/log_path = ~\/ansible\.log/g" ~/.ansible.cfg
