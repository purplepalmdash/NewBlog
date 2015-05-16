---
layout: post
title: "ArchLinux初步配置网络"
date: 2013-07-05 20:21
comments: true
categories: Linux
---
刚安装好的ArchLinux上只有基本的系统组件，启动以后连ifconfig都没有（其实ifconfig早在N年前就被干掉，以ip命令代替了)。在这种一穷二白的情况下，如何配置好网络参数？下面的步骤可以让人一劳永逸。

1\. 查看网络接口信息:  

```
	$ ip link show
	1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT 
	    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
	2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT qlen 1000
	    link/ether 08:00:27:09:fd:b7 brd ff:ff:ff:ff:ff:ff
可以看到enp0s3为有线端口，未启动，无地址无网关无路由。
```

2\. 启动网口：

```
	$ ip link enp0s3 up
```

3\. 配置网卡地址: 

```
	$ ip addr add 192.168.1.133/24 broadcast 192.168.1.255 dev enp0s3
```

参数解释：IP地址: 192.168.1.133, 广播地址:192.168.1.255

4\. 配置默认路由为192.168.1.1:

```
	$ ip default-gateway 192.168.1.1
```

5\. 查看接口信息:

```
	#路由信息
	$ ip route show
	#地址信息
	$ ip addr show
```

6\. 添加dns解析信息:

```
	$ vim /etc/resolv.conf
```

输入ISP提供的dns服务器信息，例如:

```
	nameserver 58.XXX.xx.xx
	nameserver 221.x.x.xx
```

7\. 安装net-tools，这里包含了ifconfig，终于可以不用忍受ip命令的折磨了。但是我记得看过一个高手的文章，他建议使用ip而不是使用陈旧的功能有限的ifconfig，高手开了个玩笑：“记住每次你敲ifconfig时，就会有一只无辜的小猫咪因为偷吃奶酪被击杀，可怜可怜小猫咪吧 :(”。虽然ifconfig很方便也是大多数教程里的常用配置，还是建议大家尽快适应繁琐的ip命令。


```
	$ pacman -S net-tools
```

8\. 安装dhcpcd并加入到系统启动项中:

```
	$ pacman -S dhcpcd
	# 临时启动dhcpcd
	$ systemctl start dhcpcd@enp0s3
	# 将dhcpcd加入到启动项中
	$ systemctl enable dhcpcd@enp0s3
```

现在重启机器，就可以从dhcp服务器自动获取地址并配置dns服务器等信息了。

9\. 其他：

删除当前已经绑定的IP地址：

```
	$ ip addr del 192.168.1.134/32 dev enp0s3
```

若机器处于有防火墙的机器中，则需要配置好proxy信息才能正常使用网络，在命令行下，输入一下命令：

```
	$ export http_proxy=http://ip_address:ip_port
	$ export https_proxy=http://ip_address:ip_port
	$ export ftp_proxy=http://ip_address:ip_port
	$ export ftps_proxy=http://ip_address:ip_port
```
