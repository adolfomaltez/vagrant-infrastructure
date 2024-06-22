#!/bin/bash

# Install frr
sudo apt-get update
sudo apt-get -y install frr

# Enable bgpd
sudo sed -i -e 's/bgpd=no/bgpd=yes/g' /etc/frr/daemons

# Restart frr
sudo systemctl enable frr
sudo systemctl restart frr
