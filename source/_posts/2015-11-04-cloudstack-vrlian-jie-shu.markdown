---
layout: post
title: "CloudStack VR连接数"
date: 2015-11-04 10:56:12 +0800
comments: true
categories: 
---
## All-In-One VR性能测试
### 测试环境

#### 硬件
**CPU**: Intel(R) Core(TM) i7-3770 CPU @ 3.40GHz, 四核八线程。   
**内存**: 24 G。    

#### 虚拟机网络
**虚拟机网络**: 新建网段为10.82.89.0/24, DHCP范围设置如下，NAT转发外网:   
![/images/2015_11_04_09_24_37_479x293.jpg](/images/2015_11_04_09_24_37_479x293.jpg) 

#### All-In-One 虚拟机   
**CPU**: 6 Core, Copy Host CPU Configuration。       
**内存**: 8 G。 
**硬盘**: 200 G。 
**系统**: Ubuntu 14.04 x86_64。    
**CloudStack版本**: 4.5.2。   

#### CloudStack环境
**Zone**: Advance Zone(PerfZone)。   
**IP**: 取10.82.89.0/24中DHCP尚未使用的IP地址。      
**测试机模板**: ubuntu64perftest.qcow2(http://192.168.0.79/ubuntu64perftest.qcow2)   
**测试机套餐**: 2 Core, 内存3G。    

#### 拓扑图及说明

![/images/allinone.jpeg](/images/allinone.jpeg)   

IP地址说明:   

**All-In-One**:  10.82.89.89     
**Test Server**: CloudStack实例，NAT后的10.82.89.0/24地址    
**VR**: CloudStack自动分配的10.82.89.0/24地址    
**KVM**: All-In-One上运行的虚拟机，绑定8个IP地址, 10.82.89.11/10.82.89.254~10.82.89.247   

### 测试方法
Test Server上运行一个可支持多用户长时间在线的服务端程序，并可统计同时在线人数，接受外部
客户端发来的服务请求。     

Test Client上运行一个快速发起并保持连接的客户端程序，服务端地址指向Test Server, 服务端
口即Test Server上服务端程序监听的端口。    

单个IP最多支持6万多个活动连接，为了提升单台机器能支持的同时在线人数，需要在Test Client
上同时绑定多个网卡，kvm最多支持8个网卡，60000*8=500000, 单台机可以发起并保持的连接数超
过50万。   

Server端代码下载地址:    
[https://gist.github.com/yongboy/5318930/raw/ccf8dc236da30fcf4f89567d567eaf295b363d47/server.c](https://gist.github.com/yongboy/5318930/raw/ccf8dc236da30fcf4f89567d567eaf295b363d47/server.c)   

Client端代码下载地址:    

[https://gist.github.com/yongboy/5324779/raw/f29c964fcd67fefc3ce66e487a44298ced611cdc/client2.c](https://gist.github.com/yongboy/5324779/raw/f29c964fcd67fefc3ce66e487a44298ced611cdc/client2.c)   


### 打开各节点限制
在All-In-One机器/Test Server/Test Client上，均需要打开以下限制:    

#### 最大文件句柄数

```
# vim /etc/security/limits.conf

* soft nofile 104857
* hard nofile 104857
```

#### 最大文件数限制

```
# vim /etc/sysctl.conf
fs.file-max=1048576
# sudo sysctl -p /etc/sysctl.conf
``` 

#### conntrack最大连接数

```
# vim /etc/sysctl.conf
net.netfilter.nf_conntrack_max = 6553500
# sysctl -p /etc/sysctl.conf
```

#### 可用端口数

```
# vim /etc/sysctl.conf
    net.ipv4.ip_local_port_range= 1024 65535
# sysctl -p /etc/sysctl.conf
```

更改完毕后，需要重新启动机器生效，为了使sysctl的配置每次都生效，可以考虑将命令加到启动
项中。   

### 测试过程
#### 启动Server端：    
Server端启动后将监听服务器端的8000端口：   

![/images/2015_11_04_10_25_54_816x191.jpg](/images/2015_11_04_10_25_54_816x191.jpg)   

#### 启动Client端： 

单机多网卡

在All-In-One机器上，由下面的命令启动qemu实例,则可以得到8块网卡的虚拟机, 内存大小`-m
5120`可以调小，一般1024～2048就够:    

```
$ sudo qemu-system-x86_64 -net nic,model=virtio,macaddr=52:54:00:12:34:56,vlan=1
-net tap,vlan=1 -net nic,model=virtio,macaddr=52:54:00:12:34:57,vlan=2 -net
tap,vlan=2 -net nic,model=virtio,macaddr=52:54:00:12:34:58,vlan=3 -net
tap,vlan=3 -net nic,model=virtio,macaddr=52:54:00:12:34:59,vlan=4 -net
tap,vlan=4 -net nic,model=virtio,macaddr=52:54:00:12:34:60,vlan=5 -net
tap,vlan=5 -net nic,model=virtio,macaddr=52:54:00:12:34:61,vlan=6 -net
tap,vlan=6 -net nic,model=virtio,macaddr=52:54:00:12:34:62,vlan=7 -net
tap,vlan=7 -net nic,model=virtio,macaddr=52:54:00:12:34:63,vlan=8 -net
tap,vlan=8 -hda ./ubuntu64perftest.qcow2 -m 5120 --enable-kvm
```

启动虚拟机后, 在虚拟机里设置地址(默认只从eth0得到dhcp地址):    

```
# cat ./ethernet.sh
ifconfig eth1 up
ifconfig eth1 192.168.1.254
ifconfig eth2 up
ifconfig eth2 192.168.1.253
ifconfig eth3 up
ifconfig eth3 192.168.1.252
ifconfig eth4 up
ifconfig eth4 192.168.1.251
ifconfig eth5 up
ifconfig eth5 192.168.1.250
ifconfig eth6 up
ifconfig eth6 192.168.1.249
ifconfig eth7 up
ifconfig eth7 192.168.1.248
```

客户端中，发起海量连接的脚本:

```
 cat startbomb.sh 
#!/bin/sh
./client2 -h 192.168.1.109 -p 8000 -m 64000 -o
192.168.1.16,192.168.1.254,192.168.1.253,192.168.1.252, 
192.168.1.251,192.168.1.250,192.168.1.249,192.168.1.248
```

调用`./startbomb.sh`即可开始对Server端发起大量在线连接

### 测试截图
这里记录一次完整的VR因为过多连接数造成内存耗尽自动重启的过程。     

在CloudStack的实例上运行server端程序, 此时的输出如下:    

VR的`top`输出:    

![/images/2015_11_02_21_11_06_810x293.jpg](/images/2015_11_02_21_11_06_810x293.jpg)    

Server输出:   

![/images/2015_11_02_21_13_37_788x205.jpg](/images/2015_11_02_21_13_37_788x205.jpg)   

客户端开始发包连接的过程中:    

10W:   

![/images/2015_11_02_21_15_11_794x589.jpg](/images/2015_11_02_21_15_11_794x589.jpg)    

20W:   

![/images/2015_11_02_21_15_53_841x563.jpg](/images/2015_11_02_21_15_53_841x563.jpg)   

30W:   

![/images/2015_11_02_21_16_35_902x622.jpg](/images/2015_11_02_21_16_35_902x622.jpg)   

40W:  

![/images/2015_11_02_21_17_19_869x654.jpg](/images/2015_11_02_21_17_19_869x654.jpg)   

44W, VR轰挂:   

![/images/2015_11_02_21_18_06_813x689.jpg](/images/2015_11_02_21_18_06_813x689.jpg)   

此时查看VR的重启时间:    

![/images/2015_11_02_21_18_56_665x149.jpg](/images/2015_11_02_21_18_56_665x149.jpg)   

可以看到VR启动时间很短，这证明VR由于内存耗尽已经自动重启了。   

### 应对策略

#### 暂时应对
在VR上对每个进/出 虚拟路由器的IP作连接数限制，TCP/UDP都需要设置。ICMP暂时未作限定:   

Iptables规则如下:    

```
-A PREROUTING -i eth0 -p tcp  -m connlimit --connlimit-above 1000 --connlimit-mask 32 
--connlimit-saddr -j DROP
-A PREROUTING -i eth2 -p tcp  -m connlimit --connlimit-above 1000 --connlimit-mask 32
--connlimit-saddr -j DROP
-A PREROUTING -i eth0 -p udp  -m connlimit --connlimit-above 1000 --connlimit-mask 32
--connlimit-saddr -j DROP
-A PREROUTING -i eth2 -p udp  -m connlimit --connlimit-above 1000 --connlimit-mask 32
--connlimit-saddr -j DROP
```

添加完此规则后，Test Server最多可接受1000个同时在线连接。这时在Client端发起大量连接超过
1000的都会被VR的iptables规则链丢弃。    

#### 潜在问题
对于过多过快的攻击性连接，VR匹配iptables会造成VR CPU占用率过高。建议采用硬件防火墙来阻
挡这类
攻击。   

