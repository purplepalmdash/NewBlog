---
layout: post
title: "Setup A More intelligent OpenWRT Router"
date: 2015-05-14 21:01
comments: true
categories: Firewall
---

### Openssh-Server
The default sshd is provided by dropbear, the functionality is not good, so I have to replace it with openssh-server.    

```
root@OpenWrt:~# uci set dropbear.@dropbear[0].Port=2222
root@OpenWrt:~# uci commit dropbear
root@OpenWrt:~# /etc/init.d/dropbear restart
root@OpenWrt:~# opkg install openssh-server
root@OpenWrt:~# opkg install openssh-client

```
Configure the OpenSSH:    

```
# /etc/init.d/sshd enable
# /etc/init.d/sshd start
# /etc/init.d/dropbear disable
# /etc/init.d/dropbear stop

```
The next time you login will ask you for changing your password, do it and continue for using ssh.    
### ShadowSocks and DNS
For ShadowSocks you could refer to my previous blogs.   
DNS Server is for automatically analyze the dns in server, install it via:    

```
$ sudo yum install dnsmasq

```
Configure it to another port rather than the default 53.     

```
redsocks 翻墙

```
