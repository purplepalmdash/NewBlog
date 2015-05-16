---
layout: post
title: "Setup PXE Server"
date: 2015-05-11 14:12
comments: true
categories: Linux
---
This article record how to setup the pxe server and setup the CentOS quick installation repository, using it we could quickly setup the CentOS on new machine.     
### Installation
To install following packages for preparing the environment:     

```
$ sudo apt-get install dnsmasq tftpd-hpa apache2 system-config-kickstart

```
Configure the apache2's default configuration file:    

```
$ sudo vim /etc/apache2/sites-enabled/000-default.conf
        DocumentRoot /var/www/

```
Configure the dnsmasq via following command:     

```
$ sudo vim /etc/dnsmasq.conf
bogus-priv
filterwin2k
interface=eth0
domain=nova.com
dhcp-range=10.7.7.100,10.7.7.150,12h
dhcp-option=3,10.7.7.1
dhcp-option=6,114.114.114.114
dhcp-option=121,10.7.7.0/24
dhcp-boot=/var/tftproot/pxelinux.0
enable-tftp
tftp-root=/var/tftproot
dhcp-authoritative

```
Copy the pxelinux.0 from an installed CentOS, and copy it to /var/tftproot/      

```
[root:~]# scp /usr/share/syslinux/pxelinux.0 Trusty@10.7.7.2:/home/Trusty
Trusty@WolfHunterPXE:~$ sudo cp /home/Trusty/pxelinux.0 /var/tftproot/

```

### Prepare the Repository
We need to copy the installation media into the corresponding directory:    

```
$ sudo mkdir -p /var/www/CentOS
$ sudo mount CentOS-6.3-x86_64-bin-DVD1.iso /mnt
$ sudo cp -rf /mnt/* /var/www/CentOS
$ sudo mkdir -p /mnt1
$ sudo mount CentOS-6.3-x86_64-bin-DVD2.iso /mnt1
$ sudo cp -rf /mnt1/Packages/* /var/www/CentOS/Packages/

```
Copy the CentOS's kernel and kernel-startup file into the /var/tftproot/CentOS directory:      

```
$ sudo mkdir -p /var/tftproot/CentOS
$ sudo cp /mnt/images/pxeboot/initrd.img /var/tftproot/CentOS
$ sudo cp /mnt/images/pxeboot/vmlinuz /var/tftproot/CentOS

```
Now your repository for installation is ready.      
### Configuration
Edit the boot.msg file for user choosen:     

```
$ sudo vim /var/tftproot/boot.msg
### START INSTALLING ######
Choose installation type(0/1/2),the DEFAULT is 100:
0 CentOS-6.3-64-No-RAID-Basic
1 CentOS-6.3-64-No-RAID-minidesktop-virtualization-for testing

```
When user choose the corresponding items, then /var/tftproot/pxelinux.cfg/default file will choose the correspoiding files.     

```
Trusty@WolfHunterPXE:~$ sudo mkdir -p /var/tftproot/pxelinux.cfg
Trusty@WolfHunterPXE:~$ sudo vim /var/tftproot/pxelinux.cfg/default
default 100
display boot.msg

# Label 100 , boot from hddisk
LABEL 100
localboot 0x80

### Label 0, minimal CentOS
label 0
kernel CentOS/vmlinuz
append ks=http://10.7.7.2/cfg/Centos-minibasic.cfg vga=normal initrd=CentOS/initrd.img devfs=nomount ramdisk_size=9216 nofb

### Label 1, minimal-Desktop CentOS 
label 1
kernel CentOS/vmlinuz
append ks=http://10.7.7.2/cfg/Centos-minidesktop.cfg vga=normal initrd=CentOS/initrd.img devfs=nomount ramdisk_size=9216 nofb

prompt 1 
timeout 900

```
### Get kickstart file
In a installed CentOS Server, install system-config-kickstart via:    

```
$ sudo yum install system-config-kickstart

```
Run ` sudo system-config-kickstart` for getting the graphical configuration window, like following:     

![/images/2015_05_11_14_50_05_931x572.jpg](/images/2015_05_11_14_50_05_931x572.jpg)     
Customize the partition:     

![/images/2015_05_11_14_52_09_842x576.jpg](/images/2015_05_11_14_52_09_842x576.jpg)     
Do other configurations, after everything is OK, save it.      

An example cfg file is listed as following:     

```
# cat minidesktop.cfg 
#platform=x86, AMD64, or Intel EM64T
#version=DEVEL
# Firewall configuration
firewall --disabled
# Install OS instead of upgrade
install
# Use network installation
url --url="http://10.7.7.2/CentOS"
# Root password
rootpw --iscrypted $1$aRvLvJNH$ElcmZ2Msl4MbD.fHdnos9.
# System authorization information
auth  --useshadow  --passalgo=sha512
# Use graphical install
graphical
firstboot --disable
# System keyboard
keyboard us
# System language
lang en_US
# SELinux configuration
selinux --disabled
# Installation logging level
logging --level=info

# System timezone
timezone  Asia/Hong_Kong
# System bootloader configuration
bootloader --location=mbr
# Clear the Master Boot Record
zerombr
# Partition clearing information
clearpart --all  
# Disk partitioning information
part swap --fstype="swap" --size=1024
part / --asprimary --fstype="ext4" --grow --size=1

%packages
@basic-desktop
@chinese-support
@internet-browser
@x11
-ibus-table-cangjie
-ibus-table-erbi
-ibus-table-wubi

%end

```
Copy it under the /var/www/cfg/CentOS-minidesktop.cfg.      

```
Trusty@WolfHunterPXE:~$ sudo mkdir -p /var/www/cfg
Trusty@WolfHunterPXE:~$ sudo cp minidesktop.cfg /var/www/cfg/CentOS-minidesktop.cfg

```
### Testing
Now create a new machine , set its bootup to pxe-network.    
Trouble Shooting, only need for CentOS:    
![/images/2015_05_11_16_18_47_609x332.jpg](/images/2015_05_11_16_18_47_609x332.jpg)    


```
- Ctrl+B
- dhcp net0
- config

- Ctrl+X
- autoboot

```

