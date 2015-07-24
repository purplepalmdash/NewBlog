---
layout: post
title: "Share Mouse between ArchLinux &amp; Yosemite"
date: 2014-11-20 15:02
comments: true
categories: linux
---
### Fixed IP
First configure the IP for Yosemite on router, since the Archlinux takes the 221, Yosemite may use 220 for its fixed ip.     
### ArchLinux Setting
I use ArchLinux as the synergy server, so first install synergy via:    

```
$ sudo pacman -S synergy

```
I want to place Yosemite at the right of the ArchLinux, So just configure the `/etc/hosts` like following.    

```
$ tail /etc/hosts
# For setting Synergy
10.0.0.220      Yosemite.lan            Yosemite

```

Configuration:   

```
[root@kkkkttt kkkt]# cp /etc/synergy.conf.example /etc/synergy.conf

```
For easily configure the synergy, download qsynergy.      

```
$ sudo pacman -S qsynergy

```
![/images/synergyconfigure.jpg](/images/synergyconfigure.jpg)     
Then store its configuration to the `/etc/synergy.conf`.      

Start the server and enable the server.    

```
# systemctl enable synergys@mary
# systemctl start synergys@mary

```
### Yosemite Setting     
Download the SynergyKM from [http://synergykm.com/](http://synergykm.com/), and configure the SynergyKM connected to 10.0.0.221.     
Also you have to check `Start at login`    

Now place the Yosemite at the left of the ArchLinux, your mouse and keyboard could be freely switching from 2 machines.    
