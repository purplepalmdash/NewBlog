---
layout: post
title: "Moving System on 1T Harddisk(3)"
date: 2014-11-22 12:07
comments: true
categories: Linux
---
In fact this series is not only for customization of the surface pro, it becomes the written-tips for what I've installed on my ArchLinux. So later all of the necessary packages installation I will record them here.     

1\. postgres    
Install via:    

```
sudo pacman -S postgresql

```
Start postgresql service:     

```
$ sudo systemctl start postgresql

```
Now begin to configurate the postgres:    

```
$ sudo -i -u postgres
[postgres@kkkttt ~]$ initdb --locale en_US.UTF-8 -E UTF8 -D '/var/lib/postgres/data'
[postgres@kkkttt ~]$ createuser --interactive
Enter name of role to add: kkkt
Shall the new role be a superuser? (y/n) y

```
Test of create temp db via:    

```
[kkkt@/usr/lib/systemd/system]$ createdb kkkttmp    

```

2\. dhclient    
Sometime we really need this dhclient for debugging. Especially when you want to get the specified port address.      

```
sudo pacman -S dhclient 

```

3\.  dnscrypt-proxy    
At most of the times the dns will be pulluted, so need this guy for sending the encrypted quest and get the response the safe DNS provider.    

```
sudo pacman -S  dnscrypt-proxy

```

4\. cmake    
For making some opensource projects:     

```
sudo pacman -S cmake

```

5\. cbatticon    
This little tool is for displaying battery status at the tray, install it via:   

```
sudo pacman -S cbatticon

```
Add it to the singleview/dualview/triview setting files.    

6\. nitrogen   
For setting up different picture at startup.    

```
$ sudo pacman -S nitrogen

```
Add following line into the startup file:    

```
$ nitrogen --restore

```

7\. nmap    
For scannning all of the living machine in the LAN.     

```
sudo pacman -S namp 

```
Scan via:    

```
nmap -sP 192.168.1.*

```

