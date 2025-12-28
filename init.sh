#!/bin/bash

set -e

# enable eprl
dnf config-manager --set-enabled crb
dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
sudo dnf install git ansible-core -y

ansible-playbook playbook.yaml -K
