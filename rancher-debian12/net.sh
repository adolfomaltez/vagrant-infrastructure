#!/bin/bash
# Adding static routes to Harvester networks (this need to be fixed implementing routing)


ip route add 192.168.11.0/24 via 192.168.31.1
ip route add 192.168.100.0/24 via 192.168.31.1
ip route add 192.168.101.0/24 via 192.168.31.1
ip route add 192.168.102.0/24 via 192.168.31.1
ip route add 192.168.103.0/24 via 192.168.31.1
ip route add 192.168.104.0/24 via 192.168.31.1
ip route add 192.168.105.0/24 via 192.168.31.1