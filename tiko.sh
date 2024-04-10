#!/bin/bash

if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
    setenforce 0
fi

yum install -y iptables iptables-services

systemctl stop firewalld
systemctl disable firewalld
systemctl start iptables
systemctl enable iptables

iptables -F
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -A INPUT -s 43.139.0.34 -p tcp -j ACCEPT
iptables -A OUTPUT -s 43.139.0.34 -p tcp -j ACCEPT
iptables -I OUTPUT -p tcp --dport 9000 -m string --string "tkserver.6600.org" --algo bm -j ACCEPT
iptables -I INPUT -p tcp --dport 9000 -m string --string "tkserver.6600.org" --algo bm -j ACCEPT
iptables -I INPUT -p tcp -m string --string "tiktokcdn" --algo bm -j DROP
iptables -I INPUT -p tcp -m string --string "pull-" --algo bm -j DROP
iptables -I INPUT -p tcp -m string --string "gecko" --algo bm -j ACCEPT
iptables -I OUTPUT -p tcp -m string --string "gecko" --algo bm -j ACCEPT
iptables-save > /etc/sysconfig/iptables
