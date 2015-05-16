---
layout: post
title: "Switch from BBB to RaspberryPI"
date: 2014-10-13 20:27
comments: true
categories: embedded
---
### Background
I have BeagleBone Black and RaspberryPi, both of them are cute board. Previous I use BBB for home server, which holds my own Weather APP website, also serves as a sshd server, dynamic dns server, etc. While Rpi serves like a File server and download server.         
Now I want to use BBB for developing some funny things, that means I will transfer all of the functionalities which runs in BBB to Rpi. Following steps will record what I have done.     
Before start, update all of the software in Rpi(it runs archLinux):    

```
$ sudo pacman -Syu --noconfirm

```
### sshd
Previously the sshd on BeagleBone listens on port 3333, now I have to change it back to 22,     

```
/[root@alarmpi ~]# cat /etc/ssh/sshd_config

#Port 3333
Port 22

```
Restart the service via `systemctl restart sshd`, then you could directly ssh to `10.0.0.230`.     
### DDns
Previous the BBB acts as the Ddns client, thus hold a no-ip.biz based domain name.     
On BBB, because it runs the Debian7.1, so the no-ip2 configuraiton is :    

```
root@arm:/etc# ps -ef | grep noip | grep -v grep
nobody    3184     1  0 Oct07 ?        00:00:01 /usr/local/bin/noip2 -c /usr/local/etc/no-ip2.conf

```
While the configuration file is located at:    

```
root@arm:/etc# cat /etc/rc.local
# By default this script does nothing.
# But we will call noip in this scirpt
/usr/local/bin/noip2 -c /usr/local/etc/no-ip2.conf &

```
So first we should comment this line. Then activate the Rpi's no-ip2.    

The Rpi's configuraiton is using systemd.   
The corresponding configuration file is located at:    

```
[root@alarmpi system]# pwd
/usr/lib/systemd/system
[root@alarmpi system]# cat noip2.service 
[Unit]
Description=No-IP Dynamic DNS Update Client
After=network.target

[Service]
Type=forking
ExecStart=/usr/bin/noip2 -c /etc/no-ip2.conf

[Install]
WantedBy=multi-user.target


```
Simply disable it via:   

```
$ sudo systemctl disable noip2.service

```
### ssh with nopasswd
Make sure all of the configuration is the same in `.ssh/authorized_keys `   
Then you could change the port in router, change the default 22 port from BBB to Rpi.    

Reboot the router, and BBB & Rpi.    
