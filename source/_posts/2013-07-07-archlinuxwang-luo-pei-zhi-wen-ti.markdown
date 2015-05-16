---
layout: post
title: "ArchLinux DHCP配置问题"
date: 2013-07-07 12:10
comments: true
categories: Linux
---
安装完ArchLinux后，发现网卡无法从路由器通过dhcp得到地址，ArchLinux的dhcp客户端是dhcpcd,默认配置文件。路由器型号是TP-link WR340G v5, 2010年入手的。

手动调用dhcpcd时候发现LOG里有NAK消息爆出。

翻了下Arch的论坛，这个问题是由于dhcpcd的参数配置引发的，某些dhcpcd向路由器请求的参数无法得到而导致，个人觉得大约是WR340G版本够老，无法提供这些个参数。

##解决方案一：

编辑/etc/dhcpcd.conf， 注释掉classless_static_routes 和 interface_mtu即可:

```
	# option classless_static_routes
	
	# Respect the network MTU.
	# option interface_mtu
```

而后我们可以用systemd在每次启动的时候自动调用dhcpcd绑定地址:

```
	$ systemctl enable dhcpcd@enp0s25
	$ systemctl start dhcpcd@enp0s25
```

##解决方案二:

安装dhclient:

```
	$ pacman -S dhclient
	$ dhclient enp0s25
```

这种方法需要每次手动输入，不过我们可以使用netctl包来自动管理网络接口信息：

```
	$ cp /etc/netctl/examples/ethernet-dhcp /etc/netctl/ethernet-dhcp
```

由netctl.profile查到指定dhcp客户端的字段，而后在/etc/netctl/ethernet-dhcp文件中添加：

```
	DHCPClient=dhclient
	# !!! 别忘了修改dhcp侦听的设备地址：
	# Interface=eth0
	Interface=enp0s25
```

把ethernet-dhcp作为netctl的默认启动配置文件：

```
	$ netctl enable ethernet-dhcp
```

立即开启netctl:

```
	$ netctl start ethernet-dhcp
```

查看netctl服务运行情况，我的网络是桥接的，和依据上面步骤配出来的字段会有所不同

```
	$ systemctl list-units -t service | grep netctl
	netctl@bridge.service        loaded active exited  Example Bridge connection
```


如果切换了网络环境，例如如果在待机唤醒时处于另一网络中，则需要用下列命令重新配置网络:

```
	$ netctl restart ethernet-dhcp
```

两种方法各有千秋，前者比较灵活，但是遇到复杂网络配置的时候可能会很棘手，譬如多网卡/桥接等模型时容易把人弄晕。后者配置选项很多，但一劳永逸。
