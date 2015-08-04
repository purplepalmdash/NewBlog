---
layout: post
title: "Tips On Using SpaceWalker For Deploying CentOS7"
date: 2015-08-04 15:57:47 +0800
comments: true
categories: Virtualization
---
### Configuration
After SpaceWalker has been setup, the configuration we need to done is listed as
following:    

```
In /etc/rhn/rhn.conf change the value of the parameter cobbler.host to the ip address of the spacewalk server.
In /etc/cobbler/settings change the value of the parameters server and redhat_management_server to the ip-address of the spacewalk server.
```
Install cobbler bootloaders via:    

```
# yum install -y cobbler-loaders
```
