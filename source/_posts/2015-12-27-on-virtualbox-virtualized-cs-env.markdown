---
layout: post
title: "On Virtualbox Virtualized CS env"
date: 2015-12-27 10:07:39 +0800
comments: true
categories: Virtualization
---
Using Virtualbox for building the testing env of cloudstack together with
elastistor.     

### Networking
Host-only 1: 192.168.56.1/24, no DHCP.     
Host-only 2: 172.30.0.1/24, no DHCP.     
Host-only 3: 10.10.100.1/24, no DHCP.     

### Virtual Machine
#### Machine 1
For installing CentOS 6.7 based CloudStack 4.5.2.    

```
name: csman
Type: Linux
Version: Red Hat(64-bit) 
Memory: 4096 MB
Create  a virtual hard drive now
Choosing VDI
Choose Dynamically allocated
Select the size: adjusting to 80.00 GB
Setting: 
Adjust CPU Processor to 2
Storage: Choosing CentOS6.7 DVD 1. 
Controller: SATA, Choosing "Use Host I/O Cache", this will greatly improve the
speed.
Network, The Adpter 1, choosing NAT for default. 
Click Start for installing.   
Choosing Basic Server in installing, enable eth0 for dhcp.    
```
After installation, shutdown the VM, add the second adapter.   
Configure the newly-added eth1:    

```
# vim /etc/sysconfig/network-scripts/ifcfg-eth1 
DEVICE=eth1
TYPE=Ethernet
IPADDR=192.168.56.11
PREFIX=24
ONBOOT=yes
NM_CONTROLLED=no
BOOTPROTO=none
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
NAME=MGMT
```

Shutdown the vm again , add the third adapter, Configure the newly-added eth2:    

```
[root@csman ~]# cat /etc/sysconfig/network-scripts/ifcfg-eth2 
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

```

Shutdown the vm again ,this time add eth3, and configure it:   

```
[root@csman ~]# cat /etc/sysconfig/network-scripts/ifcfg-eth3
DEVICE=eth3
TYPE=Ethernet
IPADDR=10.10.100.11
PREFIX=24
NAME=STOR
BOOTPROTO=none
ONBOOT=yes
MTU=9000
VLAN=yes
USERCTL=no
MTU=9000

```

Comparing to the guideline, eth3 didn't add vlan tagged networking.  

#### Machine 2
For installing Xenserver, which will connected to above cloudstack management
server.   

```
name: XenServer
Type: Linux
Version: Red Hat(64-bit)
Memory: 8192 MB(more than 3072 is OK)
Create a virtual hard drive now
Choosing VDI
Choose Dynamically allocated
Select the size: adjusting to 120.00 GB
Setting: 
Adjust CPU Processor to 4
Storage: Choosing XenServer-6.2.0-install-cd.iso
Controller: SATA, "Use Host I/O Cache"
Audio: Disable
Network: Adapter 1, choosing Host-only Adapter, Name choosing vboxnet,
Advanced choosing Promiscuous Mode: allow all. 
Click Start for installing.  
Networking: 192.168.56.101/255.255.255.0, gateway,192.168.56.1
Hostname: xenserver
DNS Server 1: 180.76.76.76
DNS Server 2: 223.5.5.5
DNS Server 3: 8.8.8.8
Timezone: Asia/Shanghai
NTP Server 1: 3.cn.pool.ntp.org
NTP Server 2: 3.asia.pool.ntp.org
NTP Server 3: cn.ntp.org.cn
```
After installation, shutdown, and add a new adapter, scan it in XenCenter.   

#### Machine 3
Windows 7, for installing xen desktop management tool. Which could attaches to
host-only adatper 1, with a 192.168.56.0/24 address.   

#### Machine 4
4G/2 Core, For installing the Elastistor. 

#### CloudStack(Machine 1)
Selinux:     

```
# sed -i "/SELINUX=enforcing/ c\SELINUX=permissive" /etc/selinux/config
```
Hostname, change `/etc/hosts` file:    

```
127.0.0.1 localhost localhost.cstack.local
192.168.56.11 csman.cstack.local csman
192.168.56.101 xenserver.cstack.local xenserver
```
NTP Installation:    

```
# yum install -y ntp
# chkconfig ntpd on
# service ntpd start
```
Install cloudstack/mysql:    

```
# yum install -y cloudstack-management mysql-server
```
NFS configuration:   

```
# mkdir /exports
# mkdir -p /exports/primary
# mkdir -p /exports/secondary
# chmod 777 -R /exports
# echo "/exports/primary 10.10.100.0/24(rw,async,no_root_squash)" > /etc/exports
# echo "/exports/secondary 10.10.100.0/24(rw,async,no_root_squash)" >> /etc/exports
# exportfs -a
```
sysconfig for nfs:    

