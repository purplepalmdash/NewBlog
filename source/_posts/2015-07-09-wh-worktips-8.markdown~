---
layout: post
title: "WH Worktips(8)"
date: 2015-07-09 11:08:00 +0800
comments: true
categories: virtualization
---
After Cobbler import and deployment, simply install download plugins, 
Create the repo, and edit the repo definition file in the deployed node:    

```
[root@node164 ~]# cat /etc/yum.repos.d/cloudstack.repo 
[cloudstack]
name=cloudstack
baseurl=http://10.47.58.2/4.5CentOS7/
enabled=1
gpgcheck=0
```

Steps for installing the cloudstack on CentOS7:    

```
# yum install -y ntp
[root@node164 ~]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
10.47.58.164    node164
[root@node164 ~]# vim /etc/selinux/config 
SELINUX=permissive
SELINUXTYPE=targeted
[root@node164 ~]# yum install libselinux-python
# yum install -y wget 
# wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
# yum install -y python-pip
# yum install -y mysql

[root@node164 ~]# sudo rpm -Uvh http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
[root@node164 ~]# sudo yum -y install mysql-community-server
[root@node164 ~]# yum install -y MySQL-python
# vim /etc/my.cnf
    # CloudStack MySQL settings
    innodb_rollback_on_timeout=1
    innodb_lock_wait_timeout=600
    max_connections=700
    log-bin=mysql-bin
    binlog-format = 'ROW'
    bind-address=0.0.0.0
    
    [mysqld_safe]
    log-error=/var/log/mariadb/mariadb.log
[root@node164 ~]# service mysqld start

```
