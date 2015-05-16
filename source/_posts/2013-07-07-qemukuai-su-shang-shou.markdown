---
layout: post
title: "Qemu快速上手"
date: 2013-07-07 15:19
comments: true
categories: Linux Virtualization
---
1\. 安装Qemu

ArchLinux的仓库里包含有qemu已编译好的包:

```
	$ pacman -Ss qemu
	extra/qemu 1.4.2-2 [installed]
	    A generic and open source processor emulator which achieves a good \
	emulation speed by using dynamic translation.
	$ pacman -S qemu
```

会根据默认配置安装好几乎所有平台支持的Qemu.

或者你可以手动下载源码包进行编译:官方下载地址在[http://wiki.qemu.org/Download](http://wiki.qemu.org/Download)

安装完qemu后运行qemu-system-i386, 如果弹出窗口，则说明qemu安装正确。

2\. 创建新虚拟机磁盘镜像

创建虚拟机的第一步是创建一个新的磁盘镜像，qemu提供了对多种磁盘镜像格式的支持，如raw、qcow2、qed、vdi等，qemu-img的帮助里介绍qcow2是最多才多艺(Versatile)的格式，支持压缩、加密等功能，还能最大程度节省磁盘空间。我们选择它来做磁盘镜像(Virtualbox可以直接读取qcow2格式的虚拟机镜像)。

```
	$ qemu-img create -f qcow2 ubuntu.qcow2 16G
	Formatting 'ubuntu.qcow2', fmt=qcow2 size=17179869184 encryption=off \
	cluster_size=65536 lazy_refcounts=off 
```

3\. 启动并安装虚拟机:

```
	$ qemu-system-i386 -hda ubuntu.qcow2 -boot d -cdrom \
	./ubuntu-13.04-desktop-i386.iso -m 1024 -enable-kvm
```

-boot d代表优先从光驱启动，对应的选项有a, b (软驱 1 和 2), c (硬盘优先), d (光盘优先), n-p(支持Etherboot的网卡1-4).

安装ubuntu的步骤很直观，这里就不用篇幅描述了。安装完毕后，使用下列命令启动安装好的虚拟机镜像

```
	$ qemu-system-i386 -hda ubuntu.qcow2 -m 1024 -enable-kvm
```

4\. 配置虚拟机网络：

4\.1 使用桥接网络

这种方法需要改动系统配置，使用bridge-utils来创建虚拟网卡和实际网卡之间的桥接。

```
	$ pacman -Ss bridge-utils
	core/bridge-utils 1.5-2
	    Utilities for configuring the Linux ethernet bridge
	$ pacman -S bridge-utils
```

创建桥接设备(br0)

```
	$ modprobe bridge
	$ brctl addbr br0
```

出现add bridge failed: Package not installed时的解决方法：

```
	$ brctl addbr br0
	add bridge failed: Package not installed
	# 查看kernel中关于bridge配置选项
	$ zcat /proc/config.gz | grep CONFIG_BRIDGE=
	CONFIG_BRIDGE=m
	# 查看是否存在ko文件
	$ ls /usr/lib/modules/`uname -r`/kernel/net/bridge
	bridge.ko.gz  netfilter
	# 加载bridge内核模块
	$ modprobe bridge
	# 检查内核模块是否被加载
	$ lsmod | grep ^bridge
	bridge                 93187  0 
```

若modprobe bridge后lsmod看不到bridge模块，有可能是因为更新完系统安装到新的kernel version后没有重启，ArchLinux是一个非常激进的发行版，内核往往几天一升级，习惯休眠或长期不关机的用户可能会碰到这个问题。

检查bridge网络

```
	$ brctl show br0
	bridge name	bridge id		STP enabled	interfaces
	br0		8000.000000000000	no
```

关于STP:
Spanning Tree Protocol (STP) is a Layer 2 protocol that runs on bridges and
switches. The specification for STP is IEEE 802.1D. The main purpose of STP is
to ensure that you do not create loops when you have redundant paths in your
network. Loops are deadly to a network.
生成树协议运行于bridge或交换机上，主要目的为确保在存在冗余路径时网络中不会生成回路，回路会造成网络的死循环。

用下列命令查看网口信息, 或者ifconfig -a直接查看也可:

```
	$ ifconfig -s | awk '{print $1}' | grep -v "Iface\|lo"
	enp0s25
```

将enp0s25加入到br0

```
	$ /sbin/ifconfig enp0s25 down
	$ /sbin/ifconfig enp0s25 0.0.0.0 promisc up
	$ brctl addif br0 enp0s25
	$ dhcpcd br0
```

查看bridge端口信息,发现enp0s25已经被加入了br0：

```
	$ brctl show br0
	bridge name	bridge id		STP enabled	interfaces
	br0		8000.c8cbb8b48913	no		enp0s25
```

有关bridge网络的dhcp相关配置，可以参考[ArchLinux网络配置问题](http://Tomcat.no-ip.biz/blog/2013/07/07/archlinuxwang-luo-pei-zhi-wen-ti/)。


创建qemu启动脚本:

```
	$ vim /etc/qemu-ifup
	#!/bin/sh
	  
	echo "Executing /etc/qemu-ifup"
	echo "Bringing up $1 for bridged mode..."
	sudo /usr/bin/ip link set $1 up promisc on
	echo "Adding $1 to br0..."
	sudo /usr/bin/brctl addif br0 $1
	sleep 2
```

更改脚本权限：

```
	$ chmod 750 /etc/qemu-ifup 
	$ chown -R root /etc/qemu-ifup 
	$ chgrp kvm /etc/qemu-ifup 
```

创建qemu结束脚本

```
	$ vim /etc/qemu-ifdown
	#!/bin/sh
	 
	echo "Executing /etc/qemu-ifdown"
	sudo /usr/bin/ip link set $1 down
	sudo /usr/bin/brctl delif br0 $1
	sudo /usr/bin/ip link delete dev $1
```

更改脚本权限:

```
	$ chmod 750 /etc/qemu-ifdown 
	$ chown -R root /etc/qemu-ifdown 
	$ chgrp kvm /etc/qemu-ifdown 
```

添加当前用户到kvm用户组并在visudo中开放对应命令的权限：

```
	$ usermod -a -G kvm Trusty
	$ visudo
	Cmnd_Alias      QEMU=/usr/bin/ip,/usr/bin/modprobe,/usr/bin/brctl
	%kvm     ALL=NOPASSWD: QEMU
```

建立run-qemu文件，并添加到系统路径中.

```
	$ vim /bin/run-qemu
	#!/bin/bash
	USERID=`whoami`
	precreationg=$(/usr/bin/ip tuntap list | /usr/bin/cut -d: -f1 | /usr/bin/sort)
	sudo /usr/bin/ip tuntap add user $USERID mode tap
	postcreation=$(/usr/bin/ip tuntap list | /usr/bin/cut -d: -f1 | /usr/bin/sort)
	IFACE=$(comm -13 <(echo "$precreationg") <(echo "$postcreation"))
	
	# This line creates a random mac address. The downside is the dhcp server will
	assign a different ip each time
	printf -v macaddr "52:54:%02x:%02x:%02x:%02x" $(( $RANDOM & 0xff)) $(( $RANDOM &
	0xff )) $(( $RANDOM & 0xff)) $(( $RANDOM & 0xff ))
	# Instead, uncomment and edit this line to set an static mac address. The
	benefit is that the dhcp server will assign the same ip.
	# macaddr='52:54:be:36:42:a9'
	  
	qemu-system-i386 -enable-kvm -net nic,macaddr=$macaddr -net tap,ifname="$IFACE"
	$*
	  
	sudo ip link set dev $IFACE down &> /dev/null
	sudo ip tuntap del $IFACE mode tap &> /dev/null 
	$ sudo chmod a+w /bin/run-qemu
```

使用下列命令来运行qemu

```
	$ /bin/run-qemu -hda ./ubuntu.qcow2 -m 1024 -vga std
```

运行多个run-qemu实例后的网络信息如下：

```
	$ ifconfig -s
	Iface      MTU    RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR TX-DRP TX-OVR Flg
	br0       1500    70676      0      0 0         64334      0      0      0 BMRU
	enp0s25   1500   103814      0      0 0         75661      0      0      0 BMPRU
	lo       65536      983      0      0 0           983      0      0      0 LRU
	tap0      1500        3      0      0 0            11      0      0      0 BMPRU
	tap1      1500        3      0      0 0            11      0      0      0 BMPRU
```

	
4\.2 使用VDE(Virtual Distrubuted Ethernet)创建Qemu网络，这种方法无需改变系统配置。

有关VDE的配置可以参考前面写过的[在CentOS上安装基于Qemu的虚拟机](http://Tomcat.no-ip.biz/blog/2013/07/04/zai-centosshang-an-zhuang-ji-yu-qemude-xu-ni-ji/)一文。

值得注意的是, vdeswitch和slirpvde都可以在ArchLinux的软件库中找到:

```
	$ pacman -Ss vde
	extra/vde2 2.3.2-4 [installed]
	    Virtual Distributed Ethernet for emulators like qemu
```

使用VDE创建的网络对外是不可见的，它使用由slirpvde分配的dhcp地址，通常以10.0.0开头，VDE配置的网络也可以在VirtualBox中看到，VirtualBox中关于NAT的网络配置就是基于VDE的。
