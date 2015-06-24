---
layout: post
title: "Install Newest Version Of Cobbler"
date: 2015-06-24 09:38:50 +0800
comments: true
categories: Virtualization
---
### Background
Cobbler has changed its homepage from `www.cobblerd.org` to `http://cobbler.github.io/`, thus some configuration will be be failed. In order to solve these problems, we have to upgrade to the newest version, current newest version is `2.6.9`.    

### Download And Install
Go to [http://cobbler.github.io/downloads/2.6.x.html](http://cobbler.github.io/downloads/2.6.x.html) for selecting your distribution, and download them to your folder. Mine is configured via:     

```
$ wget http://download.opensuse.org/repositories/home:/libertas-ict:/cobbler26/CentOS_CentOS-6/home:libertas-ict:cobbler26.repo
$ cp home\:libertas-ict\:cobbler26.repo /etc/yum.repos.d/cobbler26.repo
$ yum install -y cobbler cobbler-web
```

### Configuration
After installation, configure your newest cobbler via:     

```
$ cobbler sync
$ reboot
$ cobbler signature update
```
By updating the signature of the cobbler, the newest system will be supported, like Ubuntu15.04, etc.   
