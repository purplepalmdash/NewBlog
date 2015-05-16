---
layout: post
title: "Get Alive Machine In LAN"
date: 2014-12-29 14:17
comments: true
categories: linux
---
For searching all of the alive machine in the LAN, we could use nmap for searching.    
Install the nmap via:    

```
sudo pacman -S nmap

```
Scan the lan for living host:     

```
# nmap -sP 10.0.0.*

Starting Nmap 6.47 ( http://nmap.org ) at 2014-12-29 14:25 CST
Nmap scan report for www.routerlogin.com (10.0.0.1)
Host is up (0.00040s latency).
MAC Address: xxx.xxx.xxx.xxx(xxx), 
Nmap scan report for 10.0.0.20
Host is up (0.00019s latency).
MAC Address: xxx.xxx.xxx.xxx(xxx), 

```
Via this command we could easily detect which machine is living in the LAN.     

