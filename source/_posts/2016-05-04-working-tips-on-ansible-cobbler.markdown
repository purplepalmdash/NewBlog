---
layout: post
title: "Working Tips On ansible-cobbler"
date: 2016-05-04 15:36:55 +0800
comments: true
categories: Virtualization
---
### Source
The source are downloaded from:    
[https://github.com/signed8bit/ansible-cobbler](https://github.com/signed8bit/ansible-cobbler)    

Git clone it via:    

```
$ git clone https://github.com/signed8bit/ansible-cobbler.git
```
### Test
The test will be done via `vagrant up`, while we met the problem: the cobbler version
in ansible playbooks are too old, thus the command `cobbler get-loaders` won't acts
well. we have to changing to the newest cobbler version which is available in 

[http://cobbler.github.io/](http://cobbler.github.io/)     

### Manually Steps(Ubuntu)
Install the newest cobbler via:    

```
$ wget -qO - http://download.opensuse.org/repositories/home:/libertas-ict:/cobbler26/xUbuntu_14.04/Release.key | sudo apt-key add -
$ sudo add-apt-repository "deb http://download.opensuse.org/repositories/home:/libertas-ict:/cobbler26/xUbuntu_14.04/ ./"
$ sudo apt-get install -y cobbler 
$ cobbler --version
Cobbler 2.6.11
  source: ?, ?
  build time: Sat Jan 23 14:13:42 2016
```
Change Password of the `cobbler`:    

```
Change the password for the 'cobbler' username:
htdigest /etc/cobbler/users.digest "Cobbler" cobbler
```

visit the url of `http://xxx.xxx.xxx.xx/cobbler_web` and you could access the management interface of cobbler.     


### Import CentOS7.2
Import the iso via following command

```
$ sudo mount -t iso9660 -o loop ./CentOS-7-x86_64-Everything-1511.iso /mnt1
$ sudo cobbler import --name=CentOS-7.2 --arch=x86_64 --path=/mnt1
```
Examine the imported iso:    

```
root@cobbler-ubuntu:~# cobbler profile list
   CentOS-7.2-x86_64
root@cobbler-ubuntu:~# cobbler distro list
   CentOS-7.2-x86_64
```

Change the default password of root:    

```
# openssl passwd -1
# vim /etc/cobbler/settings 
- default_password_crypted: "$1$mF86/UHC$WvcIcX2t6crBz2onWxyac."
+ default_password_crypted: "$awegwaegoguoweuouoeh/"
# cobbler sync
# service cobbler restart
# service cobblerd restart

```

### Todo
How to automatically install the mate desktop via kickstart?   

First find out all of the pkgs in group, then add them into the kickstart file?  


### For Making Mate
Steps are listed as following:    

```
# curl http://mirrors.aliyun.com/repo/epel-7.repo>/etc/yum.repos.d/epel-7.repo
# curl http://mirrors.aliyun.com/repo/Centos-7.repo>CentOS-Base.repo
# yum groupinstall "X Window system"
# yum groupinstall "MATE Desktop"
```
Remain the yum cache:    

```
[root@localhost ~]# cat /etc/yum.conf 
[main]
#cachedir=/var/cache/yum/$basearch/$releasever
cachedir=/root/cache/$basearch/$releasever
keepcache=1
```
For setting mate as the default desktop envs:    

```
# systemctl isolate graphical.target
# systemctl set-default graphical.target
```
