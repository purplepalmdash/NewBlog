---
layout: post
title: "使用Fuel部署OpenContrail(3)"
date: 2015-04-27 18:56
comments: true
categories: Virtualization
---
在OpenStack HA部署好的基础上集成OpenContrail是一个比较繁琐的过程，所以这一节里我们主要做集成前的准备工作，准备网络拓扑和创建好OpenContrail本地部署仓库。    
### 网络规划
在Miranti提供的集成参考里，有如下的图，定义了整个环境的网络拓扑。    
![images/2015_04_27_19_06_11_1147x804.jpg](/images/2015_04_27_19_06_11_1147x804.jpg)   
从图中可以看到各个节点所接入到的物理网络。我们根据这些节点接入网络的不同，来定义对应系统上的网络配置。    
在安装完毕后的虚拟机里，可以看到该节点的DNS名称，例如node-19, node-20之类，在Fuel Controller上可以通过`ssh root@node-19`来登入相应角色的机器上。    
以下是三个OpenStack节点的网络部署, N/A代表不需要配置，可以直接把对应的接口文件删除:    
对应的接口分别是从eth0 ~ eth4.   

OS1: node-19, PXE:10.20.0.14, Public: 172.16.0.6, Management: 10.55.55.6, Storage: 10.66.66.5, Private: N/A.     
OS2: node-20, PXE:10.20.0.15, Public: 172.16.0.7, Management: 10.55.55.7, Storage: 10.66.66.6, Private: N/A.     
OS3: node-22, PXE:10.20.0.16, Public: 172.16.0.8, Management: 10.55.55.8, Storage: 10.66.66.7, Private: N/A.     

Compute: node-18, PXE: 10.20.0.13, Public: 172.16.0.5, Management: 10.55.55.5, Storage: 10.66.66.4, Private: N/A.    

Contrail1: node-24, PXE: 10.20.0.10, Public: N/A, Management: N/A, Storage: N/A, Private: 10.77.77.10
Contrail2: node-21, PXE: 10.20.0.11, Public: N/A, Management: N/A, Storage: N/A, Private: 10.77.77.11
Contrail3: node-23, PXE: 10.20.0.12, Public: N/A, Management: N/A, Storage: N/A, Private: 10.77.77.12

OpenStack和Compute各个节点的配置是自动配置好的，Contrail节点上的Private节点则需要手动配置，具体步骤如下:    

```
root@node-24:~# vim /etc/network/interfaces.d/ifcfg-eth4 
auto eth4
iface eth4 inet static

address 10.77.77.10
netmask 255.255.255.0
gateway 10.77.77.1

post-up  ethtool  -K  eth4  gso off  gro off || true

```
删除三个Contrail Controller节点上的未用端口, 并重启后得到我们要的配置:    

```
root@node-24:~# rm -f /etc/network/interfaces.d/ifcfg-eth3 
root@node-24:~# rm -f /etc/network/interfaces.d/ifcfg-eth2
root@node-24:~# rm -f /etc/network/interfaces.d/ifcfg-eth1 

```
到这里，我们节点机的网络单机就配置完毕了。

### 网间互通
我们需要让Management网络和Private网络可以通过某种途径互相连通，这里为了部署的方便，直接在主机(Host机器)上用iptables加上以下规则：    

```
# iptables -D FORWARD -i virbr5 -j REJECT --reject-with icmp-port-unreachable
# iptables -D FORWARD -o virbr5 -j REJECT --reject-with icmp-port-unreachable
# iptables -D FORWARD -o virbr3 -j REJECT --reject-with icmp-port-unreachable
# iptables -D FORWARD -i virbr3 -j REJECT --reject-with icmp-port-unreachable
# iptables -t nat -A POSTROUTING -s 10.55.55.0/24 -d 10.77.77.0/24 -j MASQUERADE
# iptables -t nat -A POSTROUTING -s 10.77.77.0/24 -d 10.55.55.0/24 -j MASQUERADE

```
值得注意的是，virbr5和virbr3就是10.55.55.0/24和10.77.77.0/24所附属的网口，具体可以在Virt-Manager的配置菜单里看到。     
添加完毕后，在OpenStack的节点(OS1,OS2,OS3)ping Private网络里的地址，如`ping 10.77.77.10`, 确保可以ping通；在Contrail Controller的节点(Contrail1, Contrail2, Contrail3)上ping Management网络里的地址，如10.55.55.6，确保可以ping通。   
集成OpenContrail的一个先决条件是Private网络和Management网络可以互通。   

### OpenContrail安装仓库准备
我们在Fuel Controller上建立OpenContrail的安装仓库，这样有利于快速部署， 具体的操作是从Juniper官方提供的deb包里释出OpenContrail安装所需要的包，形成一个本地仓库。具体步骤如下:    

```
# yum -y install dpkg-devel
# cd ~/Deb
# mkdir -p /var/www/nailgun/contrail
# mv /root/contrail-install-packages_2.0-22~icehouse_all.deb  ./
# ar vx contrail-install-packages_2.0-22~icehouse_all.deb
# rm -f contrail-install-packages_2.0-22~icehouse_all.deb 
# tar xf data.tar.gz
# tar xf opt/contrail/contrail_packages/contrail_debs.tgz -C /var/www/nailgun/contrail
# cd /var/www/nailgun/contrail
# dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz
# rm -rf ~/Deb

``` 
这时候如果在本机上访问    
[http://10.20.0.2:8080/contrail/](http://10.20.0.2:8080/contrail/)    
就可以看到整个仓库的包列表及详情。这个仓库将在后面部署Contrail时被用到。        
