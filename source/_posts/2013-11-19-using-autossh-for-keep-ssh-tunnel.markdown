---
layout: post
title: "Using autossh for keep ssh tunnel"
date: 2013-11-19 15:21
comments: true
categories: Linux
---
###Preparation
Install autossh:

```
	$ sudo pacman -S autossh

```
###Configure
[root@DashArch Trusty]# cat /etc/systemd/system/autossh.service

```
	[Unit]
	Description=AutoSSH service for port 1394 access to family machine
	After=network.target
	
	[Service]
	ExecStart=/usr/bin/autossh -M 22000  -N -T -D 1394 root@aaa.aaa.aaa.com
	
	[Install]
	WantedBy=multi-user.target

```
###Usage
Change the proxy to 127.0.0.1, port is 1394, then you can use the ssh tunnel for browsing. 
