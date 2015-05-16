---
layout: post
title: "使用Fuel部署OpenContrail(1)"
date: 2015-04-22 20:01
comments: true
categories: Virtualization
---
最近在做OpenContrail的解耦合操作，因为官方提供的OpenContrail一键安装包里诸多组件都是用的默认的推荐，通过解耦合可以做到更灵活的安装和配置，有利于更方便的部署和后续的维护。所以这一系列文章是关于如何用Fuel在部署完OpenStack的基础上完成OpenContrail的部署。     
### 先决条件
先决条件主要是用于准备用于部署的硬件环境和软件包。   
硬件环境:     
i5-4460(3.2GHz/4核/6M三级缓存), 32G 内存。    
系统:    
Ubuntu 14.04 LTS    
软件:     

```
$ sudo apt-get install libvirtd virt-manager

``` 
从Miranti网站下载： MirantisOpenStack-6.0.iso    
从Contrail网站下载: contrail-install-packages_2.0-22~icehouse_all.deb    
contrail-neutron-plugin仓库:     

```
git clone https://github.com/Juniper/contrail-neutron-plugin.git

```
### CPU/内存/磁盘规划
需要构建一共8台虚拟机用于在部署好的Mirantis OpenStack上集成OpenContrail. CPU/内存/磁盘规划如下:    
1台Mirantis Fuel控制节点机,2核,划分3G内存, 100G磁盘。
3个OpenStack Controller节点, 2核,各划分3G内存, 100G磁盘。     
1个OpenStack Compute节点，2核(嵌套虚拟化),划分3G内存, 100G磁盘。     
3个OpenContrail节点，2核,各划分4G内存, 100G磁盘。    
一共需要27G内存。磁盘格式为qcow2，实际占用远小于这个数，各个节点最大也就是在5G左右大小。   
其中，关于嵌套虚拟化的CPU设置，如下图, 记得选择Copy host CPU Configuration:     
![/images/2015_04_27_12_20_40_598x372.jpg](/images/2015_04_27_12_20_40_598x372.jpg)     
启用嵌套虚拟化需要在BIOS设置，并添加相应的内核模块。     
### 网络规划
Fuel OpenStack规划了5个网络，分别是:     
Admin(PXE)    
Public     
Management     
Storage     
Private    

我们在Virt-Manager里也同样创建出这样的五个子网:    
Admin(PXE) -- FuelNAT  -- 10.20.0.0/24     
Public -- FuelPublic  -- 172.16.0.0/24    
Management -- FuelMgmt -- 10.55.55.0/24    
Storage  -- FuelStorage -- 10.66.66.0/24    
Private  -- FuelPrivate -- 10.77.77.0/24    

创建网络的步骤如下，双击Virtual Machine Manager里的localhost(QEMU), 弹出下面的窗口:    
![/images/2015_04_27_14_57_37_499x379.jpg](/images/2015_04_27_14_57_37_499x379.jpg)    
点击网络列表最下面的+号,弹出创建网络的窗口:    
![/images/2015_04_27_14_58_52_543x374.jpg](/images/2015_04_27_14_58_52_543x374.jpg)    
命名该网络，点击下一步:    
![/images/2015_04_27_15_00_34_549x371.jpg](/images/2015_04_27_15_00_34_549x371.jpg)    
禁用DHCP:    
![/images/2015_04_27_16_37_32_544x374.jpg](/images/2015_04_27_16_37_32_544x374.jpg)    
选择isolated网络模式:    
![/images/2015_04_27_16_38_34_551x375.jpg](/images/2015_04_27_16_38_34_551x375.jpg)    
接着点击下一步直到完成，这样我们的网络就创建好了。    
用上面的方法创建出以上5个子网。    
### 各个节点网络配置
Miranti Fuel Node: 仅FuelNAT, 安装完毕后，自动指定地址为10.20.0.2.      
其他所有节点机，在创建时，把五个网络都添加上，添加方法如下:    
Details -> Add Hardware -> Network, 而后选择:        
![/images/2015_04_27_16_45_34_765x444.jpg](/images/2015_04_27_16_45_34_765x444.jpg)    
### Miranti Fuel Node安装
安装很简单，直接用下载的MirantisOpenStack-6.0.iso作为安装光盘，在创建出来的虚拟机里安装系统。安装完毕后，在Host机器的浏览器里访问     
[http://10.20.0.2:8000](http://10.20.0.2:8000)      
输入用户名密码都为admin后，登录，可以看到以下界面:      
![/images/2015_04_27_16_55_29_717x477.jpg](/images/2015_04_27_16_55_29_717x477.jpg)    
在这个界面里我们可以进行OpenStack环境的准备、部署、配置、销毁等操作。    


到这一步，我们已经完成了Miranti Fuel Node的安装，基本的部署准备工作已经完成，接下来我们将使用Fuel来部署一个可用的OpenStack环境, 以及三台用于部署Contrail的节点机.    
