---
layout: post
title: "Add Private NAT Networking In XenServer"
date: 2015-07-06 11:42:00 +0800
comments: true
categories: Virtualization
---
### Create Networking In XenCenter
Create the networking under the XenCenter UI's tab "Networking".     

### Networking Setting
Enable the ip forward:    

```
# vim /etc/sysctl.conf
net.ipv4.ip_forward = 1
# sysctl -p 
# cat /proc/sys/net/ipv4/ip_forward 
1
```
Use iptables for forwarding the network flow:    

```
# iptables -A FORWARD --in-interface xapi0 -j ACCEPT
# iptables --table nat -A POSTROUTING --out-interface eth0 -j MASQUERADE
```
But this didn't bring up the internal networking, after discussing with college, edit the file:     

```
[root@xenserver-WolfHunter ~]# cat /etc/sysconfig/iptables
+++++  *nat
+++++  :PREROUTING ACCEPT [7019:539216]
+++++  :INPUT ACCEPT [77:3825]
+++++  :OUTPUT ACCEPT [104:6495]
+++++  :POSTROUTING ACCEPT [53:3228]
+++++  -A POSTROUTING -o xenbr0 -j MASQUERADE
+++++  COMMIT
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:RH-Firewall-1-INPUT - [0:0]
-A INPUT -j RH-Firewall-1-INPUT
++++ -A FORWARD -i xapi0 -j ACCEPT
-A FORWARD -j RH-Firewall-1-INPUT
-A RH-Firewall-1-INPUT -i lo -j ACCEPT
-A RH-Firewall-1-INPUT -p icmp --icmp-type any -j ACCEPT
# DHCP for host internal networks (CA-6996)
-A RH-Firewall-1-INPUT -p udp -m udp --dport 67 --in-interface xenapi -j ACCEPT
-A RH-Firewall-1-INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
# Linux HA hearbeat (CA-9394)
-A RH-Firewall-1-INPUT -m conntrack --ctstate NEW -m udp -p udp --dport 694 -j ACCEPT
-A RH-Firewall-1-INPUT -m conntrack --ctstate NEW -m tcp -p tcp --dport 22 -j ACCEPT
-A RH-Firewall-1-INPUT -m conntrack --ctstate NEW -m tcp -p tcp --dport 80 -j ACCEPT
-A RH-Firewall-1-INPUT -m conntrack --ctstate NEW -m tcp -p tcp --dport 443 -j ACCEPT
-A RH-Firewall-1-INPUT -j REJECT --reject-with icmp-host-prohibited
COMMIT

```
Restart XenServer and waiting for verification.    
