---
layout: post
title: "CloudStack Dev Env Setup"
date: 2015-12-26 09:24:22 +0800
comments: true
categories: virtualization
---
### Hypervisor Preparation
Use Virtualbox for setting up the development env, the configuration of the
networking are lisetd as following:   

```
Host-Only 1: 192.168.56.1/255.255.255.0
Host-Only 2: 172.30.0.1/255.255.255.0
Host-Only 3: none
NAT network: 10.0.2.0/24
```
Host-Only 1:    
![/images/2015_12_26_09_23_32_460x220.jpg](/images/2015_12_26_09_23_32_460x220.jpg)    
Host-Only 2:    
![/images/2015_12_26_09_23_50_450x226.jpg](/images/2015_12_26_09_23_50_450x226.jpg)    
Host-Only 3:    
![/images/2015_12_26_09_24_02_459x255.jpg](/images/2015_12_26_09_24_02_459x255.jpg)    
NAT:    
![/images/2015_12_26_09_27_57_500x288.jpg](/images/2015_12_26_09_27_57_500x288.jpg)   


### Virtual Machine
Install CentOS6.7, the network configuration is listed as:    

```
eth0 -> Host-Only 1
eth1 -> NAT
eth2 -> Host-Only 2
eth3 -> Host-Only 3
```

The configuration files for NAT working is listed as:    

```
[root@CSMAN yum.repos.d]# cat /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
TYPE=Ethernet
UUID=fc709b6b-54c0-4181-97cc-d91f14228fdc
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=none
HWADDR=08:00:27:CC:35:D9
IPADDR=192.168.56.11
PREFIX=24
GATEWAY=192.168.56.1
#DNS1=223.5.5.5
#DEFROUTE=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
NAME="System eth0"
[root@CSMAN yum.repos.d]# cat /etc/sysconfig/network-scripts/ifcfg-eth1
DEVICE=eth1 
TYPE=Ethernet 
#IPADDR=10.0.2.11 
#GATEWAY=10.0.2.22 
PREFIX=24 
ONBOOT=yes 
NM_CONTROLLED=no 
BOOTPROTO=dhcp
DEFROUTE=yes 
PEERROUTES=yes 
IPV4_FAILURE_FATAL=yes 
IPV6INIT=no 
NAME=NAT 
DNS1=180.76.76.76
[root@CSMAN yum.repos.d]# cat /etc/sysconfig/network-scripts/ifcfg-eth2
DEVICE=eth2 
TYPE=Ethernet 
IPADDR=172.30.0.11 
PREFIX=24 
ONBOOT=yes 
NM_CONTROLLED=no 
BOOTPROTO=none 
IPV4_FAILURE_FATAL=yes 
IPV6INIT=no 
NAME=PUBLIC 
[root@CSMAN yum.repos.d]# cat /etc/sysconfig/network-scripts/ifcfg-eth3
CE=eth3 
TYPE=Ethernet 
BOOTPROTO=none 
ONBOOT=yes 
MTU=9000 
VLAN=yes 
USERCTL=no 
MTU=9000 
[root@CSMAN yum.repos.d]# cat /etc/sysconfig/network-scripts/ifcfg-eth3.100
DEVICE=eth3.100 
TYPE=Ethernet 
IPADDR=10.10.100.11 
PREFIX=24 
ONBOOT=yes 
BOOTPROTO=none 
NAME=PRI-STOR 
VLAN=yes 
USERCTL=no 
MTU=9000 
[root@CSMAN yum.repos.d]# cat /etc/sysconfig/network-scripts/ifcfg-eth3.101
DEVICE=eth3.101 
TYPE=Ethernet 
IPADDR=10.10.101.11 
PREFIX=24 
ONBOOT=yes 
BOOTPROTO=none 
NAME=SEC-STOR 
VLAN=yes 
USERCTL=no 
MTU=9000 
```

Be notice the networking of eth1 should changes to following, for NatNetwork
won't give us the priviledge of accessing internet.     

![/images/2015_12_26_13_23_34_509x313.jpg](/images/2015_12_26_13_23_34_509x313.jpg)    

### CloudStack Configuration
#### SELinux
Change selinux to permissive:    

```
[root@csman ~]# cat /etc/selinux/config 

SELINUX=permissive
[root@csman ~]# reboot

```

#### Hostname

```
[root@csman ~]# cat /etc/sysconfig/network
NETWORKING=yes
HOSTNAME=csman
GATEWAY=192.168.56.1
[root@csman ~]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
localhost.cstack.local
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.56.11   csman.cstack.local      csman
192.168.56.101  xenserver.cstack.local  xenserver
```

#### NTP
Install ntp service via:    

