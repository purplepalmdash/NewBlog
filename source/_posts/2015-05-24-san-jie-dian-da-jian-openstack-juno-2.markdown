---
layout: post
title: "三节点搭建OpenStack Juno(2)"
date: 2015-05-24 22:37:28 +0800
comments: true
categories: Virtualization
---

### MySQL数据库
绝大多数的OpenStack服务使用SQL数据库来存储信息，一般情况下数据库运行在控制节点上，这里我们使用MariaDB或者MySQL来作为SQL数据库。    

安装, 注意安装过程中需要输入密码:    

```
# apt-get install mariadb-server python-mysqldb
```

配置, 主要是更改了bind的地址，添加了一些有用选项，并支持UTF-8编码:     

```
$ sudo vim /etc/mysql/my.cnf
[mysqld]
...
bind-address = 10.55.55.2
...
default-storage-engine = innodb
innodb_file_per_table
collation-server = utf8_general_ci
init-connect = 'SET NAMES utf8'
character-set-server = utf8
```

完成安装，包括重启服务及加密数据库服务:      

```
# service mysql restart
# mysql_secure_installation 
```

### 消息服务器
OpenStack使用message broker用来在各种服务器之间调度操作和协调状态信息，通常情况下消息服务器也运行在控制节点上，OpenStack支持RabbitMQ, Qpid和ZeroMQ, 这里使用RabbitMQ.    

安装:    

```
# apt-get install rabbitmq-server
```

配置，首先我们需要设定rabbitMQ使用的密码:    

```
# rabbitmqctl change_password guest RABBIT_PASS
Changing password for user "guest" ...
...done.
```

如果是RabbitMQ 3.3.0或者更新的版本，则需要激活guest用户的远程访问权限。    

检查RabbitMQ版本:    

```
# rabbitmqctl status | grep rabbit
Status of node rabbit@Controller ...
 {running_applications,[{rabbit,"RabbitMQ","3.2.4"},
```

这里我们的版本是3.2.4所以不需要做任何修改，直接重启RabbitMQ服务即可。若是3.3.0以后的版本，则需要参考官方文档作更为详细的配置。    

```
# service rabbitmq-server restart
```

### 鉴权(Identity)服务
鉴权服务的作用主要有:     
1\. 跟踪用户及其权限。     
2\. 提供可用服务的服务类别及API endpoint.    

详细的关于Identity的介绍可以参见OpenStack官方文档。只有理解了其理念后才能明了OpenStack架构中各种服务的角色和地位.      

首先创建keystone所需要的数据库:     

```
# mysql -u root -p
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 36
Server version: 5.5.43-MariaDB-1ubuntu0.14.04.2 (Ubuntu)

Copyright (c) 2000, 2015, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE DATABASE keystone;
Query OK, 1 row affected (0.00 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' \
    -> IDENTIFIED BY 'KEYSTONE_PASSWD';
Query OK, 0 rows affected (0.01 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' \
    -> IDENTIFIED BY 'KEYSTONE_PASSWD';
Query OK, 0 rows affected (0.00 sec)

MariaDB [(none)]> quit;
Bye

```

创建一个随机值，用于管理token在初始化配置时使用:     

```
# openssl rand -hex 10
760bc221f4dc966693e5
```

安装和配置组件:    


```
# apt-get install keystone python-keystoneclient
```

配置, 更改`admin_token`为刚才生成的随机数:    
```
$ sudo vim /etc/keystone/keystone.conf
[DEFAULT]
...
admin_token = 760bc221f4dc966693e5
...
[database]
...
connection = mysql://keystone:KEYSTONE_DBPASS@Controller/keystone
...
[token]
...
provider = keystone.token.providers.uuid.Provider
driver = keystone.token.persistence.backends.sql.Token
...
[revoke]
...
driver = keystone.contrib.revoke.backends.sql.Revoke
...
[DEFAULT]
...
verbose = True
```

修改完毕后，使用以下命令来同步Identity服务数据库:    

```
# su -s /bin/sh -c "keystone-manage db_sync" keystone
```

重启鉴权服务，删除Ubuntu使用的默认sqlite数据库, 并完成安装:    

