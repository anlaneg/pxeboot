#! /bin/bash
public_inf=wlx0c82684148d9
private_inf=enp0s31f6
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o $public_inf -j MASQUERADE
iptables -A FORWARD -i $public_inf -o $private_inf -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i $private_inf -o $public_inf -j ACCEPT
