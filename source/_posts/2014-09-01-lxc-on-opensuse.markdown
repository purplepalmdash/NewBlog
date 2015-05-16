---
layout: post
title: "LXC On OpenSuse"
date: 2014-09-01 09:58
comments: true
categories: lxc
---
### LXC 相关操作
列出本机已有的容器：    

```
# lxc-ls
xxxxxyyySimulator1  xxxxxyyySimulator2

```
开启虚拟机：     

```
# lxc-start -n xxxxxyyySimulator1

```
本机开启终端连接到开启后的虚拟机：    

```
# lxc-console --name xxxxxyyySimulator1

Type <Ctrl+a q> to exit the console, <Ctrl+a Ctrl+a> to enter Ctrl+a itself

Welcome to openSUSE 12.3 "Dartmouth" - Kernel 3.11.10-21-default (tty1).


xxxxxyyySimulator1 login: root
Password: 
Last login: Fri Aug 29 15:40:54 from xxx.xxx.xx.59
Have a lot of fun...
xxxxxyyySimulator1:~ # 

```
用户名和密码都是"root". ctrl+a后按q即可退出该终端。  
 
销毁容器:    

```
lxc-destroy -n XXXXXXXXXX

```

克隆容器:    

```
bash /usr/bin/lxc-clone -o xxxxxyyySimulator1 -n xxxxxyyySimulator2

```
其中-o 是源容器， -n 后接的是目的容器名，目的容器会自动创建。    
### LXC 容器修改
比如，网络配置在下列文件里：    

```
# cat /var/lib/lxc/xxxxxyyySimulator2/config | more
# Template used to create this container: /usr/share/lxc/templates/lxc-opensuse
# Template script checksum (SHA-1): xxxxxxxxxxxxxxxxxxxxxxxxxxxx

#lxc.network.type = empty
lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = br0
lxc.network.name = eth0
lxc.network.ipv4 = xxx.xxx.xx.67/24
lxc.network.ipv4.gateway = xxx.xxx.xx.1

```
network.ipv4代表其IP地址，而Gateway则代表其默认路由。     

虚拟机位置：    

```
linux:/var/lib/lxc # du -hs *
483M	xxxxxyyySimulator1
483M	xxxxxyyySimulator2
linux:/var/lib/lxc # pwd
/var/lib/lxc

```

克隆后的虚拟机也在同一目录下。    

启动后的虚拟机，都可以被视为真实的物理机，可以通过ssh直接连上去操作。