```
# service keystone restart
# rm -f /var/lib/keystone/keystone.db 
```

使用下列命令来激活cron任务，以便每小时判断tokens的存活时间:     

```
# (crontab -l -u keystone 2>&1 | grep -q token_flush) || echo '@hourly /usr/bin/keystone-manage token_flush >/var/log/keystone/keystone-tokenflush.log 2>&1' >> /var/spool/cron/crontabs/keystone
```

#### 创建tenants, users, roles    

```
# export OS_SERVICE_TOKEN=760bc221f4dc966693e5
# export OS_SERVICE_ENDPOINT=http://Controller:35357/v2.0
# keystone tenant-create --name admin --description "Admin Tenant"
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
| description |           Admin Tenant           |
|   enabled   |               True               |
|      id     | 6f5f440aa9de4b2fa205f43df073ddfa |
|     name    |              admin               |
+-------------+----------------------------------+
# keystone user-create --name admin --pass XXXXXXXXX --email xxxxxxxx@gmail.com
+----------+----------------------------------+
| Property |              Value               |
+----------+----------------------------------+
|  email   |        XXXXXXXX@gmail.com        |
| enabled  |               True               |
|    id    | 7bc9be5493e345518a384383872ab274 |
|   name   |              admin               |
| username |              admin               |
+----------+----------------------------------+
# keystone role-create --name admin
+----------+----------------------------------+
| Property |              Value               |
+----------+----------------------------------+
|    id    | 65b6ccaa3b434c848ccb757be43d6b41 |
|   name   |              admin               |
+----------+----------------------------------+
# keystone user-role-add --user admin --tenant admin --role admin
# keystone tenant-create --name demo --description "Demo Tenant"
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
| description |           Demo Tenant            |
|   enabled   |               True               |
|      id     | 459c25933274483fb01ce66d9514add6 |
|     name    |               demo               |
+-------------+----------------------------------+
# keystone user-create --name demo --tenant demo --pass xxxxx --email xxxxxxx@gmail.com
+----------+----------------------------------+
| Property |              Value               |
+----------+----------------------------------+
|  email   |        xxxxxxx@gmail.com        |
| enabled  |               True               |
|    id    | b2f3d8a239b34edfb50fa67c5aca8f83 |
|   name   |               demo               |
| tenantId | 459c25933274483fb01ce66d9514add6 |
| username |               demo               |
+----------+----------------------------------+
# keystone tenant-create --name service --description "Service Tenant"
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
| description |          Service Tenant          |
|   enabled   |               True               |
|      id     | 08a675be93a04cca8a74159a3eefa288 |
|     name    |             service              |
+-------------+----------------------------------+
# keystone service-create --name keystone --type identity --description "OpenStack Identity"
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
| description |        OpenStack Identity        |
|   enabled   |               True               |
|      id     | bf7613d9563c47a9af80ecdb4f26f3f5 |
|     name    |             keystone             |
|     type    |             identity             |
+-------------+----------------------------------+
# keystone endpoint-create --service-id $(keystone service-list | awk '/ identity / {print $2}') --publicurl http://Controller:5000/v2.0 --internalurl http://Controller:5000/v2.0 --adminurl http://Controller:35357/v2.0 --region regionOne
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
|   adminurl  |   http://Controller:35357/v2.0   |
|      id     | c2c7a6c24b1d411b996f2e30fefc70b6 |
| internalurl |   http://Controller:5000/v2.0    |
|  publicurl  |   http://Controller:5000/v2.0    |
|    region   |            regionOne             |
|  service_id | bf7613d9563c47a9af80ecdb4f26f3f5 |
+-------------+----------------------------------+
```

验证, 详细的说明参见OpenStack官方文档:         

