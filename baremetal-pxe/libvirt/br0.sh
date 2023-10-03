#!/bin/bash 
# Create bridge interface for libvirt

brctl addbr br0;
ip link set br0 up;
ip addr del 192.168.31.11/24 dev eno1;
brctl addif br0 eno1;
ip addr add 192.168.31.11/24 dev br0;
ip link set br0 up;
ip route add default via 192.168.31.1
