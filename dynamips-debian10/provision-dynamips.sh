#!/bin/bash
# Minimal CISCO IOS Lab. (virtualbox) on laptop

# Add contrib non-free repos 
sed -i -e 's/main/main contrib non-free/g' /etc/apt/sources.list
apt-get update

# Install dynamips (hypervisor) and utils
apt-get install -y dynamips uml-utilities bridge-utils

# Create bridge on Linux Machine
tunctl -u root -t tap0
tunctl -u root -t tap1
brctl addbr br0
brctl addif br0 eth1
brctl addif br0 tap0
brctl addif br0 tap1
ip link set br0 up
ip link set eth1 up
ip link set tap0 up
ip link set tap1 up

ip addr del 192.168.33.10/24 dev eth1
ip addr add 192.168.33.10/24 dev br0

echo 1 > /proc/sys/net/ipv4/ip_forward
#iptables -t nat -A POSTROUTING -o br0 -j MASQUERADE
