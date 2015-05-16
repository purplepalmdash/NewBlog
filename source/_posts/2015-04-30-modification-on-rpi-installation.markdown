---
layout: post
title: "Modification SWAP on RPI Installation"
date: 2015-04-30 21:49
comments: true
categories: embedded
---
First disable the swap partition, for it will save your sd card:    
Know where is your swap file:   

```
$ cat /proc/swap*

```
Disable it via change the S to K under `/etc/rcx.d`, and reboot the services:   

```
$ sudo mv S02dphys-swapfile K02dphys-swapfile

```
