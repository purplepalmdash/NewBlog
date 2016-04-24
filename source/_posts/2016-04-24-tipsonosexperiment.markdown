---
layout: post
title: "TipsOnOSExperiment"
date: 2016-04-24 17:32:12 +0800
comments: true
categories: virtualization
---
为了在家里验证一下DevStack的网络配置，组建了一个网络，涉及到的点比较多，以下是
具体记录。

### 交换机配置
前段时间从美国亚马逊买回来一个TP-LINK的千兆交换机一直没用起来，型号是TL-SG108E
，8口可网管交换机。但前面有写过文章可以用来参考:    

[http://purplepalmdash.github.io/blog/2015/12/12/ba-wan-tl-sg108e/](http://purplepalmdash.github.io/blog/2015/12/12/ba-wan-tl-sg108e/)    

但这篇文章里讲的主要还是ovs后虚拟机的vlan，和最近要做的DevStack的FloatIP配置稍
微有点差异。

### 网络规划
家里已有网络192.168.177.0/24, 这个网络是可以访问Internet的。所以DevStack机器上
的eth0将连接到这个网段，并在其上分配floating IP.

另外我们需要创建一个VLAN隔离的private network，用于给DevStack里的虚拟机默认启
动后分配IP地址。将DevStack机器上的eth1连接到此网络。    

### 配置交换机
TP-LINK的DEB-100网卡是比较皮实，奈何win10驱动需要找，随便找了个淘宝9.9包邮的
USB转10兆网卡连上SurfacePro，开始配置交换机。    

步骤:    
打开桌面的`Easy Smart Configuration Utility`，开始自动发现局域网内的交换机，如
下图:    

![/images/2016_04_24_17_58_49.jpg](/images/2016_04_24_17_58_49.jpg)    

需要重新配置下USB有线网卡的IP地址才能连接上交换机:    

![/images/2016_04_24_18_02_45.jpg](/images/2016_04_24_18_02_45.jpg)   

双击发现的交换机，用`admin/admin`登录后的界面如下:    

![/images/2016_04_24_18_08_04.jpg](/iamges/2016_04_24_18_08_04.jpg)    

以前我曾经把这个交换机配置成802.1Q VLAN, 这次基于端口来隔离，所以要配置成`Port
Based VLAN`, 配置完毕后的画面如下:    

![/images/2016_04_24_18_20_36.jpg](/images/2016_04_24_18_20_36.jpg)    

这种基于端口VLAN的验证方法很简单，将上网机和宽带路由器分别插在1～4和5～8口，即
可测试出VLAN被端口隔离。但这好像不是DevStack中需要设置的。    

还是继续配置802.1Q VLAN. 值得注意的是，如果之前配置端口VLAN时将SurfacePro的连
接和交换机网段隔离了，那可能会连接不上，换回同一VLAN即可连接上。    

配置vlan100如以下图所示:    

![/images/2016_04_24_19_51_15.jpg](/images/2016_04_24_19_51_15.jpg)   

### 测试VLAN
将两台PC连接在5~8口上，VLAN100。     

PC1, ArchLinux, Systemd配置VLAN:    

```
$ cat enp0s25.100.network
[Match]
Name=enp0s25.100

[Network]
DNS=192.168.2.1
Address=192.168.2.1/24
$ cat enp0s25.100.netdev 
[NetDev]
Name=enp0s25.100
Kind=vlan

[VLAN]
Id=100

[Network]
DNS=192.168.2.1
Address=192.168.2.1/24
Gateway=192.168.2.1
$ pwd
/etc/systemd/network
```
重新启动PC1后，`192.168.2.1`将成为VLAN100口的地址。作为`192.168.2.1`,我们在这
个端口上启动dhcp服务及路由转发等服务。   

```
$ sudo pacman -S dhcp
$ sudo systemctl enable dhcpd4.service
``` 

干掉冗余的默认dhcpd.conf文件，写一个最小的配置文件:    

```
$ sudo vim /etc/dhcpd.conf.example 
$ sudo vim /etc/dhcpd.conf         
option domain-name-servers 180.76.76.76,223.5.5.5;
option subnet-mask 255.255.255.0;
option routers 192.168.2.1;
subnet 192.168.2.0 netmask 255.255.255.0 {
  range 192.168.2.150 192.168.2.250;

  host macbookpro{
   hardware ethernet 70:56:81:22:33:44;
   fixed-address 192.168.2.199;
  }
}
```

开启dhcpd服务:    

```
$ sudo systemctl start dhcpd4.service
```

PC2, 用openvswitch的vlan配置, libvirt的XML配置如下:    

```
    <interface type='bridge'>
      <mac address='52:54:00:fd:03:e9'/>
      <source bridge='ovsbr0'/>
      <vlan trunk='yes'>
        <tag id='100' nativeMode='untagged'/>
      </vlan>
      <virtualport type='openvswitch'>
        <parameters interfaceid='fb3e7f34-6fcd-41dc-8fed-c3ffe0d54b18'/>
      </virtualport>
```
测试，即启动PC2上的虚拟机，若虚拟机能获得IP地址，则说明VLAN配置成功。   

### DevStack网络配置
操作系统为Ubuntu14.04, 网卡为eth0(192.168.177.100)和eth1(vlan 100) 
