---
layout: post
title: "安装Icehouse@Ubuntu14.04(3)"
date: 2015-04-13 16:54
comments: true
categories: virtualization
---
Image Service 用于提供给用户用于快速启动虚拟机的镜像文件，这样的服务称为glance服务。    

### Glance服务数据库设定
在mysql中创建glance数据库:    

```
root@JunoController:~#  mysql -u root -p
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 33
Server version: 5.5.41-MariaDB-1ubuntu0.14.04.1 (Ubuntu)

Copyright (c) 2000, 2014, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE DATABASE glance;
Query OK, 1 row affected (0.01 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'xxxx'
    -> ;
Query OK, 0 rows affected (0.00 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'xxxx';
Query OK, 0 rows affected (0.00 sec)

MariaDB [(none)]> flush privileges;
Query OK, 0 rows affected (0.00 sec)

MariaDB [(none)]> quit;
Bye

```
### 创建Glance的user/role/tenant权限
用admin的权限，创建以下权限：    

```
root@JunoController:~#  source ~/openstack/admin-openrc.sh

```
创建glance用户:    

```
root@JunoController:~# keystone user-create --name glance --pass engine
+----------+----------------------------------+
| Property |              Value               |
+----------+----------------------------------+
|  email   |                                  |
| enabled  |               True               |
|    id    | c706febbcc8843fb97383c9fdfba6214 |
|   name   |              glance              |
| username |              glance              |
+----------+----------------------------------+

```
用户glance属于admin角色，使用service tanant:    

```
keystone user-role-add --user glance --tenant service --role admin

```
在keystone注册glance服务:     

```
root@JunoController:~# keystone service-create --name glance --type image --description "OpenStack Image Service"
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
| description |     OpenStack Image Service      |
|   enabled   |               True               |
|      id     | 3d52d2992b9f423eb9868304e4405fab |
|     name    |              glance              |
|     type    |              image               |
+-------------+----------------------------------+

```
在keystone创建服务的end-point:    

```
root@JunoController:~# keystone endpoint-create --service-id $(keystone service-list | awk '/ image / {print $2}') --publicurl http://10.17.17.211:9292 --internalurl http://10.17.17.211:9292 --adminurl http://10.17.17.211:9292 --region regionOne
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
|   adminurl  |     http://10.17.17.211:9292     |
|      id     | f44400bebc07408d8e0f4e70a0d18475 |
| internalurl |     http://10.17.17.211:9292     |
|  publicurl  |     http://10.17.17.211:9292     |
|    region   |            regionOne             |
|  service_id | 3d52d2992b9f423eb9868304e4405fab |
+-------------+----------------------------------+

```
### 安装Glance服务
安装:    

```
apt-get -y install glance python-glanceclient

```
配置:    

```
# vim /etc/glance/glance-api.conf
[database]
# sqlite_db = /var/lib/glance/glance.sqlite
backend = sqlalchemy
connection = mysql://glance:engine@10.17.17.211/glance

[keystone_authtoken]
auth_uri = http://10.17.17.211:5000
auth_host = 10.17.17.211
auth_port = 35357
auth_protocol = http
admin_tenant_name = service
admin_user = glance
admin_password = engine
#  vim /etc/glance/glance-registry.conf
[database]
# The file name to use with SQLite (string value)
#sqlite_db = /var/lib/glance/glance.sqlite
backend = sqlalchemy
connection = mysql://glance:engine@10.17.17.211/glance

[keystone_authtoken]
auth_uri = http://10.17.17.211:5000
auth_host = 10.17.17.211
auth_port = 35357
auth_protocol = http
admin_tenant_name = service
admin_user = glance
admin_password = engine
# rm -f /var/lib/glance/glance.sqlite
# su -s /bin/sh -c "glance-manage db_sync" glance

```
这里会碰到一个问题，解决方案如下:    

```
root@JunoController:~# su -s /bin/sh -c "glance-manage db_sync" glance
2015-04-13 17:20:22.637 9455 CRITICAL glance [-] ValueError: Tables "migrate_version" have non utf8 collation, please make sure all tables are CHARSET=utf8

root@JunoController:~# mysql -u root -p glance
Enter password: 
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 29
Server version: 5.5.41-MariaDB-1ubuntu0.14.04.1 (Ubuntu)

Copyright (c) 2000, 2014, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [glance]> alter table migrate_version convert to character set utf8 collate utf8_unicode_ci;
Query OK, 1 row affected (0.09 sec)                
Records: 1  Duplicates: 0  Warnings: 0

MariaDB [glance]> flush privileges;
Query OK, 0 rows affected (0.00 sec)

MariaDB [glance]> quit;
Bye

```
重启服务，    

```
root@JunoController:~# service glance-registry restart
root@JunoController:~# service glance-api restart

```
### 验证Glance服务
首先下载镜像:     

```
# wget http://cdn.download.cirros-cloud.net/0.3.3/cirros-0.3.3-x86_64-disk.img

```
创建Glance可见镜像:    

```
# glance image-create --name "cirros-0.3.3-x86_64" --file cirros-0.3.3-x86_64-disk.img --disk-format qcow2 --container-format bare --is-public True --progress
[=============================>] 100%
+------------------+--------------------------------------+
| Property         | Value                                |
+------------------+--------------------------------------+
| checksum         | 133eae9fb1c98f45894a4e60d8736619     |
| container_format | bare                                 |
| created_at       | 2015-04-13T09:27:54                  |
| deleted          | False                                |
| deleted_at       | None                                 |
| disk_format      | qcow2                                |
| id               | 68f14900-8b25-4329-ad56-8fbd497c6812 |
| is_public        | True                                 |
| min_disk         | 0                                    |
| min_ram          | 0                                    |
| name             | cirros-0.3.3-x86_64                  |
| owner            | ea1f0a6b15dc4796958f087c38756ed1     |
| protected        | False                                |
| size             | 13200896                             |
| status           | active                               |
| updated_at       | 2015-04-13T09:27:54                  |
| virtual_size     | None                                 |
+------------------+--------------------------------------+

```
检查镜像:    

```
root@JunoController:~# ls /var/lib/glance/images/
68f14900-8b25-4329-ad56-8fbd497c6812

```
列出可用镜像:    

```
root@JunoController:~# glance image-list
+--------------------------------------+---------------------+-------------+------------------+----------+--------+
| ID                                   | Name                | Disk Format | Container Format | Size     | Status |
+--------------------------------------+---------------------+-------------+------------------+----------+--------+
| 68f14900-8b25-4329-ad56-8fbd497c6812 | cirros-0.3.3-x86_64 | qcow2       | bare             | 13200896 | active |
+--------------------------------------+---------------------+-------------+------------------+----------+--------+

```
好了，现在glance服务可以使用了，接下来将创建compute节点和网络节点。    
