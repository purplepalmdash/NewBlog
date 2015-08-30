---
layout: post
title: "Tips For SSD Installation"
date: 2015-08-30 14:45:24 +0800
comments: true
categories: Linux
---
Refers to:    
[https://wiki.archlinux.org/index.php/Beginners'_guide_%28%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87%29](https://wiki.archlinux.org/index.php/Beginners'_guide_%28%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87%29)    

### Partition
Check if you are in efi mode:    

```
# efivar -l
```
Then format your disk using parted:    

```
# parted /dev/sda
(parted) mkpart ESP fat32 1M 513M
(parted) set 1 boot on
(parted) mkpart primary ext4 513M 100%
```

Check if your partition is aligned:    

```
# blockdev --getalignoff /dev/sda
0
```

I have 2 disks, one for ssd, the other for hdd, so I want to share the swap partition,
and locate the /var directory in the hdd, modify it via:    

```
# mkfs.ext4 /dev/sda2
# mkfs.vfat -F32 /dev/sda1
# mount /dev/sda2 /mnt
# mkdir -p /mnt/boot
# mount /dev/sda1 /mnt/boot
# swapon /dev/sdb1
# mkdir /media/
# mount /dev/sdb2 /media
# mkdir /media/var_for_sda
# ln -s /media/var_for_sda /mnt/var
```

Now you could do pacstrap.    

### Installation
Installation are the same as the guildeline show, 

```
# pacman -S dosfstools efibootmgr
# bootctl --path=/boot install
# vim /boot/loader/entries/arch.conf
title          Arch Linux
linux          /vmlinuz-linux
initrd         /initramfs-linux.img
options        root=/dev/sda2 rw
# vim /boot//loader/loader.conf
#timeout 3
default arch
timeout 5
```
For wireless connection:    

```
# pacman -S iw wpa_supplicant
# pacman -S dialog
```

Modification of the /etc/fstab:    

```
# /dev/sda2
UUID=xxxxxxxxxxxxxxxxxxxxxxxx       /               ext4 default,rw,data=ordered,noatime,discard 0 1

# /dev/sda1
UUID=xxxxxxxxxxxxxxxxx          /boot           vfat rw,noatime,discard,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,errors=remount-ro  0 2

# /dev/sdb1
UUID=xxxxxxxxxxxxxxxxxxx       none            swap defaults        0 0

# /dev/sdb2
UUID=xxxxxxxxxxxxxxxxxxx       /media          ext4	 rw,relatime,data=ordered        0 2

# Only for /var , use mount -o bind
/media/var_for_sda      /var    none    bind
```
Now reboot everything will be OK.    

### Configuration For SSD

Profile-sync-daemon for optimization of Browser :    

```
$ yaourt profile-sync-daemon
$ sudo vim /etc/psd.conf
USERS="XXXXX"
BROWSERS="chromium firefox"
USE_OVERLAYFS="yes"
$ sudo systemctl enable psd.service
$ sudo systemctl start psd.service
```
Test it via:     

```
$ profile-sync-daemon parse
```
Use `firefox -P` for changing the profile position. I put all of the profils on HDD.    

For chromium, softlink the ~/.config/chromium to HDD disk then you play the tricks for
avoiding HDD from too much write.   .   

### Quickly Add User
Use following command for quickly adding the user with specified priviledge:    

```
# useradd -m -g root -G \
audio,video,floppy,network,rfkill,scanner,storage,optical,power,wheel,uucp -s  \
/usr/bin/zsh xxxxx
# passwd xxxxx
```
