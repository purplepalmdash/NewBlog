---
layout: post
title: "Install CloudStack Mgmt Server On CentOS7"
date: 2016-01-11 15:03:38 +0800
comments: true
categories: virtualization
---
### Steps
Disable selinux:    

```
# setenforce permissive
# vim /etc/selinux/config 
SELINUX=permissive
```

Edit the hostname and hosts file:    

```
[root@csman ~]# cat /etc/hostname 
csman
[root@csman ~]# cat /etc/hosts
127.0.0.1 localhost localhost.cstack.local
192.168.56.12 csman.cstack.local csman
192.168.56.101 xenserver.cstack.local xenserver
```

Enable the ntp server:    

```
# yum install -y ntp
# chkconfig ntpd on
# service ntpd start
```
Configure the nfs sharing:    

```
# mkdir /exports
# mkdir -p /exports/primary
# mkdir -p /exports/secondary
# chmod 777 -R /exports
# echo "/exports/primary 10.10.100.0/24(rw,async,no_root_squash)" > /etc/exports
# echo "/exports/secondary 10.10.101.0/24(rw,async,no_root_squash)" >> /etc/exports
# exportfs -a
```

Configure the nfs ruls:    

```
# sed -i -e '/#MOUNTD_NFS_V3="no"/ c\MOUNTD_NFS_V3="yes"' -e '/#RQUOTAD_PORT=875/ c\RQUOTAD_PORT=875' -e '/#LOCKD_TCPPORT=32803/ c\LOCKD_TCPPORT=32803' -e '/#LOCKD_UDPPORT=32769/ c\LOCKD_UDPPORT=32769' -e '/#MOUNTD_PORT=892/ c\MOUNTD_PORT=892' -e '/#STATD_PORT=662/ c\STATD_PORT=662' -e '/#STATD_OUTGOING_PORT=2020/ c\STATD_OUTGOING_PORT=2020' /etc/sysconfig/nfs
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
# service iptables restart
# chkconfig nfs on
# service nfs restart
```

Install the packages:    

```
# yum install -y cloudstack-management
# yum -y install mariadb-server mariadb
```

Configure the mariadb:    

```
# sed -i -e '/datadir/ a\innodb_rollback_on_timeout=1' -e '/datadir/ a\innodb_lock_wait_timeout=600' -e '/datadir/ a\max_connections=350' -e '/datadir/ a\log-bin=mysql-bin' -e "/datadir/ a\binlog-format = 'ROW'" -e "/datadir/ a\bind-address = 0.0.0.0" /etc/my.cnf
# systemctl enable mariadb
# systemctl start mariadb
# systemctl start mariadb.service
# mysql_secure_installation
```

Setup the privileges:    

```
[root@csman system]# mysql -u root -pengine123
MariaDB [(none)]> GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
MariaDB [(none)]> quit
```

Setup the management database and setup the managment server:    

```
# cloudstack-setup-databases cloud:<password>@127.0.0.1 --deploy-as=root:<password>
# cloudstack-setup-management --tomcat7
# service cloudstack-management start
# /bin/systemctl enable  cloudstack-management.service
```

Nginx:    

```
# echo "[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=0
enabled=1" > /etc/yum.repos.d/nginx.repo
# yum install nginx -y
# cd /usr/share/nginx/html
# wget -nc http://download.cloud.com/templates/builtin/centos56-x86_64.vhd.bz2
# sed -i -e "/:OUTPUT/ a\-A INPUT -p tcp -m tcp --dport 80 -j ACCEPT" /etc/sysconfig/iptables
# service iptables restart
```

vhd-utils:    

```
# cd /usr/share/cloudstack-common/scripts/vm/hypervisor/xenserver/
# wget http://download.cloud.com.s3.amazonaws.com/tools/vhd-util
# chmod 755 /usr/share/cloudstack-common/scripts/vm/hypervisor/xenserver/vhd-util
```

SystemVM Template:    

```
# /usr/share/cloudstack-common/scripts/storage/secondary/cloud-install-sys-tmplt -m /exports/secondary -u http://xxxxxxxxxxxxx -h xenserver -F
```

CloudStack usage server:    

```
# yum install cloudstack-usage -y
# service cloudstack-usage start
```
Mysql related:    

```
# mysql -p<password> cloud -e \ "INSERT INTO cloud.configuration (category, instance, component, name, value, description) VALUES ('Advanced', 'DEFAULT', 'management-server', 'xen.check.hvm', 'false', 'Shoud we allow only the XenServers support HVM');"

```
### If KVM
Install bridge-utils:    

```
# yum install -y bridge-utils
```

Edit the bridge connections:   

```
# cat /etc/sysconfig/network-scripts/ifcfg-eth0 
DEVICE="eth0"
ONBOOT="yes"
BOOTPROTO=none
NM_CONTROLLED="no"
BRIDGE="cloudbr0"
TYPE=Ethernet
# cat /etc/sysconfig/network-scripts/ifcfg-cloudbr0
DEVICE="cloudbr0"
ONBOOT="yes"
NM_CONTROLLED=yes
TYPE="Bridge"
BOOTPROTO=static
IPADDR=10.47.58.11
NETMASK=255.255.255.0
GATEWAY=10.47.58.1
DNS1=223.5.5.5
DEFROUTE=yes
```


### Building 4.5.2/4.5.1 For CentOS 7
Key-Step:    

[http://zooi.widodh.nl/cloudstack/build-dep/cloud-manageontap.jar](http://zooi.widodh.nl/cloudstack/build-dep/cloud-manageontap.jar)    



