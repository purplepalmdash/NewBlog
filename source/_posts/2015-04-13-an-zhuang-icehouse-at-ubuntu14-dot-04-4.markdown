---
layout: post
title: "安装Icehouse@Ubuntu14.04(4)"
date: 2015-04-13 17:34
comments: true
categories: virtualization
---
这里将配置计算节点。计算节点我们使用了一台2G内存的虚拟机，并使用了嵌套虚拟化，可以通过`lscpu`来看到CPU的VMX/VT-X标志都已经被下发到虚拟机中。    
### 数据库准备
使用下列命令来创建nova所需数据库:     

```
root@JunoController:~# mysql -u root -p
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 35
Server version: 5.5.41-MariaDB-1ubuntu0.14.04.1 (Ubuntu)

Copyright (c) 2000, 2014, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE DATABASE nova;
Query OK, 1 row affected (0.00 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'xxxx';
Query OK, 0 rows affected (0.00 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'xxxx';
Query OK, 0 rows affected (0.00 sec)

MariaDB [(none)]> flush privileges;
Query OK, 0 rows affected (0.00 sec)

MariaDB [(none)]> quit
Bye

```
### nova用户
创建nova用户:     

```
root@JunoController:~# source ~/openstack/admin-openrc.sh
root@JunoController:~# keystone user-create --name nova --pass xxxx
+----------+----------------------------------+
| Property |              Value               |
+----------+----------------------------------+
|  email   |                                  |
| enabled  |               True               |
|    id    | 845c22d1a781458a8b28ba54534b73dd |
|   name   |               nova               |
| username |               nova               |
+----------+----------------------------------+

```
制定nova属于service tenant, 并赋予admin权限:    

```
root@JunoController:~# keystone user-role-add --user nova --tenant service --role admin

```
在keystone注册nova:    

```
root@JunoController:~# keystone service-create --name nova --type compute --description "OpenStack Compute"
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
| description |        OpenStack Compute         |
|   enabled   |               True               |
|      id     | 8733caba0b9742a39ee9ac53ad4d8e27 |
|     name    |               nova               |
|     type    |             compute              |
+-------------+----------------------------------+

```
在keystone注册nova end-point:    

```
root@JunoController:~# keystone endpoint-create --service-id $(keystone service-list | awk '/ compute / {print $2}') --publicurl http://10.17.17.211:8774/v2/%\(tenant_id\)s --internalurl http://10.17.17.211:8774/v2/%\(tenant_id\)s --adminurl http://10.17.17.211:8774/v2/%\(tenant_id\)s --region regionOne
+-------------+-------------------------------------------+
|   Property  |                   Value                   |
+-------------+-------------------------------------------+
|   adminurl  | http://10.17.17.211:8774/v2/%(tenant_id)s |
|      id     |      d16c91bfacf2474ebee36314535a146f     |
| internalurl | http://10.17.17.211:8774/v2/%(tenant_id)s |
|  publicurl  | http://10.17.17.211:8774/v2/%(tenant_id)s |
|    region   |                 regionOne                 |
|  service_id |      8733caba0b9742a39ee9ac53ad4d8e27     |
+-------------+-------------------------------------------+

```
### Compute服务安装
#### Controller节点配置
在Controller节点上，安装以下包:    

```
root@JunoController:~# apt-get -y install nova-api nova-cert nova-conductor nova-consoleauth nova-novncproxy nova-scheduler python-novaclient

```
配置nova所需的配置文件:     

```
# vim /etc/nova/nova.conf
[database]
connection = mysql://nova:xxxxx@10.17.17.211/nova

[DEFAULT]
....
rpc_backend = rabbit
rabbit_host = 10.17.17.211
rabbit_password = xxxxxx
my_ip=10.17.17.211
vncserver_listen = 0.0.0.0
vncserver_proxyclient_address = 10.17.17.211
auth_strategy = keystone 

[keystone_authtoken]
auth_uri = http://10.17.17.211:5000
auth_host = 10.17.17.211
auth_port = 35357
auth_protocol = http
admin_tenant_name = service
admin_user = nova
admin_password = xxxx
[glance]
host=10.17.17.211

```
删除sqlite3数据库:     

