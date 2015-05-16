---
layout: post
title: "Prison-Break For Something"
date: 2015-02-03 04:02
comments: true
categories: linux
---
I've worked two days on prison-break something, this will greatly improve my working efficiency. There are so many steps for recording, so I will detailed described them in following parts.     
### Single MOde
In Single Mode you could get an terminal with root then you could do anything you want, simply pass `init=/bin/bash` in Grub then you could do anything.     
Question: why Unix-like system enable this command?    
Answer: In Unix-like systems, init is the first process to be run, and the ultimate ancestor of all processes ever run. It's responsible for running all the init scripts.    
We could add sudo users, with sudo users, you could get more priviledges.    
### privoxy
This fantanstic software could let you setup your own proxy server, simply compile it and let it run under user `root`, after it starts up, a proxy which listens on 8118 will be available for using.    
### System Upgrade
!!!Notice!!!: Always keep at least 2 root loginned terminal alive, thus if any problem happens you could do debugging.   
Since you have the privoxy for using proxy, you could do anything you want, you could upgrade system from default 11.3 to the latest 13.2. The reference URLs are listed as following:     
Upgrade from 11.3 to 12.3:    
[https://zh.opensuse.org/SDB:%E7%B3%BB%E7%BB%9F%E5%8D%87%E7%BA%A7](https://zh.opensuse.org/SDB:%E7%B3%BB%E7%BB%9F%E5%8D%87%E7%BA%A7)    
Main tips:    

```
$ sudo zypper addrepo --check --name 'openSUSE-11.3-Update' http://download.opensuse.org/update/11.3/repo-update
$ sudo zypper ref && zypper update
$ sudo reboot
.....
$ sudo zypper mr -da
$ sudo zypper ar -f http://download.openSUSE.org/distribution/12.3/repo/oss/ openSUSE:12.3:OSS
$ sudo zypper ar -f http://download.openSUSE.org/distribution/12.3/repo/non-oss/ openSUSE:12.3:NON-OSS
$ sudo zypper addlock liblzma0
$ sudo zypper dup --download "in-advance"
$ sudo shutdown -hP now                                                                                                                       

```                                                                                                                                           
Upgrade from 11.3 to 12.3 won't cause any problems, and on my machine the new system become available for using immediately.                  
Upgrade from 12.3 to 13.2:    
[https://en.opensuse.org/SDB:System_upgrade](https://en.opensuse.org/SDB:System_upgrade)    
Main tips:    

```
$ sudo zypper addrepo --check --name 'openSUSE-12.3-Update' http://download.opensuse.org/update/12.3/repo-update
$ sudo zypper ref && zypper update
$ sudo reboot
.....
$ sudo zypper mr -da
$ sudo zypper ar -f http://download.openSUSE.org/distribution/13.2/repo/oss/ openSUSE:13.2:OSS
$ sudo zypper ar -f http://download.openSUSE.org/distribution/13.2/repo/non-oss/ openSUSE:13.2:NON-OSS
$ sudo zypper addlock liblzma0
$ sudo zypper dup --download "in-advance"
$ sudo shutdown -hP now

```
Trouble shooting:     
1\. When upgrading the system, zypper will halt(hang) at following packages:    
zypper dup locks up Bug #802525. Workaround: make sure to keep a root shell open while zypper dup is running. Run "killall dbus-send" when zypper dup hangs at rtkit.    
[https://en.opensuse.org/openSUSE:Most_annoying_bugs_13.1_dev](https://en.opensuse.org/openSUSE:Most_annoying_bugs_13.1_dev)     
2\. tuned installation got stuck:    

```
$ ps -ef | grep tuned
$ kill tunned
$ ps -ef | grep rpm 
$ kill greped_rpm_install

```
### Route
References:    
[http://w.gdu.me/wiki/Linux/iptables_forward_internetshare.html](http://w.gdu.me/wiki/Linux/iptables_forward_internetshare.html)    
First in the middleware machine, add following rules in iptables:    

```
# iptables -P FORWARD ALLOW
# iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
# iptables -t nat -A POSTROUTING -s 10.1.1.0/24 -j SNAT --to 60.1.1.1
# iptables -A FORWARD -s 10.1.1.9 -j ACCEPT

```
Now you could use this middle machine for acrossing something.     
But, in your own machine, should use the following command for deleting the routes and add new routes:    

```
# route del default gw xxx.xxx.xxx.xxx
# route add default gw xxx.xxx.xxx.xxx

```
There are also some complicated commands for holding the routes, but we could also edit the following files:    

```
# pwd
/etc/sysconfig/network
linux:/etc/sysconfig/network # cat routes 
default xxx.xx.xxx.xxx - - 
any net xxx.xx.0.0 netmask 255.255.0.0 gw xxx.xxx.xxx.200

```
Now even if you reboot the machine, the default route and the exchange route will be also added into the system.    
### More Safer
Change the opensshd listenning port.    
More and more.   