```
# sed -i -e '/#MOUNTD_NFS_V3="no"/ c\MOUNTD_NFS_V3="yes"' -e '/#RQUOTAD_PORT=875/ c\RQUOTAD_PORT=875' -e '/#LOCKD_TCPPORT=32803/ c\LOCKD_TCPPORT=32803' -e '/#LOCKD_UDPPORT=32769/ c\LOCKD_UDPPORT=32769' -e '/#MOUNTD_PORT=892/ c\MOUNTD_PORT=892' -e '/#STATD_PORT=662/ c\STATD_PORT=662' -e '/#STATD_OUTGOING_PORT=2020/ c\STATD_OUTGOING_PORT=2020' /etc/sysconfig/nfs
```
Iptables configuration:    

```
sed -i -e "/:OUTPUT/ a\-A INPUT -p tcp -m tcp --dport 111 -j ACCEPT" /etc/sysconfig/iptables
sed -i -e "/:OUTPUT/ a\-A INPUT -p udp -m udp --dport 111 -j ACCEPT" /etc/sysconfig/iptables
sed -i -e "/:OUTPUT/ a\-A INPUT -p tcp -m tcp --dport 2049 -j ACCEPT" /etc/sysconfig/iptables
sed -i -e "/:OUTPUT/ a\-A INPUT -p udp -m udp --dport 2049 -j ACCEPT" /etc/sysconfig/iptables
sed -i -e "/:OUTPUT/ a\-A INPUT -p tcp -m tcp --dport 2020 -j ACCEPT" /etc/sysconfig/iptables
sed -i -e "/:OUTPUT/ a\-A INPUT -p tcp -m tcp --dport 32803 -j ACCEPT" /etc/sysconfig/iptables
sed -i -e "/:OUTPUT/ a\-A INPUT -p udp -m udp --dport 32769 -j ACCEPT" /etc/sysconfig/iptables
sed -i -e "/:OUTPUT/ a\-A INPUT -p tcp -m tcp --dport 892 -j ACCEPT" /etc/sysconfig/iptables
sed -i -e "/:OUTPUT/ a\-A INPUT -p udp -m udp --dport 892 -j ACCEPT" /etc/sysconfig/iptables
sed -i -e "/:OUTPUT/ a\-A INPUT -p tcp -m tcp --dport 875 -j ACCEPT" /etc/sysconfig/iptables
sed -i -e "/:OUTPUT/ a\-A INPUT -p udp -m udp --dport 875 -j ACCEPT" /etc/sysconfig/iptables
sed -i -e "/:OUTPUT/ a\-A INPUT -p tcp -m tcp --dport 662 -j ACCEPT" /etc/sysconfig/iptables
sed -i -e "/:OUTPUT/ a\-A INPUT -p udp -m udp --dport 662 -j ACCEPT" /etc/sysconfig/iptables
service iptables restart
```
nfs service:    

```
# chkconfig nfs on
# service nfs start
```
MySQL Server Configuration:    

```
# sed -i -e '/datadir/ a\innodb_rollback_on_timeout=1' -e '/datadir/ a\innodb_lock_wait_timeout=600' -e '/datadir/ a\max_connections=350' -e '/datadir/ a\log-bin=mysql-bin' -e "/datadir/ a\binlog-format = 'ROW'" -e "/datadir/ a\bind-address = 0.0.0.0" /etc/my.cnf
# chkconfig mysqld on
# service mysqld start
# mysql_secure_installation
# mysql -u root -p  (enter password when prompted)
mysql> GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
mysql> quit
```
Setup Database:     

```
# cloudstack-setup-databases cloud:<password>@127.0.0.1 --deploy-as=root:<password>
# cloudstack-setup-management
```
vhd-util:    

```
# cd /usr/share/cloudstack-common/scripts/vm/hypervisor/xenserver/
# wget http://download.cloud.com.s3.amazonaws.com/tools/vhd-util
# chmod 755 /usr/share/cloudstack-common/scripts/vm/hypervisor/xenserver/vhd-util
```
System VM template:     

```
# /usr/share/cloudstack-common/scripts/storage/secondary/cloud-install-sys-tmplt -m /exports/secondary/ -u http://192.168.177.13/systemvm64template-4.5-xen.vhd.bz2 -h xenserver -F
```

### Customization
Don't check hvm for xenserver:   