```
root@JunoController:~# rm /var/lib/nova/nova.sqlite 

```
创建数据库：    

```
root@JunoController:~# su -s /bin/sh -c "nova-manage db sync" nova

```
重启服务，使用nova检查本机可用镜像情况:     

```
root@JunoController:~# service nova-api restart
root@JunoController:~# service nova-cert restart
root@JunoController:~#  service nova-consoleauth restart
root@JunoController:~# service nova-scheduler restart
root@JunoController:~# service nova-conductor restart
root@JunoController:~# service nova-novncproxy restart
root@JunoController:~# nova image-list
+--------------------------------------+---------------------+--------+--------+
| ID                                   | Name                | Status | Server |
+--------------------------------------+---------------------+--------+--------+
| 68f14900-8b25-4329-ad56-8fbd497c6812 | cirros-0.3.3-x86_64 | ACTIVE |        |
+--------------------------------------+---------------------+--------+--------+

```
#### Compute节点安装
安装下列包:     

```
root@JunoCompute:~#  apt-get -y install nova-compute sysfsutils

```
配置:     

```
root@JunoCompute:~# vim /etc/nova/nova.conf 
[DEFAULT]
......
auth_strategy = keystone
rpc_backend = rabbit
rabbit_host = 10.17.17.211
rabbit_password = xxxx
my_ip = 10.17.17.213
vnc_enabled = True
vncserver_listen = 0.0.0.0
vncserver_proxyclient_address = 10.17.17.213
novncproxy_base_url = http://10.17.17.211:6080/vnc_auto.html
glance_host = 10.17.17.211

[keystone_authtoken]
auth_uri = http://10.17.17.211:5000
auth_host = 10.17.17.211
auth_port = 35357
auth_protocol = http
admin_tenant_name = service
admin_user = nova
admin_password = xxxx

[database]
#The SQLAlchemy connection string used to connect to the database
connection = mysql://nova:xxxx@10.17.17.211/nova
[glance]
host=10.17.17.211

```
看cpu硬件是否支持硬件加速:     

```
root@JunoCompute:~# egrep -c '(vmx|svm)' /proc/cpuinfo
2

```
如果支持加速，则配置nova-compute.conf为:     

```
root@JunoCompute:~# cat /etc/nova/nova-compute.conf
[libvirt]
virt_type=kvm

```
删除不需要的nova.sqlite文件:      

```
root@JunoCompute:~# rm -f /var/lib/nova/nova.sqlite 

```
重起nova服务:     

```
root@JunoCompute:~# service nova-compute restart

```
### 验证
在控制节点上,列出所有的service:     

```
root@JunoController:~# nova service-list
+------------------+----------------+----------+---------+-------+----------------------------+-----------------+
| Binary           | Host           | Zone     | Status  | State | Updated_at                 | Disabled Reason |
+------------------+----------------+----------+---------+-------+----------------------------+-----------------+
| nova-cert        | JunoController | internal | enabled | up    | 2015-04-13T10:16:10.000000 | -               |
| nova-consoleauth | JunoController | internal | enabled | up    | 2015-04-13T10:16:12.000000 | -               |
| nova-scheduler   | JunoController | internal | enabled | up    | 2015-04-13T10:16:05.000000 | -               |
| nova-conductor   | JunoController | internal | enabled | up    | 2015-04-13T10:16:08.000000 | -               |
| nova-compute     | JunoCompute    | nova     | enabled | up    | 2015-04-13T10:16:09.000000 | -               |
+------------------+----------------+----------+---------+-------+----------------------------+-----------------+

```
现在compute节点已经配置完了，接下来可以配置网络节点。配置完网络节点后，就可以启动虚拟机了。    
