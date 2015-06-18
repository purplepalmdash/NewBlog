---
layout: post
title: "WH Worktips(1)"
date: 2015-06-17 14:55:39 +0800
comments: true
categories: Virtualization
---
### Preparation
Hardware: 2G Memory, 1-Core, the Cobbler Server, which runs CentOS6.6.     
Network: Use a 10.47.58.0/24(Its name is WHNetwork), no dhcp server in this network.    

### Cobbler Server Preparation
First Change its IP address to 10.47.58.2, gateway to 10.47.58.1.     

```
[root@z_WHServer ~]# cat /etc/sysconfig/network-scripts/ifcfg-eth0 
DEVICE=eth0
TYPE=Ethernet
UUID=a6e5b56f-661f-4128-ab8c-c575a9623245
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=none
IPADDR=10.47.58.2
GATEWAY=10.47.58.1
......

[root@z_WHServer ~]# cat /etc/sysconfig/network
NETWORKING=yes
HOSTNAME=z_WHServer
# vim /etc/selinux/config
    #SELINUX=enforcing
    SELINUX=disabled 
# reboot
```

Install and configure Cobbler Server via:    

```
# yum -y update && yum install -y cobbler cobbler-web
# reboot
# openssl passwd -1                                                                                                     │
Password:                                                                                                                                 │
Verifying - Password:                                                                                                                     │
igaowugoauwgoueougo
# vim /etc/cobbler/settings
    default_password_crypted: "agowuoguwoawoguwoe"
    # default, localhost
    server: 10.47.58.2
    # default, localhost
    next_server: 10.47.58.2
    manage_dhcp: 1
```

Edit the dhcp template:     

```
# vim /etc/cobbler/dhcp.template
####  subnet 192.168.1.0 netmask 255.255.255.0 {
####       option routers             192.168.1.5;
####       option domain-name-servers 192.168.1.1;
####       option subnet-mask         255.255.255.0;
####       range dynamic-bootp        192.168.1.100 192.168.1.254;
####       default-lease-time         21600;
####       max-lease-time             43200;
####       next-server                $next_server;
subnet 10.47.58.0 netmask 255.255.255.0 {
     option routers             10.47.58.1; 
     range dynamic-bootp        10.47.58.3 10.47.58.254;
     option domain-name-servers 114.114.114.114, 180.76.76.76;     
     option subnet-mask         255.255.255.0;         
     filename                   "/pxelinux.0";       
     default-lease-time         21600;           
     max-lease-time             43200;      
     next-server                $next_server; 

     class "pxeclients" {
```

Check via:     

```
[root@z_WHServer ~]# service cobblerd start
Starting cobbler daemon:                                   [  OK  ]
[root@z_WHServer ~]# chkconfig cobblerd on
[root@z_WHServer ~]# chkconfig httpd on
[root@z_WHServer ~]# service cobblerd status
cobblerd (pid 5421) is running...
```
Reboot and Check via:     

```
# cobbler check
```
You will get lots of the errors, first solve the dhcpd issue, notice the following dhcpd configuration file is temporarily used.      

```
# yum install -y dhcp
# vim /etc/dhcp/dhcpd.conf
#
# DHCP Server Configuration file.
#   see /usr/share/doc/dhcp*/dhcpd.conf.sample
#   see 'man 5 dhcpd.conf'
#
# create new
# specify domain name
option domain-name "server.world";
# specify name server's hostname or IP address
option domain-name-servers dlp.server.world;
# default lease time
default-lease-time 600;
# max lease time
max-lease-time 7200;
# this DHCP server to be declared valid
authoritative;
# specify network address and subnet mask
subnet 10.47.58.0 netmask 255.255.255.0 {
    # specify the range of lease IP address
    range dynamic-bootp 10.47.58.200 10.47.58.254;
    # specify broadcast address
    option broadcast-address 10.47.58.255;
    # specify default gateway
    option routers 10.47.58.1;
}
# service dhcpd start
# chkconfig dhcpd on
# chkconfig xinetd on
# reboot
```

Get loaders to download the loaders to `/var/lib/cobbler/loaders`:    
!!! Notice, this step maybe failed because of networking issues!!!!     

```
$ cobbler get-loaders
```

Change xinted:    

```
# cat  /etc/xinetd.d/rsync 
# default: off
# description: The rsync server is a good addition to an ftp server, as it \
#       allows crc checksumming etc.
service rsync
{
        disable = no

```

Edit iptables:     

```
$ sudo vim /etc/sysconfig/iptables
:OUTPUT ACCEPT [0:0]
-A INPUT -p udp -m multiport --dports 69,80,443,25151 -j ACCEPT 
-A INPUT -p tcp -m multiport --dports 69,80,443,25151 -j ACCEPT 
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
$ sudo reboot
```

Install packages:     

```
# yum install -y debmirror pykickstart cman
# cobbler check
# cobbler sync
```

### Import Systems
Import 2 DVD iso via:    

```
# mount -o loop -t iso9660 CentOS-6.5-x86_64-bin-DVD1.iso  /mnt1/
# cobbler import --name=CentOS-6.5 --arch=x86_64 --path=/mnt1
# mount -o loop -t iso9660 CentOS-6.5-x86_64-bin-DVD2.iso  /mnt2
# rsync -a '/mnt2/' /var/www/cobbler/ks_mirror/CentOS-6.5-x86_64/ --exclude-from=/etc/cobbler/rsync.exclude --progress
# COMPSXML=$(ls /var/www/cobbler/ks_mirror/CentOS-6.5-x86_64/repodata/*comps*.xml)
# createrepo -c cache -s sha --update --groupfile ${COMPSXML} /var/www/cobbler/ks_mirror/CentOS-6.5-x86_64/ 
```

Verify it via:    

```
[root@z_WHServer repodata]# cobbler distro list
   CentOS-6.5-x86_64
[root@z_WHServer repodata]# cobbler profile list
   CentOS-6.5-x86_64
[root@z_WHServer repodata]# cobbler distro report --name=CentOS-6.5-x86_64
Name                           : CentOS-6.5-x86_64
Architecture                   : x86_64
TFTP Boot Files                : {}
Breed                          : redhat
Comment                        : 
Fetchable Files                : {}
Initrd                         : /var/www/cobbler/ks_mirror/CentOS-6.5-x86_64/images/pxeboot/initrd.img
Kernel                         : /var/www/cobbler/ks_mirror/CentOS-6.5-x86_64/images/pxeboot/vmlinuz
```
Check if your tftp working:     

```
# yum install tftp-server
# vim /etc/xinetd.d/tftp
# /sbin/chkconfig tftp on
# service xinetd start
# netstat -anp | grep 69
# tftp 10.47.58.2
get pxelinux.0
```
If successful, the pxelinux.0 will downloaded to your directory.    

### Install New Systems
Use a machine, configure to the same network, then start from pxe.    

### Customize the KS file
Generate kickstart configuration file via:    

```
# system-config-kickstart 
```
Add a new profile via:    

```
[root@z_WHServer kickstarts]# cobbler profile add --name=CentOS6.5-Desktop --kickstart=/var/lib/cobbler/kickstarts/CentOS-6.5-x86_64/C
sktop.cfg --distro=CentOS-6.5-x86_64
[root@z_WHServer kickstarts]# cobbler profile list
   CentOS-6.5-x86_64
   CentOS6.5-Desktop
```

### Cobbler Web Interface

```
$ htdigest /etc/cobbler/users.digest "Cobbler" cobbler 
Which will prompt you for a new password. 
Once you have updated the password remember to run
$ cobbler sync
```
