---
layout: post
title: "Setup the Cobbler Server"
date: 2015-05-14 09:38
comments: true
categories: Linux
---
The reference material is mainly from:    
[http://www.cobblerd.org/manuals/quickstart/](http://www.cobblerd.org/manuals/quickstart/)    
### Prepartion
First install the CentOS6.6, choose the basic server.   
After installation, update to the latest system via `yum -y update`.   
Disable the SELinux via:     

```
# vim /etc/selinux/config
#SELINUX=enforcing                                                                                                                       │
SELINUX=disabled 

```
Then restart the compute.    
Add epel repository:   

```
# wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
# yum update
# yum install -y cobbler cobbler-web

```
### Configuration
Change the default password:    

```
# openssl passwd -1                                                                                                     │
Password:                                                                                                                                 │
Verifying - Password:                                                                                                                     │
igaowugoauwgoueougo
[root@CobblerServer ~]# vim /etc/cobbler/settings          
default_password_crypted: "agowuoguwoawoguwoe"

```
Set the Server and Next_Server to the specified IP Address, DO NOT use 0.0.0.0:     

```
# default, localhost
server: 10.3.3.3.

# default, localhost
next_server: 10.3.3.3

```
Enable the dhcp managed:    

```
manage_dhcp: 0

```
Edit the dhcp template via:    

```
vi /etc/cobbler/dhcp.template
subnet 10.3.3.0 netmask 255.255.255.0 {
     option routers             10.3.3.1;                                                                                                  
     range dynamic-bootp        10.3.3.4 10.3.3.254;
     option domain-name-servers 114.114.114.114, 8.8.8.8;     
     option subnet-mask         255.255.255.0;         
     filename                   "/pxelinux.0";       
     default-lease-time         21600;           
     max-lease-time             43200;      
     next-server                $next_server; 
}          

```
Start and check the service status:   

```
[root@CobblerServer ~]# service cobblerd start                                                                                           
Starting cobbler daemon:                                   [  OK  ]
[root@CobblerServer ~]# chkconfig cobblerd on                     
[root@CobblerServer ~]# chkconfig httpd on                     
[root@CobblerServer ~]# service cobblerd status                  
cobblerd (pid 1564) is running...     

```
Better you restart the machine and verify your installation via:     

```
[root@CobblerServer ~]# cobbler check
The following are potential configuration items that you may want to fix:

1 : dhcpd is not installed
2 : some network boot-loaders are missing from /var/lib/cobbler/loaders, you may run 'cobbler get-loaders' to download them, or, if you only want to handle x86/x86_64 netbooting, you may ensure that you have installed a *recent* version of the syslinux package installed and can ignore this message entirely.  Files in this directory, should you want to support all architectures, should include pxelinux.0, menu.c32, elilo.efi, and yaboot. The 'cobbler get-loaders' command is the easiest way to resolve these requirements.
3 : change 'disable' to 'no' in /etc/xinetd.d/rsync
4 : since iptables may be running, ensure 69, 80/443, and 25151 are unblocked
5 : debmirror package is not installed, it will be required to manage debian deployments and repositories
6 : ksvalidator was not found, install pykickstart
7 : fencing tools were not found, and are required to use the (optional) power management features. install cman or fence-agents to use them

```
OOOOPs, so many errors, so first install dhcpd:     

```
# yum install -y dhcpd
# chkconfig dhcpd on
# chkconfig xinetd on

```
Manullly edit the dhcpd configuration file as in following files:     

```
[root@CobblerServer ~]# cat /etc/dhcp/dhcpd.conf 
#
# DHCP Server Configuration file.
#   see /usr/share/doc/dhcp*/dhcpd.conf.sample
#   see 'man 5 dhcpd.conf'
#
# create new
# specify domain name
option domain-name "server.world";
# specify name server's hostname or IP address
option domain-name-servers 114.114.114.114;
# default lease time
default-lease-time 600;
# max lease time
max-lease-time 7200;
# this DHCP server to be declared valid
authoritative;
# specify network address and subnet mask
subnet 10.3.3.0 netmask 255.255.255.0 {
    # specify the range of lease IP address
    range dynamic-bootp 10.3.3.4 10.3.3.254;
    # specify broadcast address
    option broadcast-address 10.3.3.255;
    # specify default gateway
    option routers 10.3.3.1;
}
# service dhcpd restart

```
One trouble after another, solve them:    
Get Loaders:    

```
[root@CobblerServer ~]# cobbler get-loaders

```
Enable the rsync configuration:   

```
  # vim /etc/xinetd.d/rsync 
        disable = no

```
Add the following lines into the /etc/sysconfig/iptables:     

```
:OUTPUT ACCEPT [0:0]
-A INPUT -p udp -m multiport --dports 69,80,443,25151 -j ACCEPT 
-A INPUT -p tcp -m multiport --dports 69,80,443,25151 -j ACCEPT 
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

```
Or:   

```
# iptables -I INPUT -p udp -m multiport --dports 69,80,443,25151 -j ACCEPT
# iptables -I INPUT -p tcp -m multiport --dports 69,80,443,25151 -j ACCEPT


```
The difference is the latter won't last for long once the machine got restarted.   

Install following packages:    

```
[root@CobblerServer ~]# yum install -y debmirror pykickstart cman

```
Now check again:   

```
$ cobbler check
$ cobbler sync

```
### Import ISO
I use the CentOS7 iso(CentOS-7-x86_64-Everything-1503-01.iso).    

```
[root@CobblerServer ~]# mount -o loop -t iso9660 ./CentOS-7-x86_64-Everything-1503-01.iso  /mnt
[root@CobblerServer ~]# cobbler import --name=CentOS-7 --arch=x86_64 --path=/mnt
path=/mnt
task started: 2015-05-14_035209_import
task started (id=Media import, time=Thu May 14 03:52:09 2015)
Found a candidate signature: breed=redhat, version=rhel6
Found a candidate signature: breed=redhat, version=rhel7
Found a matching signature: breed=redhat, version=rhel7
Adding distros from path /var/www/cobbler/ks_mirror/CentOS-7-x86_64:
creating new distro: CentOS-7-x86_64
trying symlink: /var/www/cobbler/ks_mirror/CentOS-7-x86_64 -> /var/www/cobbler/links/CentOS-7-x86_64
creating new profile: CentOS-7-x86_64
associating repos
checking for rsync repo(s)
checking for rhn repo(s)
checking for yum repo(s)
starting descent into /var/www/cobbler/ks_mirror/CentOS-7-x86_64 for CentOS-7-x86_64
processing repo at : /var/www/cobbler/ks_mirror/CentOS-7-x86_64
need to process repo/comps: /var/www/cobbler/ks_mirror/CentOS-7-x86_64
looking for /var/www/cobbler/ks_mirror/CentOS-7-x86_64/repodata/*comps*.xml
Keeping repodata as-is :/var/www/cobbler/ks_mirror/CentOS-7-x86_64/repodata
*** TASK COMPLETE ***

```
Check it via:    

```
[root@CobblerServer ~]# cobbler distro list
   CentOS-7-x86_64
[root@CobblerServer ~]# cobbler profile list
   CentOS-7-x86_64
[root@CobblerServer ~]# cobbler distro report --name=CentOS-7-x86_64
Name                           : CentOS-7-x86_64
Architecture                   : x86_64
TFTP Boot Files                : {}
Breed                          : redhat
Comment                        : 
Fetchable Files                : {}
Initrd                         : /var/www/cobbler/ks_mirror/CentOS-7-x86_64/images/pxeboot/initrd.img
Kernel                         : /var/www/cobbler/ks_mirror/CentOS-7-x86_64/images/pxeboot/vmlinuz
Kernel Options                 : {}
Kernel Options (Post Install)  : {}
Kickstart Metadata             : {'tree': 'http://@@http_server@@/cblr/links/CentOS-7-x86_64'}
Management Classes             : []
OS Version                     : rhel7
Owners                         : ['admin']
Red Hat Management Key         : <<inherit>>
Red Hat Management Server      : <<inherit>>
Template Files                 : {}

```


### Installation
Install the system, via setup a machine which boot from PXE in the same subnet, then this machine will hint you with installing the corresponding system.   
The new system's username/password is the same as we set in the cobbler configuration file.  
### Enable Web Interface  
Change the default password via:    

```
$ cp /etc/cobbler/users.digest /etc/cobbler/users.digest.back
$ htdigest /etc/cobbler/users.digest "Cobbler" cobbler

```
Now restart the cobblerd, you could visit following URL for visiting the Web Inteface:    
[http://10.3.3.3/cobbler_web](http://10.3.3.3/cobbler_web)    


### Import Multiple ISOs
Import the first iso as usual.    

```
# mount -o loop -t iso9660 ./CentOS-6.6-x86_64-bin-DVD1.iso  /mnt
# cobbler import --name=CentOS-6.6 --arch=x86_64 --path=/mnt

```
The Second iso first mount to /mnt1/ directory, then import with following command:    

```
#  rsync -a '/mnt1/' /var/www/cobbler/ks_mirror/CentOS-6.6-x86_64/ --exclude-from=/etc/cobbler/rsync.exclude --progress
#  COMPSXML=$(ls /var/www/cobbler/ks_mirror/CentOS-6.6-x86_64/repodata/*comps*.xml)
#  createrepo -c cache -s sha --update --groupfile ${COMPSXML} /var/www/cobbler/ks_mirror/CentOS-6.6-x86_64

```
Verify it via:    

```
# cobbler distro list
# cobbler profile list
# cobbler distro report --name=CentOS-6.6-x86_64

```
Verify it via installing a new machine running CentOS6.6.    
### Trouble-Shooting on fence
Lacking of fence equipment.   

Trouble shooting for controlling the Systems(which is the node information which added into cobbler system).     
For Power Management:    

```
[root@CobblerServer ~]# cobbler system poweroff --name Node1
task started: 2015-05-14_064600_power
task started (id=Power management (off), time=Thu May 14 06:46:00 2015)
cobbler power configuration is:
      type   : virsh
      address: qemu+ssh://root@10.3.3.1/system
      user   : root
      id     : CobblerTest
running: /usr/sbin/fence_virsh
received on stdout: 
received on stderr: Unable to connect/login to fencing device

```
