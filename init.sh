#!/bin/bash

set -e

# enable eprl
dnf config-manager --set-enabled crb
dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
sudo dnf install git ansible-core -y

# install ansible-galaxy collection
chmod +x ./command/main.sh
./command/main.sh

ansible-playbook playbook.yaml -K
