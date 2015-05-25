---
layout: post
title: "三节点搭建OpenStack Juno(3)"
date: 2015-05-25 16:51:01 +0800
comments: true
categories: Virtualization
---

### Nova
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


