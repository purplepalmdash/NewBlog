---
layout: post
title: "Add vlan to existing machine"
date: 2013-11-26 13:51
comments: true
categories: Linux
---
增加一个VLAN设备：     

```
	$ ip link add link eth0 name eth0.100 type vlan id 100

```
查看增加的VLAN设备详情：

```
	$ ip -d link show eth0.100

```
增加一个IPV4地址：

```
	$ ip addr add 192.168.100.1/24 brd 192.168.100.255 dev eth0.100
	$ ip link set dev eth0.100 up

```
关闭一个VLAN设备：

```
	$ ip link set dev eth0.100 down

```
移除一个VLAN设备: 

```
	$ ip link delete eth0.100

```
