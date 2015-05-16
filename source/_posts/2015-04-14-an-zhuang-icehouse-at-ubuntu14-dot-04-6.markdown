---
layout: post
title: "安装Icehouse@Ubuntu14.04(6)"
date: 2015-04-14 11:39
comments: true
categories: virtualization
---
这里我们安装horizon服务，使得我们对OpenStack的管理做到可视化.    
###安装horizon
在Controller节点上，安装需要的包:    

```
root@JunoController:~# apt-get -y install openstack-Trustyboard apache2 libapache2-mod-wsgi memcached python-memcache

```
建议删除ubuntu提供的主题，这个主题会使得一些翻译失效:    

```
root@JunoController:~# apt-get remove --purge openstack-Trustyboard-ubuntu-theme

```
配置DashBoard的本地配置文件:    

```
root@JunoController:~# vim /etc/openstack-Trustyboard/local_settings.py 
    OPENSTACK_HOST = "10.17.17.211"
    TIME_ZONE = "Asia/Shanghai"

```
重新启动服务:    

```
root@JunoController:~# service apache2 restart
root@JunoController:~# service memcached restart

```
访问`http://10.17.17.211/horizon`登入到DashBoard以管理OpenStack.    

### 查看OpenStack版本
节点机器起名错误，应该是IcehouseController/IcehouseCompute/IcehouseNetwork之类，但是这里可以通过以下命令来查看OpenStack安装的版本：    

```
root@JunoController:~# dpkg -l | grep nova-common
ii  nova-common                         1:2014.1.4-0ubuntu2                   all          OpenStack Compute - common files

```
`2014.1.4`就是我们要关注的版本信息，在:    
[https://wiki.openstack.org/wiki/Releases](https://wiki.openstack.org/wiki/Releases)    
可以查到，它属于Icehouse.    
![/images/2015_04_14_11_58_39_490x203.jpg](/images/2015_04_14_11_58_39_490x203.jpg)    
