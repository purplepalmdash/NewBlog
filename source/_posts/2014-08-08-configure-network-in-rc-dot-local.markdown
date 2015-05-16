---
layout: post
title: "Configure Network in rc.local"
date: 2014-08-08 10:23
comments: true
categories: Linux
---
Following is the configuration of the vlan and whole network:   
In rc.local, RHEL.   

```
#!/bin/sh
#
# This script will be executed *after* all the other init scripts.
# You can put your own initialization stuff in here if you don't
# want to do the full Sys V style init stuff.

touch /var/lock/subsys/local

echo VLAN=yes > /etc/sysconfig/network 

/sbin/vconfig add eth1 10
/sbin/vconfig add eth1 11
/sbin/vconfig add eth1 12
/sbin/vconfig add eth1 13
/sbin/vconfig add eth1 30
/sbin/vconfig add eth1 40

/sbin/vconfig add eth1 100
/sbin/vconfig add eth1 110
/sbin/vconfig add eth1 120
/sbin/vconfig add eth1 130
/sbin/vconfig add eth1 200

/sbin/ifconfig eth1.10 172.10.1.55 netmask 255.255.0.0 up
/sbin/ifconfig eth1.10:11 172.10.11.55 netmask 255.255.0.0 up
/sbin/ifconfig eth1.11 172.11.1.55 netmask 255.255.0.0 up
/sbin/ifconfig eth1.12 172.12.1.55 netmask 255.255.0.0 up
/sbin/ifconfig eth1.13 172.13.1.55 netmask 255.255.0.0 up
/sbin/ifconfig eth1.30 172.30.1.55 netmask 255.255.0.0 up
/sbin/ifconfig eth1.30:11 172.30.11.55 netmask 255.255.0.0 up
/sbin/ifconfig eth1.40 172.40.1.55 netmask 255.255.0.0 up

/sbin/ifconfig eth1.100 20.100.1.55 netmask 255.255.0.0 up
/sbin/ifconfig eth1.110 20.110.1.55 netmask 255.255.0.0 up
/sbin/ifconfig eth1.120 20.120.1.55 netmask 255.255.0.0 up
/sbin/ifconfig eth1.130 20.130.1.55 netmask 255.255.0.0 up

/sbin/ifconfig eth1.10 inet6 add fd00::410:172:10:1:88/64
/sbin/ifconfig eth1.10 inet6 add fd00::410:172:10:11:88/64
/sbin/ifconfig eth1.11 inet6 add fd00::411:172:11:1:88/64
/sbin/ifconfig eth1.12 inet6 add fd00::412:172:12:1:88/64
/sbin/ifconfig eth1.13 inet6 add fd00::413:172:13:1:88/64
/sbin/ifconfig eth1.30 inet6 add fd00::430:172:30:1:88/64
/sbin/ifconfig eth1.30 inet6 add fd00::430:172:30:11:88/64
/sbin/ifconfig eth1.40 inet6 add fd00::440:172:40:1:88/64

route add -net 224.0.0.0 netmask 224.0.0.0 dev eth1.40
/sbin/route add default gw 10.9.134.1 dev eth1

echo 1 > /proc/sys/net/ipv4/ip_forward

echo 1 > /proc/sys/net/ipv6/conf/all/forwarding
echo 1 > /proc/sys/net/ipv6/conf/all/mc_forwarding

modprobe sctp

#/etc/init.d/xinetd restart
#/usr/sbin/xinetd -stayalive -pidfile /var/run/xinetd.pid
#echo "nameserver 10.9.133.243" >> /etc/resolv.conf
# Activate eth0 again. 
/sbin/ifconfig eth0 1xx.xx.xxx.xxx netmask 255.255.255.0 up
/sbin/route add default gw 1xx.xx.xxx.1 dev eth0

```

For eth0 will lose configuration, so we add the eth0 again.    
