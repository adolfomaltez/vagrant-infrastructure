#!/bin/bash

echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o wlp0s20f3 -j MASQUERADE
iptables -A INPUT -i vboxnet7 -j ACCEPT
iptables -A INPUT -i wlp0s20f3 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -j ACCEPT
