---
layout: post
title: "Move SpaceWalk Server Into A New Network"
date: 2015-08-22 16:49:19 +0800
comments: true
categories: Linux
---
### Env
Move from one isolated network to another isolated network. Experiment is done on
virt-manager, from 10.9.10.0/24 to 10.47.58.0/24 network. Following are the steps for
migration.      

### Steps
First shutdown the machine and connect the existing network card to new network, boot
on the computer.    

Modify the ip address(static IP Address):    

```
$ sudo vim /etc/sysconfig/network-scripts/ifcfg-eth0
- IPADDR=10.9.10.13
- GATEWAY=10.9.10.1
+ IPADDR=10.47.58.3
+ GATEWAY=10.47.58.1
```
Modify the hostname:    

```
# vim /etc/hosts
- 10.9.10.13      spacewalker
+ 10.47.58.3      spacewalker
```

Modify the dhcpd configuration:    

```
$ sudo vim /etc/dhcp/dhcpd.conf
#  specify network address and subnet mask
-  subnet 10.9.10.0 netmask 255.255.255.0 {
-      # specify the range of lease IP address
-      range dynamic-bootp 10.9.10.200 10.9.10.254;
-      # specify broadcast address
-      option broadcast-address 10.9.10.255;
-      # specify default gateway
-      option routers 10.9.10.1;
-      # Specify default dns server
-      option domain-name-servers 10.9.10.13;
-  }

+ subnet 10.47.58.0 netmask 255.255.255.0 {
+     # specify the range of lease IP address
+     range dynamic-bootp 10.47.58.200 10.47.58.254;
+     # specify broadcast address
+     option broadcast-address 10.47.58.255;
+     # specify default gateway
+     option routers 10.47.58.1;
+     # Specify default dns server
+     option domain-name-servers 10.47.58.3;
+     filename                   "/pxelinux.0";       
+     # default-lease-time         21600;           
+     # max-lease-time             43200;      
+     next-server                10.47.58.3; 
+ 
+ }
```

DNS Server Configuration:    

```
$ sudo vim /etc/named.conf

options {
        - listen-on port 53 { 127.0.0.1; 10.9.10.13;};
        + listen-on port 53 { 127.0.0.1; 10.47.58.3;};
//.................
        
	- allow-query     { localhost; 10.9.10.0/24;};
        + allow-query     { localhost; 10.47.58.0/24;};
```

DNS Server DB Change:    

```
$ sudo vim /etc/named/zones/db.spacewalker
- spacewalker.         IN      A       10.9.10.13
+ spacewalker.         IN      A       10.47.58.3
```

Reboot and check the result:    

```
[root@spacewalker ~]# ps -ef | grep dhcp
dhcpd      848     1  0 17:02 ?        00:00:00 /usr/sbin/dhcpd -f -cf
/etc/dhcp/dhcpd.conf -user dhcpd -group dhcpd --no-pid
root      2208  2186  0 17:03 pts/0    00:00:00 grep --color=auto dhcp
[root@spacewalker ~]# ps -ef | grep name
named     1031     1  0 17:02 ?        00:00:00 /usr/sbin/named -u named
root      2210  2186  0 17:03 pts/0    00:00:00 grep --color=auto name
[root@spacewalker ~]# hostname --fqdn
spacewalker
[root@spacewalker tftpboot]# netstat -anp | grep 69 | grep xinetd
udp        0      0 0.0.0.0:69              0.0.0.0:*  841/xinetd  
```

Now bootup a machine and add it to the 10.47.58.0/24 network, your machine will be boot
into pxe menu, thus you could reinstall your machine.   

