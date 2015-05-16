---
layout: post
title: "安装Icehouse@Ubuntu14.04(2)"
date: 2015-04-13 16:08
comments: true
categories: Virtualization
---
### 安装Identity服务
首先创建keystone所需数据库:    

```
root@JunoController:~# mysql -u root -p
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 28
Server version: 5.5.41-MariaDB-1ubuntu0.14.04.1 (Ubuntu)

Copyright (c) 2000, 2014, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE DATABASE keystone;
Query OK, 1 row affected (0.00 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'KEYSTONE_PASS';
Query OK, 0 rows affected (0.00 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'KEYSTONE_PASS';
Query OK, 0 rows affected (0.00 sec)

MariaDB [(none)]> flush privileges;
Query OK, 0 rows affected (0.00 sec)

MariaDB [(none)]> exit;
Bye

```
安装keystone相关套件:     

```
root@JunoController:~# apt-get -y install keystone python-keystoneclient

```
创建一个admin token用于做初始化配置:    

```
root@JunoController:~# openssl rand -hex 10
5c3b5cd66a7dfa8e33e5

```
使用上面取得的admin token和mysql设置用于更新/etc/keystone.conf文件，更改如下:    

```
root@JunoController:~# vim /etc/keystone/keystone.conf 
[DEFAULT]
admin_token=5c3b5cd66a7dfa8e33e5
verbose=True
log_dir = /var/log/keystone

[database]
connection=mysql://keystone:KEYSTONE_DBPASS@10.17.17.211/keystone



```
部署数据库并重新启动Keystone服务:    

```
root@JunoController:~# su -s /bin/sh -c "keystone-manage db_sync" keystone
root@JunoController:~# service keystone restart

```
删除不需要的sqlite数据库, 并设定crontab任务:    

```
root@JunoController:~# rm -f /var/lib/keystone/keystone.db
root@JunoController:~# (crontab -l -u keystone 2>&1 | grep -q token_flush) || echo '@hourly /usr/bin/keystone-manage token_flush >/var/log/keystone/keystone-tokenflush.log 2>&1' >> /var/spool/cron/crontabs/keystone

```
### 建立 user / role / tenant
环境变量设置:    

```
root@JunoController:~# export OS_SERVICE_TOKEN=5c3b5cd66a7dfa8e33e5
root@JunoController:~# export OS_SERVICE_ENDPOINT=http://10.17.17.211:35357/v2.0

```
#### tenant创建
创建admin tenant:    

```
root@JunoController:~#  keystone tenant-create --name admin --description "Admin Tenant"
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
| description |           Admin Tenant           |
|   enabled   |               True               |
|      id     | ea1f0a6b15dc4796958f087c38756ed1 |
|     name    |              admin               |
+-------------+----------------------------------+

```
创建demo tenant:    

```
root@JunoController:~# keystone tenant-create --name demo --description "Demo Tenant"
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
| description |           Demo Tenant            |
|   enabled   |               True               |
|      id     | 2ac9cae777014d3d94458f521b013e94 |
|     name    |               demo               |
+-------------+----------------------------------+

```
#### 建立user
建立admin用户:    

```
root@JunoController:~# keystone user-create --name admin --pass xxxx --email kkkttt@gmail.com
+----------+----------------------------------+
| Property |              Value               |
+----------+----------------------------------+
|  email   |        kkkttt@gmail.com        |
| enabled  |               True               |
|    id    | 055dd9b7b1564df5bf9e9c511f32978b |
|   name   |              admin               |
| username |              admin               |
+----------+----------------------------------+

```
在demo tenant下建立demo用户:    

```
root@JunoController:~# keystone user-create --name demo --tenant demo --pass engine --email kkkttt@gmail.com
+----------+----------------------------------+
| Property |              Value               |
+----------+----------------------------------+
|  email   |        kkkttt@gmail.com        |
| enabled  |               True               |
|    id    | e8f2c2bdaee34f3895147f26a924e010 |
|   name   |               demo               |
| tenantId | 2ac9cae777014d3d94458f521b013e94 |
| username |               demo               |
+----------+----------------------------------+

```
#### admin role
建立admin role:    

```
root@JunoController:~# keystone role-create --name admin
+----------+----------------------------------+
| Property |              Value               |
+----------+----------------------------------+
|    id    | 4af914913e154a599deb1b78a0751c1a |
|   name   |              admin               |
+----------+----------------------------------+

```
#### 链接user/role/tenant

```
root@JunoController:~# keystone user-role-add --user admin --tenant admin --role admin

```
#### 创建一个Service Tenant
先建立Service Tenant:    

