---
layout: post
title: "三节点搭建OpenStack Juno(3)"
date: 2015-05-25 16:51:01 +0800
comments: true
categories: Virtualization
---

### Nova

#### Nova数据库    
创建nova数据库:      

```
# mysql -u root -p
	CREATE DATABASE nova;
	GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' \
	IDENTIFIED BY 'NOVA_DBPASS';
	GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' \
	IDENTIFIED BY 'NOVA_DBPASS';
	quit;
```
创建nova用户:    

```
# source /home/dash/admin-openrc.sh
root@Controller:~# keystone user-create --name nova --pass xxxxxx
+----------+----------------------------------+
| Property |              Value               |
+----------+----------------------------------+
|  email   |                                  |
| enabled  |               True               |
|    id    | 4a3768e3f4754cd0b9d47c6fadb22c7e |
|   name   |               nova               |
| username |               nova               |
+----------+----------------------------------+
```

为admin角色添加nova用户:     

```
# keystone user-role-add --user nova --tenant service --role admin
```

添加nova服务条目:    

```
# keystone service-create --name nova --type compute --description "OpenStack Compute"
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
| description |        OpenStack Compute         |
|   enabled   |               True               |
|      id     | 1587a46ee1e94402821398444175981f |
|     name    |               nova               |
|     type    |             compute              |

```
创建Compute服务的API endpoints:    

```
# keystone endpoint-create --service-id $(keystone service-list | awk '/ compute / {print $2}') --publicurl http://Controller:8774/v2/%\(tenant_id\)s --internalurl http://Controller:8774/v2/%\(tenant_id\)s --adminurl http://Controller:8774/v2/%\(tenant_id\)s --region regionOne
+-------------+-----------------------------------------+
|   Property  |                  Value                  |
+-------------+-----------------------------------------+
|   adminurl  | http://Controller:8774/v2/%(tenant_id)s |
|      id     |     bd439dc236c04956a11b353a7b74331c    |
| internalurl | http://Controller:8774/v2/%(tenant_id)s |
|  publicurl  | http://Controller:8774/v2/%(tenant_id)s |
|    region   |                regionOne                |
|  service_id |     1587a46ee1e94402821398444175981f    |
+-------------+-----------------------------------------+
```

#### Nova安装及配置
安装以下包:    

```
# apt-get install nova-api nova-cert nova-conductor nova-consoleauth nova-novncproxy nova-scheduler python-novaclient
```

更改数据库链接:    

```
$ sudo vim /etc/nova/nova.conf
[database]
...
connection = mysql://nova:NOVA_DBPASS@controller/nova
```

配置RabbitMQ访问:    

```
[DEFAULT]
...
rpc_backend = rabbit
rabbit_host = controller
rabbit_password = RABBIT_PASS
```

配置鉴权服务:    

```
[DEFAULT]
...
auth_strategy = keystone
[keystone_authtoken]
...
auth_uri = http://controller:5000/v2.0
identity_uri = http://controller:35357
admin_tenant_name = service
admin_user = nova
admin_password = NOVA_PASS
```

更改`my_ip`:    

```
[DEFAULT]
...
my_ip = 10.55.55.2
```

更改VNC侦听：    

```
[DEFAULT]
...
vncserver_listen = 10.55.55.2
vncserver_proxyclient_address = 10.55.55.2
```

配置glance服务所在:    

```
[glance]
...
host = controller
```

现在开始配置数据库:    

```
# su -s /bin/sh -c "nova-manage db sync" nova
```

重启服务以完成安装:    

```
# service nova-api restart
# service nova-cert restart
# service nova-consoleauth restart
# service nova-scheduler restart 
# service nova-conductor start
# service nova-conductor restart
# service nova-novncproxy
# service nova-novncproxy restart
```

扫尾，删除不用的sqlite数据库:    

```
# rm -f /var/lib/nova/nova.sqlite
```

### 安装和配置计算节点
在计算节点上，安装以下包:    

```
# apt-get install nova-compute sysfsutils
```

配置具体过程如下:    
配置RabbitMQ:    

```
$ sudo vim /etc/nova/nova.conf
[DEFAULT]
...
rpc_backend = rabbit
rabbit_host = controller
rabbit_password = RABBIT_PASS
```

配置鉴权服务:    

```
[DEFAULT]
...
auth_strategy = keystone
[keystone_authtoken]
...
auth_uri = http://Controller:5000/v2.0
identity_uri = http://Controller:35357
admin_tenant_name = service
admin_user = nova
admin_password = NOVA_PASS
```

配置`my_ip`:    

```
[DEFAULT]
...
my_ip = 10.55.55.4
```

配置允许远程终端访问:    

```
[DEFAULT]
...
vnc_enabled = True
vncserver_listen = 0.0.0.0
vncserver_proxyclient_address = 10.55.55.4
novncproxy_base_url = http://Controller:6080/vnc_auto.html

```

配置glance服务:    

```
[glance]
...
host = Controller
```

完成安装， 首先判断你的CPU是否支持硬件加速:    

```
$ egrep -c '(vmx|svm)' /proc/cpuinfo
```

如果返回的值小于1, 则更改`/etc/nova/nova-compute.conf`配置中的[libvirt]选项，选用qemu而不是kvm:    

```
$ sudo vim /etc/nova/nova-compute.conf
[libvirt]
...
virt_type = qemu
```

重启nova-compute服务:    

```
# service nova-compute restart
```

扫尾，删除不用的nova.sqlite文件:    

```
# rm -f /var/lib/nova/nova.sqlite
```

### 验证
具体步骤如下:    

```
root@Controller:~# source ~/admin-openrc.sh
root@Controller:~# nova service-list
+----+------------------+------------+----------+---------+-------+----------------------------+-----------------+
| Id | Binary           | Host       | Zone     | Status  | State | Updated_at                 | Disabled Reason |
+----+------------------+------------+----------+---------+-------+----------------------------+-----------------+
| 1  | nova-cert        | Controller | internal | enabled | up    | 2015-05-25T12:00:20.000000 | -               |
| 2  | nova-consoleauth | Controller | internal | enabled | up    | 2015-05-25T12:00:28.000000 | -               |
| 3  | nova-scheduler   | Controller | internal | enabled | up    | 2015-05-25T12:00:23.000000 | -               |
| 4  | nova-conductor   | Controller | internal | enabled | up    | 2015-05-25T12:00:25.000000 | -               |
| 5  | nova-compute     | Compute    | nova     | enabled | up    | 2015-05-25T12:00:20.000000 | -               |
+----+------------------+------------+----------+---------+-------+----------------------------+-----------------+
root@Controller:~# nova image-list
+--------------------------------------+---------------------+--------+--------+
| ID                                   | Name                | Status | Server |
+--------------------------------------+---------------------+--------+--------+
| 3d45ea58-731c-4eb5-bf30-db1b4bfe4f57 | cirros-0.3.3-x86_64 | ACTIVE |        |
+--------------------------------------+---------------------+--------+--------+

```

注意我们看到了compute节点已经被加入进来。这样我们完成了添加计算服务，接下来我们将开始添加网络组件，这可能是最难的一部分。    
