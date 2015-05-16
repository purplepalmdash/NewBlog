---
layout: post
title: "Wake On LAN"
date: 2014-05-08 15:08
comments: true
categories: Linux
---
See if your equipment support "Wake On LAN" feature:    

```
$ ethtool enp0s25 | grep "Wake"
Cannot get wake-on-lan settings: Operation not permitted

```
If you got this feature, then install wol:

```
$ pacman -S wol

```
Record the mac address of your equipment which you want to wake up, in a living machine, if you want to wake it, simply use following command:   

```
# wol -i HOSTNAME_OR_IP MACADDRESS

```
The next consideration is, how to keep a wake-up equipment 24-hours, I suggest you use BeagleBone or Raspberry PI, or you can research how to use arduino and write your own applications. 
