---
layout: post
title: "安装Icehouse@Ubuntu14.04(1)"
date: 2015-04-13 11:29
comments: true
categories: Virtualization
---
项目的需要，手动基于多台Ubuntu虚拟机部署OpenStack Icehouse, 然后在部署好的Icehouse的基础上，部署OpenContrail, 最终达到OpenContrail解耦的过程。    
### 环境准备
物理机: i7-3770/24G Memory/CentOS 6.6     
软件: virt-manager/qemu等    
节点机(虚拟机):    
节点机1: 控制节点(JunoController), 2 CPU+3G内存+单网卡(管理网络,10.17.17.211).    
节点机2: 网络节点(JunoNetwork), 1 CPU+1G内存+3 网卡(管理网络:10.17.17.212, GRE Tunnel网络:10.19.19.212, 外部网络:10.22.22.212).    
节点机3: 计算节点(JunoCompute), 2 CPU(Nested)+2G内存+2 网卡(管理网络:10.17.17.213, GRE Tunnel网络:10.19.19.213).    
网络配置:    
Virt-manager里需要配置三个网络，一个是管理网络10.17.17.0/24, 另一个GRE Tunnel网络10.19.19.0/24, 外部网络为10.22.22.0/24.    
参考资料:    
不错的指南文件:[http://godleon.github.io/blog/2015/02/10/install-openstack-juno-in-ubuntu-basic-environment-setting/](http://godleon.github.io/blog/2015/02/10/install-openstack-juno-in-ubuntu-basic-environment-setting/)    
官方文档:[http://docs.openstack.org/icehouse/install-guide/install/apt/content/](http://docs.openstack.org/icehouse/install-guide/install/apt/content/)        

### 虚拟机准备
用以下命令创建三台虚拟机的磁盘，而后按照上面的节点机配置完毕后，启动三台虚拟机。    

```
# pwd
/home/juju/img/OpenStack
# qemu-img create -f qcow2 -b ./UbuntuBase1404.qcow2 JunoController.qcow2
# qemu-img create -f qcow2 -b ./UbuntuBase1404.qcow2 JunoNetwork.qcow2
# qemu-img create -f qcow2 -b ./UbuntuBase1404.qcow2 JunoCompute.qcow2

```
更改节点机的/etc/hostname文件，更改各自的名字为JunoController, JunoNetwork和JunoCompute.    
每台机器的/etc/network/interfaces文件配置如下:    
JunoController:    

```
# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet static
address 10.17.17.211
netmask 255.255.255.0
gateway 10.17.17.1
dns-nameservers 114.114.114.114

```
JunoNetwork:    

```
# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
# auto eth0
# iface eth0 inet dhcp

# The primary network interface
auto eth0
iface eth0 inet static
address 10.17.17.212
netmask 255.255.255.0
#gateway 10.17.17.1
dns-nameservers 114.114.114.114

# Network, have the tunnel, which locates at the 10.19.19.0/24
auto eth1
iface eth1 inet static
address 10.19.19.212
netmask 255.255.255.0
up route add -net 10.19.19.0/24 dev eth1

# Directly to internet, used for ovs
auto eth2
iface eth2 inet dhcp

```
JunoCompute:    

```
# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet static
address 10.17.17.213
netmask 255.255.255.0
gateway 10.17.17.1
dns-nameservers 114.114.114.114

# Network, have the tunnel, which locates at the 10.19.19.0/24
auto eth1
iface eth1 inet static
address 10.19.19.213
netmask 255.255.255.0
up route add -net 10.19.19.0/24 dev eth1

```
把下列条目添加到各台节点机的 /etc/hosts文件中:     

```
10.17.17.211    JunoController
10.17.17.212    JunoNetwork
10.17.17.213    JunoCompute

```
### NTP服务部署
#### NTP 服务器
使用NTP来保证各个节点之间的时间同步，对后续加入的各个节点，同样需要使用NTP来同步该节点时间。我们将JunoController作为NTP服务器,在JunoController上，安装和配置NTP服务器：     

```
root@JunoController:~# apt-get -y install ntp
root@JunoController:~# vim /etc/ntp.conf
    # 修改成大陆时间
    server 2.cn.pool.ntp.org
    server 1.asia.pool.ntp.org
    server 2.asia.pool.ntp.org
    # 修改 restrict 設定
    restrict -4 default kod notrap nomodify
    restrict -6 default kod notrap nomodify
root@JunoController:~# service ntp restart

```
#### NTP客户端
其他的节点上都需要安装NTP客户端并使用NTP服务器时间同步。    

```
# apt-get -y install ntp
# vim /etc/ntp.conf
    # 設定 controller 為參照的 time server
    # 並將其他 server 開頭的設定進行註解
    server 10.17.17.211 iburst
# service ntp restart

```
检查结果是否正确:     

```
root@JunoNetwork:~# ntpq -c peers
     remote           refid      st t when poll reach   delay   offset  jitter
==============================================================================
 JunoController  59.106.180.168   3 u    1   64    1    0.239  447024.   0.049

```
### 添加软件仓库
官方文档中说icehouse已经在14.04的官方仓库中了，所以下面的步骤并不是必须的。     
在所有节点上，执行以下操作:    

```
# apt-get install python-software-properties
# add-apt-repository cloud-archive:icehouse
# apt-get update && apt-get -y dist-upgrade && reboot

```
### 安装/配置数据库
OpenStack需要一个数据库用于存储相关数据，一般情况下采用MySQL. "你问我支持不支持MySQL？我说不支持，我就明确告诉你，你们呀，我感觉你们开源界也要学习，你们非常熟悉MYSQL被Oracle这一套的，你们毕竟是Too Young，明白这意思吗？"----所以装一个MariaDB来代替它.    

```
root@JunoController:~# apt-get -y install mariadb-server python-mysqldb
root@JunoController:~# vim /etc/mysql/my.cnf 
    [mysqld]
    # 修改 bind-address 設定
    bind-address = 10.17.17.211
    
    # 加入以下 UTF-8 的相關設定
    default-storage-engine = innodb
    innodb_file_per_table
    collation-server = utf8_general_ci
    init-connect = 'SET NAMES utf8'
    character-set-server = utf8

```
重启服务:    

```
root@JunoController:~# service mysql restart

```
### 安装消息服务器
同样在控制节点上安装，OpenStack使用rabbitmq作为消息服务器：     

```
root@JunoController:~# apt-get install -y rabbitmq-server

```
修改初始化guest密码:    

```
root@JunoController:~# rabbitmqctl change_password guest RABBITMQ_PASSWD

```
第一部分跑完，这里我们完成了OpenStack创建的基本设定，接下来就可以挨个搭建OpenStack的服务了。     