```
root@JunoController:~# keystone tenant-create --name service --description "Service Tenant"
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
| description |          Service Tenant          |
|   enabled   |               True               |
|      id     | 4b22bf4e6a68419aa91da6e0ffaca2dc |
|     name    |             service              |
+-------------+----------------------------------+

```
#### 定义services & API 服务挂载点
所有安装好的服务都需要向Identity Service注册，甚至是Identity Service本身，都需要先注册上才可以被使用:    
首先注册Identity Service:         

```
root@JunoController:~# keystone service-create --name keystone --type identity --description "OpenStack Identity"
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
| description |        OpenStack Identity        |
|   enabled   |               True               |
|      id     | 27bf7f70deac429d8d28623d99939ae6 |
|     name    |             keystone             |
|     type    |             identity             |
+-------------+----------------------------------+

```
而后，设定Identity Service的服务端点:     

```
root@JunoController:~# keystone endpoint-create --service-id $(keystone service-list | awk '/ identity / {print $2}') --publicurl http://10.17.17.211:5000/v2.0 --internalurl http://10.17.17.211:5000/v2.0 --adminurl http://10.17.17.211:35357/v2.0 --region regionOne                      
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
|   adminurl  |  http://10.17.17.211:35357/v2.0  |
|      id     | fb4c17d5c1414a7e852c6f7db552dd89 |
| internalurl |  http://10.17.17.211:5000/v2.0   |
|  publicurl  |  http://10.17.17.211:5000/v2.0   |
|    region   |            regionOne             |
|  service_id | 27bf7f70deac429d8d28623d99939ae6 |
+-------------+----------------------------------+

```
验证Identity服务是否安装成功,首先，unset环境变量:     

```
root@JunoController:~# unset OS_SERVICE_TOKEN OS_SERVICE_ENDPOINT

```
以 tenant(admin) & user(admin) 的身份取得 token:    

```
keystone --os-tenant-name admin --os-username admin --os-password ADMIN_PASS --os-auth-url http://10.17.17.211:35357/v2.0 token-get

```
以 tenant(admin) & user(admin) 的身分查詢 tenant 清單:     

```
# keystone --os-tenant-name admin --os-username admin --os-password  xxxxxx --os-auth-url http://10.17.17.211:35357/v2.0 tenant-list
+----------------------------------+---------+---------+
|                id                |   name  | enabled |
+----------------------------------+---------+---------+
| ea1f0a6b15dc4796958f087c38756ed1 |  admin  |   True  |
| 2ac9cae777014d3d94458f521b013e94 |   demo  |   True  |
| 4b22bf4e6a68419aa91da6e0ffaca2dc | service |   True  |
+----------------------------------+---------+---------+

```
查询user清单：     

```
root@JunoController:~# keystone --os-tenant-name admin --os-username admin --os-password xxxx --os-auth-url http://10.17.17.211:35357/v2.0 user-list
+----------------------------------+-------+---------+--------------------+
|                id                |  name | enabled |       email        |
+----------------------------------+-------+---------+--------------------+
| 055dd9b7b1564df5bf9e9c511f32978b | admin |   True  | kkkttt@gmail.com |
| e8f2c2bdaee34f3895147f26a924e010 |  demo |   True  | kkkttt@gmail.com |
+----------------------------------+-------+---------+--------------------+

```
查询role清单:    

```
root@JunoController:~# keystone --os-tenant-name admin --os-username admin --os-password xxxx --os-auth-url http://10.17.17.211:35357/v2.0 role-list
+----------------------------------+----------+
|                id                |   name   |
+----------------------------------+----------+
| 9fe2ff9ee4384b1894a90878d3e92bab | _member_ |
| 4af914913e154a599deb1b78a0751c1a |  admin   |
+----------------------------------+----------+

```
以demo用户身份去的token

```
root@controller:~# keystone --os-tenant-name demo --os-username demo --os-password DEMO_PASS --os-auth-url http://10.17.17.211:35357/v2.0 token-get

```
以demo身份取得用户清单会被提示权限不足:    

```
root@JunoController:~# keystone --os-tenant-name demo --os-username demo --os-password xxxx --os-auth-url http://10.17.17.211:35357/v2.0 user-list
You are not authorized to perform the requested action, admin_required. (HTTP 403)

```
现在keystone服务已经挂载完毕了，接下来就是逐个挂载组件。    
### 快速切换脚本
快速切换脚本如下，记得加上执行权限:    

```
root@JunoController:~# cat openstack/admin-openrc.sh
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=xxxx
export OS_AUTH_URL=http://10.17.17.211:35357/v2.0
root@JunoController:~# cat openstack/demo-openrc.sh 
export OS_TENANT_NAME=demo
export OS_USERNAME=demo
export OS_PASSWORD=xxxx
export OS_AUTH_URL=http://10.17.17.211:5000/v2.0

```
