---
layout: post
title: "Install xampp on ArchLinux"
date: 2014-04-18 16:49
comments: true
categories: 
---
Install xampp in ArchLinux via:    

```
	yaourt xampp
	pacman -U xampp-1.8.1-1-x86_64.pkg.tar.xz 

```
Stop and disable the previous installed service:     

```
	systemctl stop httpd.service
	systemctl stop mysqld
	systemctl stop vsftpd
	systemctl disable httpd.service
	systemctl disable mysqld
	systemctl disable vsftpd

```
Start the xampp via:

```
	/opt/lampp/lampp start

```
Other commands: start/restart/stop.     