```
# unset OS_SERVICE_TOKEN OS_SERVICE_ENDPOINT
# keystone --os-tenant-name admin --os-username admin --os-password xxxxx --os-auth-url http://Controller:35357/v2.0 token-get
+-----------+----------------------------------+
|  Property |              Value               |
+-----------+----------------------------------+
|  expires  |       2015-05-24T16:43:08Z       |
|     id    | 612b529c9c754b87a153abd39284aff6 |
| tenant_id | 6f5f440aa9de4b2fa205f43df073ddfa |
|  user_id  | 7bc9be5493e345518a384383872ab274 |
+-----------+----------------------------------+
# keystone --os-tenant-name admin --os-username admin --os-password xxxxx --os-auth-url http://Controller:35357/v2.0 tenant-list
+----------------------------------+---------+---------+
|                id                |   name  | enabled |
+----------------------------------+---------+---------+
| 6f5f440aa9de4b2fa205f43df073ddfa |  admin  |   True  |
| 459c25933274483fb01ce66d9514add6 |   demo  |   True  |
| 08a675be93a04cca8a74159a3eefa288 | service |   True  |
+----------------------------------+---------+---------+
# keystone --os-tenant-name admin --os-username admin --os-password xxxxx --os-auth-url http://Controller:35357/v2.0 user-list
+----------------------------------+-------+---------+--------------------+
|                id                |  name | enabled |       email        |
+----------------------------------+-------+---------+--------------------+
| 7bc9be5493e345518a384383872ab274 | admin |   True  | xxxxxxx@gmail.com |
| b2f3d8a239b34edfb50fa67c5aca8f83 |  demo |   True  | xxxxxxx@gmail.com |
+----------------------------------+-------+---------+--------------------+
# keystone --os-tenant-name admin --os-username admin --os-password xxxxx --os-auth-url http://Controller:35357/v2.0 role-list
+----------------------------------+----------+
|                id                |   name   |
+----------------------------------+----------+
| 9fe2ff9ee4384b1894a90878d3e92bab | _member_ |
| 65b6ccaa3b434c848ccb757be43d6b41 |  admin   |
+----------------------------------+----------+
# keystone --os-tenant-name demo --os-username demo --os-password xxxxx --os-auth-url http://controller:35357/v2.0 token-get
+-----------+----------------------------------+
|  Property |              Value               |
+-----------+----------------------------------+
|  expires  |       2015-05-24T16:46:34Z       |
|     id    | 0d8a9472b0f547dfabc62594b4fb146f |
| tenant_id | 459c25933274483fb01ce66d9514add6 |
|  user_id  | b2f3d8a239b34edfb50fa67c5aca8f83 |
+-----------+----------------------------------+
# keystone --os-tenant-name demo --os-username demo --os-password xxxxx --os-auth-url http://controller:35357/v2.0 user-list
You are not authorized to perform the requested action: admin_required (HTTP 403)

```

### 创建脚本

```
# cat admin-openrc.sh 
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=xxxxx
export OS_AUTH_URL=http://Controller:35357/v2.0
# cat demo-openrc.sh
export OS_TENANT_NAME=demo
export OS_USERNAME=demo
export OS_PASSWORD=xxxxx
export OS_AUTH_URL=http://Controller:5000/v2.0

```

下次使用时直接用`source admin-openrc.sh`或者`source demo-openrc.sh`即可。    


### 镜像服务
添加镜像服务:     

```
root@Controller:~# mysql -u root -p
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 40
Server version: 5.5.43-MariaDB-1ubuntu0.14.04.2 (Ubuntu)

Copyright (c) 2000, 2015, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE DATABASE glance;
Query OK, 1 row affected (0.00 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'xxxxx';
Query OK, 0 rows affected (0.00 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'xxxxx';
Query OK, 0 rows affected (0.00 sec)

MariaDB [(none)]> quit;
Bye

```

创建glance用户:    


```
# source  /home/dash/admin-openrc.sh
# keystone user-create --name glance --pass xxxxx
+----------+----------------------------------+
| Property |              Value               |
+----------+----------------------------------+
|  email   |                                  |
| enabled  |               True               |
|    id    | a3108e4267154acd809f3978d360e6cd |
|   name   |              glance              |
| username |              glance              |
+----------+----------------------------------+

```

赋予glance用户admin权限:    

```
# keystone user-role-add --user glance --tenant service --role admin
```

创建service entity和service end-point:    

