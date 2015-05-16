---
layout: post
title: "Moving From Working PC To Own USB-Disk Based"
date: 2014-05-21 15:13
comments: true
categories: linux
---
### Background
Since I want to hava a usb-based OS which could easily be taken by hand, I took this series for resarching how to finish this aim.     
### Preparation
ArchLinux iso file, USB-3.0 HardDisk, 80GB, later I will use a bigger one.     
#### Qemu Script 
I use qemu firstly to install the system. following is the configuraton file for qemu-i386:     

```
#!/bin/bash
USERID=$(whoami)

# Get name of newly created TAP device; see https://bbs.archlinux.org/viewtopic.php?pid=1285079#p1285079
precreationg=$(/usr/bin/ip tuntap list | /usr/bin/cut -d: -f1 | /usr/bin/sort)
sudo /usr/bin/ip tuntap add user $USERID mode tap
postcreation=$(/usr/bin/ip tuntap list | /usr/bin/cut -d: -f1 | /usr/bin/sort)
IFACE=$(comm -13 <(echo "$precreationg") <(echo "$postcreation"))

# This line creates a random MAC address. The downside is the DHCP server will assign a different IP address each time
printf -v macaddr "52:54:%02x:%02x:%02x:%02x" $(( $RANDOM & 0xff)) $(( $RANDOM & 0xff )) $(( $RANDOM & 0xff)) $(( $RANDOM & 0xff ))
# Instead, uncomment and edit this line to set a static MAC address. The benefit is that the DHCP server will assign the same IP address.
# macaddr='52:54:be:36:42:a9'
  
qemu-system-i386 -net nic,macaddr=$macaddr -net tap,ifname="$IFACE" $*
  
sudo ip link set dev $IFACE down &> /dev/null
sudo ip tuntap del $IFACE mode tap &> /dev/null 

```
Run the virtual machine like following:     

```
$ ./run-qemu-i386 -hda /dev/sdc -m 1024 -boot d -cdrom  ./archlinux-2014.05.01

```
#### Installation Of ArchLinux
When your iso bootup, you will enter command-line, use following command for start the ssh :    

```
# passwd root
# systemctl start sshd
# ifconfig 
# ssh root@10.0.0.240

```
Partition disk:    

```
# fdisk /dev/sda
Command (m for help): p
Disk /dev/sda: 74.5 GiB, 80026361856 bytes, 156301488 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xc001c001

Device    Boot Start       End   Blocks  Id System
/dev/sda1       2048 156301487 78149720  83 Linux

Command (m for help): d

Selected partition 1
Partition 1 has been deleted.

Command (m for help): n

Partition type:
   p   primary (0 primary, 0 extended, 4 free)
   e   extended
Select (default p): p
Partition number (1-4, default 1): 1
First sector (2048-156301487, default 2048): 
Last sector, +sectors or +size{K,M,G,T,P} (2048-156301487, default 156301487): +1G

Created a new partition 1 of type 'Linux' and of size 1 GiB.

Command (m for help): t
Hex code (type L to list all codes): 82
Changed type of partition 'Linux' to 'Linux swap / Solaris'.

Command (m for help): n

Partition type:
   p   primary (1 primary, 0 extended, 3 free)
   e   extended
Select (default p): p
Partition number (2-4, default 2): 
First sector (2099200-156301487, default 2099200): 
Last sector, +sectors or +size{K,M,G,T,P} (2099200-156301487, default 156301487): 

Created a new partition 2 of type 'Linux' and of size 73.5 GiB.

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.

root@archiso ~ # fdisk -l /dev/sda

Disk /dev/sda: 74.5 GiB, 80026361856 bytes, 156301488 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xc001c001

Device    Boot     Start       End   Blocks  Id System
/dev/sda1           2048   2099199  1048576  82 Linux swap / Solaris
/dev/sda2        2099200 156301487 77101144  83 Linux

```
Now your partition is ok, make filesystems.    

```
# mkfs.ext4 /dev/sda2                                                             
root@archiso ~ # mkswap /dev/sda1
root@archiso ~ # swapon /dev/sda1

```
Now begin to install system:    

```
# mount /dev/sda2 /mnt
# pacstrap /mnt base

```
Configuraion:    

```
# genfstab -p /mnt >> /mnt/etc/fstab
# arch-chroot /mnt
sh-4.3# cat /etc/hostname 
FreeArch

sh-4.3# ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
# Uncomment the items in /etc/locale.gen, and run: 
sh-4.3# locale-gen
Generating locales...
  en_US.UTF-8... done
  en_US.ISO-8859-1... done
  zh_CN.GB18030... done
  zh_CN.GBK... done
  zh_CN.UTF-8... done
  zh_CN.GB2312... done
  zh_TW.EUC-TW... done
  zh_TW.UTF-8... done
  zh_TW.BIG5... done
Generation complete.

sh-4.3# mkinitcpio -p linux
sh-4.3# passwd root

```
Network Configuration:    

```
sh-4.3# ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether 52:54:94:b5:12:24 brd ff:ff:ff:ff:ff:ff
sh-4.3# pacman -S dhcpcd
sh-4.3# systemctl enable dhcpcd@ens3
ln -s '/usr/lib/systemd/system/dhcpcd@.service' '/etc/systemd/system/multi-user.target.wants/dhcpcd@ens3.service'

```
BootLoad Configuration:    

```
# pacman -S grub
# grub-install --target=i386-pc --recheck --debug /dev/sda
# grub-mkconfig -o /boot/grub/grub.cfg

```
Umount and reboot:

```
umount -R /mnt

```

### Configuration Of System
Install openssh firstly, and net-tools for getting the ipaddress using ifconfig:    

```
pacman -S openssh
systemctl enable sshd
systemctl start sshd
pacman -S net-tools

```
Now you can use terminal for getting to the qemu-based machine, and sshd service should be enabled always.    

Quickly setup an account, because using root is a bad idea.

```
# useradd -m -g root -G audio -s /bin/bash Trusty
# pacman -S sudo
# visudo
##
## User privilege specification
##
root ALL=(ALL) ALL
Trusty ALL=(ALL) NOPASSWD: ALL
## Locale settings
# Defaults env_keep += "LANG LANGUAGE LINGUAS LC_* _XKB_CHARSET"
Defaults env_keep += "http_proxy https_proxy ftp_proxy ftps_proxy"

```
Now you can use the newly added username "Trusty" for login.      

Install yaourt, add following lines into the file /etc/pacman.conf:    

```
[archlinuxfr]
SigLevel = Never
Server = http://repo.archlinux.fr/$arch

```
Then update and install yaourt: 

```
sudo pacman -Syu && sudo pacman -S yaourt

```

Next chapter we will begin to install softwares.    