```
[root@csman ~]# yum install -y ntp
[root@csman ~]# service ntpd start
Starting ntpd:                                             [  OK  ]
[root@csman ~]# chkconfig ntpd on
```

#### Necessary Packages
Install them via following command, for these tools will be useful during
installation.    

```
# yum install -y python-pip wget nethogs
```

#### MySQL
Install and configure:    

```
# yum install -y mysql-server MySQL-python
# vim /etc/my.cnf
    + # CloudStack MySQL settings
    + innodb_rollback_on_timeout=1
    + innodb_lock_wait_timeout=600
    + max_connections=700
    + log-bin=mysql-bin
    + binlog-format = 'ROW'
    + bind-address=0.0.0.0

    [mysqld_safe]
```
Save the service and start it:   

```
# service mysqld start
# chkconfig mysqld on
```
Drop the anonymous user and test database:    

```
[root@csman ~]# mysql
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 2
Server version: 5.1.73-log Source distribution

Copyright (c) 2000, 2013, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> drop user ''@'csman';
Query OK, 0 rows affected (0.00 sec)

mysql> drop user ''@'localhost';
Query OK, 0 rows affected (0.00 sec)

mysql> select user,host,password from mysql.user;
+------+-----------+----------+
| user | host      | password |
+------+-----------+----------+
| root | localhost |          |
| root | csman     |          |
| root | 127.0.0.1 |          |
+------+-----------+----------+
3 rows in set (0.00 sec)

mysql> delete from mysql.db where db like 'test%';
Query OK, 2 rows affected (0.00 sec)

mysql> select * from mysql.db;
Empty set (0.01 sec)

mysql> drop database test;
Query OK, 0 rows affected (0.00 sec)

mysql> flush privileges;
Query OK, 0 rows affected (0.00 sec)

mysql> \q
Bye
```
Run `mysql_secure_installation` to set the user password, and remove anonymous
uses.   

#### CloudStack-Management
Install via:    

```
# yum install -y cloudstack-management
```

#### cloudmonkey
Install it via:    

```
$ pip install cloudmonkey
```
But the installed cloudmonkey won't be used, later will be fixed.   

#### Configure database

```
[root@csman ~]# cloudstack-setup-databases cloud:engine123@127.0.0.1  --deploy-as root:engine123
[root@csman ~]# cloudstack-setup-management
```

#### NFS
Create the nfs related folders and configuration files.    

```
[root@csman ~]# mkdir /exports
[root@csman ~]# mkdir -p /exports/secondary
[root@csman ~]# mkdir -p /exports/primary
[root@csman ~]# echo "/exports/primary 10.10.100.0/24(rw,async,no_root_squash)">/etc/exports
[root@csman ~]# echo "/exports/primary 10.10.101.0/24(rw,async,no_root_squash)">>/etc/exports
[root@csman ~]# cat /etc/exports 
/exports/primary 10.10.100.0/24(rw,async,no_root_squash)
/exports/primary 10.10.101.0/24(rw,async,no_root_squash)
# service nfs start
# exportfs -a
# chkconfig nfs on
# chkconfig rpcbind on
# chmod 777 -R /exports/
```
update the configuration of /etc/sysconfig/nfs:    

```
# sed -i -e '/#MOUNTD_NFS_V3="no"/ c\MOUNTD_NFS_V3="yes"' -e '/#RQUOTAD_PORT=875/ c\RQUOTAD_PORT=875' -e '/#LOCKD_TCPPORT=32803/ c\LOCKD_TCPPORT=32803' -e '/#LOCKD_UDPPORT=32769/ c\LOCKD_UDPPORT=32769' -e '/#MOUNTD_PORT=892/ c\MOUNTD_PORT=892' -e '/#STATD_PORT=662/ c\STATD_PORT=662' -e '/#STATD_OUTGOING_PORT=2020/ c\STATD_OUTGOING_PORT=2020' /etc/sysconfig/nfs
```

#### Iptables
Add following configuraitons:   