```
# mysql -p<YOURPASSWORD> cloud -e \ "INSERT INTO cloud.configuration (category, instance, component, name, value, description) VALUES ('Advanced', 'DEFAULT', 'management-server', 'xen.check.hvm', 'false', 'Shoud we allow only the XenServers support HVM');"

```
Install cloudstack-usage:    

```
# yum install cloudstack-usage -y
# service cloudstack-usage start
```
Disable the HVM:    

```
# mysql -p<password> cloud -e \ "INSERT INTO cloud.configuration (category, instance, component, name, value, description) VALUES ('Advanced', 'DEFAULT', 'management-server', 'xen.check.hvm', 'false', 'Shoud we allow only the XenServers support HVM');"
```
Global Setting:    

```
mysql -u cloud -p<password>
UPDATE cloud.configuration SET value='8096' WHERE name='integration.api.port';
UPDATE cloud.configuration SET value='60' WHERE name='expunge.delay';
UPDATE cloud.configuration SET value='60' WHERE name='expunge.interval';
UPDATE cloud.configuration SET value='60' WHERE name='account.cleanup.interval';
UPDATE cloud.configuration SET value='60' WHERE name='capacity.skipcounting.hours';
UPDATE cloud.configuration SET value='0.99' WHERE name='cluster.cpu.allocated.capacity.disablethreshold';
UPDATE cloud.configuration SET value='0.99' WHERE name='cluster.memory.allocated.capacity.disablethreshold';
UPDATE cloud.configuration SET value='0.99' WHERE name='pool.storage.capacity.disablethreshold';
UPDATE cloud.configuration SET value='0.99' WHERE name='pool.storage.allocated.capacity.disablethreshold';
UPDATE cloud.configuration SET value='60000' WHERE name='capacity.check.period';
UPDATE cloud.configuration SET value='1' WHERE name='event.purge.delay';
UPDATE cloud.configuration SET value='60' WHERE name='network.gc.interval';
UPDATE cloud.configuration SET value='60' WHERE name='network.gc.wait';
UPDATE cloud.configuration SET value='600' WHERE name='vm.op.cleanup.interval';
UPDATE cloud.configuration SET value='60' WHERE name='vm.op.cleanup.wait';
UPDATE cloud.configuration SET value='600' WHERE name='vm.tranisition.wait.interval';
UPDATE cloud.configuration SET value='60' WHERE name='vpc.cleanup.interval';
UPDATE cloud.configuration SET value='4' WHERE name='cpu.overprovisioning.factor';
UPDATE cloud.configuration SET value='8' WHERE name='storage.overprovisioning.factor';
UPDATE cloud.configuration SET value='192.168.56.11/32' WHERE name='secstorage.allowed.internal.sites';
UPDATE cloud.configuration SET value='192.168.56.0/24' WHERE name='management.network.cidr';
UPDATE cloud.configuration SET value='192.168.56.11' WHERE name='host';
UPDATE cloud.configuration SET value='false' WHERE name='check.pod.cidrs';
UPDATE cloud.configuration SET value='0' WHERE name='network.throttling.rate';
UPDATE cloud.configuration SET value='0' WHERE name='vm.network.throttling.rate';
UPDATE cloud.configuration SET value='GMT' WHERE name='usage.execution.timezone';
UPDATE cloud.configuration SET value='16:00' WHERE name='usage.stats.job.exec.time';
UPDATE cloud.configuration SET value='true' WHERE name='enable.dynamic.scale.vm';
UPDATE cloud.configuration SET value='9000' WHERE name='secstorage.vm.mtu.size';
UPDATE cloud.configuration SET value='60' WHERE name='alert.wait';
UPDATE cloud.service_offering SET ram_size='128', speed='128' WHERE vm_type='domainrouter';
UPDATE cloud.service_offering SET ram_size='128', speed='128' WHERE vm_type='elasticloadbalancervm';
UPDATE cloud.service_offering SET ram_size='128', speed='128' WHERE vm_type='secondarystoragevm';
UPDATE cloud.service_offering SET ram_size='128', speed='128' WHERE vm_type='internalloadbalancervm';
UPDATE cloud.service_offering SET ram_size='128', speed='128' WHERE vm_type='consoleproxy';
UPDATE cloud.vm_template SET removed=now() WHERE id='2';
UPDATE cloud.vm_template SET url='http://192.168.56.11/centos56-x86_64.vhd.bz2' WHERE unique_name='centos56-x86_64-xen';
quit

service cloudstack-management restart
```

Add iptables rules and restart:    

```
# sed -i -e "/:OUTPUT/ a\-A INPUT -p tcp -m tcp --dport 8096 -j ACCEPT" /etc/sysconfig/iptables
# service iptables restart
```


