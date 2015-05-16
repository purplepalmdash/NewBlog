---
layout: post
title: "Using Teamviewer"
date: 2015-01-28 21:02
comments: true
categories: linux
---
### Installation
#### CentOS
Download the corresponding rpm files, install it via `sudo yum install ******.rpm`, this will automatically install the dependencies and also install the teamviewer for your centos system.    
#### Ubuntu
Only working for 14.04:     
First you have to add i686(i386) supporting:    

```
$ dpkg --add-architecture i386
$ apt-get update

```
Then you have to downloaded the following packages rather than the offcial packages(x64 or i386):    
[http://download.teamviewer.com/download/teamviewer_linux.deb](http://download.teamviewer.com/download/teamviewer_linux.deb)     
Install this `teamviewer_linux.deb`, and you got teamviewer running on your system.    
For 12.04, directly download the package from:    
[http://download.teamviewer.com/download/teamviewer_linux_x64.deb](http://download.teamviewer.com/download/teamviewer_linux_x64.deb)    
Then install it via:    

```
# dpkg -i teamviewer_linux_x64.deb
# apt-get install -f

```
Then teamviewer could be installed on your system.    
### Connect Back
First your server side will install the teamviewer and run is as the daemon mode.   


### Tips
Stop the teamviewerd via(On CentOS):    

```
$ sudo teamviewer --daemon stop

```
While start it via:    

```
$ sudo teamviewer --daemon start

```

Seems someone blocked the flow to this site...55555