```
# sed -i -e "/:OUTPUT/ a\-A INPUT -p tcp -m tcp --dport 111 -j ACCEPT" /etc/sysconfig/iptables
# sed -i -e "/:OUTPUT/ a\-A INPUT -p udp -m udp --dport 111 -j ACCEPT" /etc/sysconfig/iptables
# sed -i -e "/:OUTPUT/ a\-A INPUT -p tcp -m tcp --dport 2049 -j ACCEPT" /etc/sysconfig/iptables
# sed -i -e "/:OUTPUT/ a\-A INPUT -p udp -m udp --dport 2049 -j ACCEPT" /etc/sysconfig/iptables
# sed -i -e "/:OUTPUT/ a\-A INPUT -p tcp -m tcp --dport 2020 -j ACCEPT" /etc/sysconfig/iptables
# sed -i -e "/:OUTPUT/ a\-A INPUT -p tcp -m tcp --dport 32803 -j ACCEPT" /etc/sysconfig/iptables
# sed -i -e "/:OUTPUT/ a\-A INPUT -p udp -m udp --dport 32769 -j ACCEPT" /etc/sysconfig/iptables
# sed -i -e "/:OUTPUT/ a\-A INPUT -p tcp -m tcp --dport 892 -j ACCEPT" /etc/sysconfig/iptables
# sed -i -e "/:OUTPUT/ a\-A INPUT -p udp -m udp --dport 892 -j ACCEPT" /etc/sysconfig/iptables
# sed -i -e "/:OUTPUT/ a\-A INPUT -p tcp -m tcp --dport 875 -j ACCEPT" /etc/sysconfig/iptables
# sed -i -e "/:OUTPUT/ a\-A INPUT -p udp -m udp --dport 875 -j ACCEPT" /etc/sysconfig/iptables
# sed -i -e "/:OUTPUT/ a\-A INPUT -p tcp -m tcp --dport 662 -j ACCEPT" /etc/sysconfig/iptables
# sed -i -e "/:OUTPUT/ a\-A INPUT -p udp -m udp --dport 662 -j ACCEPT" /etc/sysconfig/iptables
```
Restart the iptables restart:    

```
# service iptables restart
# servcie nfs restart
```

#### nginx
Install nginx via:    

```
# echo "[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=0
enabled=1" > /etc/yum.repos.d/nginx.repo
# yum install nginx -y
# sed -i -e "/:OUTPUT/ a\-A INPUT -p tcp -m tcp --dport 80 -j ACCEPT" /etc/sysconfig/iptables
# service iptables restart
# cd /usr/share/nginx/html/
# scp dash@192.168.177.11:/home/dash/Downloads/centos56-x86_64.vhd.bz2 ./
```

####  vhd-util
Download the vhd-util, cause we want to use xenserver:    

```
# cd /usr/share/cloudstack-common/scripts/vm/hypervisor/xenserver/
# wget http://download.cloud.com.s3.amazonaws.com/tools/vhd-util
# chmod 777 vhd-util 
```

#### Cloudstack Usage Server

```
# yum install cloudstack-usage -y
# service cloudstack-usage start
```

#### System VM

```
#  /usr/share/cloudstack-common/scripts/storage/secondary/cloud-install-sys-tmplt -m /exports/secondary -u http://192.168.177.13/systemvm64template-4.5-xen.vhd.bz2 -h xenserver -F
```

#### HVM Configuration
Configure the management-server's configuration for xenserver's checking hvm to false:    

```
[root@csman ~]# mysql -pengine123 cloud -e \ "INSERT INTO cloud.configuration (category, instance, component, name, value, description) VALUES ('Advanced', 'DEFAULT', 'management-server', 'xen.check.hvm', 'false', 'Shoud we allow only the XenServers support HVM');"
```



### XenServer

Install it in virtualbox:    

![/images/2015_12_26_16_28_02_719x443.jpg](/images/2015_12_26_16_28_02_719x443.jpg)    

Usage of the disk:    
![/images/2015_12_26_16_29_55_722x406.jpg](/images/2015_12_26_16_29_55_722x406.jpg)    

![/images/2015_12_26_16_31_36_717x401.jpg](/images/2015_12_26_16_31_36_717x401.jpg)    

IP Address:   

![/images/2015_12_26_16_33_27_719x403.jpg](/images/2015_12_26_16_33_27_719x403.jpg)   

Network:    

![/images/2015_12_26_16_34_39_444x261.jpg](/images/2015_12_26_16_34_39_444x261.jpg)    

Change the timezone to `Asia/Shanghai`, and configure the ntp:    

![/images/2015_12_26_16_36_39_535x239.jpg](/images/2015_12_26_16_36_39_535x239.jpg)    

Click continue and run installation.   

Skip the Supplemental Package:    

![/images/2015_12_26_16_40_20_436x213.jpg](/images/2015_12_26_16_40_20_436x213.jpg)    

After installation, the vm become like this:    

![/images/2015_12_26_16_50_36_639x403.jpg](/images/2015_12_26_16_50_36_639x403.jpg)    

### XenServer Plugin
Configure the memory Usage:    

```
[root@xenserver ~]# /opt/xensource/libexec/xen-cmdline --set-xen dom0_mem=400M,max:2248M
``` 

First without patch, adding to the cloudstack management server.   
