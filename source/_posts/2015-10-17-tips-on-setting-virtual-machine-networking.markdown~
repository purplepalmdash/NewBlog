---
layout: post
title: "Tips On Setting Virtual Machine Networking"
date: 2015-10-17 08:11:29 +0800
comments: true
categories: Virtualization
---
### 目的
主要涉及到CloudStack的网络模型，最近在搭建一个环境时有诸多不了解，索性开始做实
验，在虚拟机里验证虚拟机的网络模型。    

### 环境准备
内存 16G 的嵌套虚拟机一台，安装`Ubuntu 14.04 x86_64`版本。 安装完毕后，开启桌
面环境Xubuntu，及安装virt-manager等常用的管理虚拟机的组件。    

网络配置如下:    

```
$ sudo vim /etc/network/interfaces
    # The loopback network interface
    auto lo
    iface lo inet loopback
    
    # The primary network interface
    auto eth0
    iface eth0 inet manual
    
    auto br0
    iface br0 inet dhcp
    bridge_ports eth0
    
    auto isolationbr
    iface isolationbr inet static
    bridge_ports none
    bridge_fd 5
    bridge_stp off
    bridge_maxwait 1
    address 172.16.0.1
    netmask 255.255.0.0
```
这里我们将eth0桥接到br0，并建立一个物理上隔绝的网桥isolationbr, 手动配置其地址
为172.16.0.1/16。    

开启嵌套虚拟机的内核包转发功能:    

```
# vim /etc/sysctl.conf
net.ipv4.ip_forward=1
# sysctl -w net.ipv4.ip_forward=1
# reboot
```
重启后验证内核包转发功能:    

```
# cat /proc/sys/net/ipv4/ip_forward 
1
# sysctl -p
net.ipv4.ip_forward = 1
```

### 验证网桥1
用已经创建好的qcow2文件创建一台虚拟机，选择网络配置如下：    

![/images/2015_10_17_08_47_08_808x488.jpg](/images/2015_10_17_08_47_08_808x488.jpg)    

注意我们将虚拟机的第一块网卡桥接到我们刚才创建的isolationbr网桥上，当然这时候
虚拟机启动时是没有IP地址的，我们手动配置如下:    

```
$ sudo vim /etc/network/interfaces
    # The primary network interface
    auto eth0
    iface eth0 inet static
    address 172.16.0.2
    netmask 255.255.0.0
    gateway 172.16.0.1
```
重新启动虚拟机后，我们可以ping通嵌套虚拟机`172.16.0.1`但是无法ping通局域网内其
他机器。    

### 验证转发
在嵌套虚拟机上，打开iptables的转发规则即可实现创建出的虚拟机与Internet的连接:    

```
# iptables -t nat -A POSTROUTING -s 172.16.0.0/16 ! -d 172.16.0.0/16 -j
MASQUERADE
```

虚拟机上，ping外网地址:    

```
$ ping 223.5.5.5
PING 223.5.5.5 (223.5.5.5) 56(84) bytes of data.
64 bytes from 223.5.5.5: icmp_seq=1 ttl=50 time=37.1 ms
64 bytes from 223.5.5.5: icmp_seq=2 ttl=50 time=35.4 ms
64 bytes from 223.5.5.5: icmp_seq=3 ttl=50 time=35.6 ms
```

### 存储转发规则
Ubuntu14.04可以用下列命令将iptables设置的规则永久保存，每次开机启动:    

```
# iptables-save>/etc/iptables.rules
# vim /etc/network/interfaces
	pre-up iptables-restore < /etc/iptables.rules
```
这样在重启宿主机后，我们设置的转发规则依然生效。    

如果需要动态配置IP地址，则启动嵌套虚拟机端的dhcpd或者dnsmasq服务即可。    