```
 keystone service-create --name glance --type image --description "OpenStack Image Service"
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
| description |     OpenStack Image Service      |
|   enabled   |               True               |
|      id     | 8736ca50fdf741afb5fcc2d078b1cd9b |
|     name    |              glance              |
|     type    |              image               |
+-------------+----------------------------------+
# keystone endpoint-create --service-id $(keystone service-list | awk '/ image / {print $2}') --publicurl http://Controller:9292 --internalurl http://Controller:9292 --adminurl http://Controller:9292 --region regionOne
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
|   adminurl  |      http://Controller:9292      |
|      id     | 340f40f0558c4a5b8fa88089aee69767 |
| internalurl |      http://Controller:9292      |
|  publicurl  |      http://Controller:9292      |
|    region   |            regionOne             |
|  service_id | 8736ca50fdf741afb5fcc2d078b1cd9b |
+-------------+----------------------------------+

```

安装服务组件:    


```
# apt-get install glance python-glanceclient
```

配置：    

```
# vim /etc/glance/glance-api.conf
[database]
...
connection = mysql://glance:GLANCE_DBPASS@controller/glance
[keystone_authtoken]
...
auth_uri = http://controller:5000/v2.0
identity_uri = http://controller:35357
admin_tenant_name = service
admin_user = glance
admin_password = GLANCE_PASS
[paste_deploy]
...
flavor = keystone
[glance_store]
...
default_store = file
filesystem_store_datadir = /var/lib/glance/images/
[DEFAULT]
...
notification_driver = noop
[DEFAULT]
...
verbose = True
```

配置`/etc/glance/glance-registry.conf`文件，完成以下配置:    

```
[database]
...
connection = mysql://glance:GLANCE_DBPASS@controller/glance

[keystone_authtoken]
...
auth_uri = http://controller:5000/v2.0
identity_uri = http://controller:35357
admin_tenant_name = service
admin_user = glance
admin_password = GLANCE_PASS
[paste_deploy]
...
flavor = keystone
[DEFAULT]
...
notification_driver = noop
[DEFAULT]
...
notification_driver = noop
```

同步数据库:     

```
# su -s /bin/sh -c "glance-manage db_sync" glance
```

重启服务，删除默认的sqlite数据库:     

```
# service glance-registry restart
# service glance-api restart
# rm -f /var/lib/glance/glance.sqlite

```

验证:     


```
# wget http://download.cirros-cloud.net/0.3.3/cirros-0.3.3-x86_64-disk.img
# source ~/admin-openrc.sh
# glance image-create --name "cirros-0.3.3-x86_64" --file ~/cirros-0.3.3-x86_64-disk.img --disk-format qcow2 --container-format bare --is-public True --progress
[=============================>] 100%
+------------------+--------------------------------------+
| Property         | Value                                |
+------------------+--------------------------------------+
| checksum         | 133eae9fb1c98f45894a4e60d8736619     |
| container_format | bare                                 |
| created_at       | 2015-05-24T16:25:32                  |
| deleted          | False                                |
| deleted_at       | None                                 |
| disk_format      | qcow2                                |
| id               | 3d45ea58-731c-4eb5-bf30-db1b4bfe4f57 |
| is_public        | True                                 |
| min_disk         | 0                                    |
| min_ram          | 0                                    |
| name             | cirros-0.3.3-x86_64                  |
| owner            | 6f5f440aa9de4b2fa205f43df073ddfa     |
| protected        | False                                |
| size             | 13200896                             |
| status           | active                               |
| updated_at       | 2015-05-24T16:25:32                  |
| virtual_size     | None                                 |
+------------------+--------------------------------------+
# glance image-list
+--------------------------------------+---------------------+-------------+------------------+----------+--------+
| ID                                   | Name                | Disk Format | Container Format | Size     | Status |
+--------------------------------------+---------------------+-------------+------------------+----------+--------+
| 3d45ea58-731c-4eb5-bf30-db1b4bfe4f57 | cirros-0.3.3-x86_64 | qcow2       | bare             | 13200896 | active |
+--------------------------------------+---------------------+-------------+------------------+----------+--------+

```

控制节点基本上配置成功，明天继续。
