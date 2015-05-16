---
layout: post
title: "OpenWRT on BBB(3)"
date: 2014-11-10 11:40
comments: true
categories: embedded
---
### Building Guideline
I found a openwrt-bbb  repository on github, so just download it and build:     
[https://github.com/nc543/openwrt-bbb/wiki](https://github.com/nc543/openwrt-bbb/wiki)     

```
$ git clone https://github.com/nc543/openwrt-bbb.git
$ cd openwrt-bbb
$ make

```
When building you will meet the openssl download error, simply change the version from 1.0.1i to 1.0.1h or other version is OK.     
I change this because in recent days the download page of openssl.org is not stable, so the download procedure will directly download the tar files from openwrt.org, while on openwrt.org it holds the 1.0.1h version rather than 1.0.1i version. If you could get 1.0.1i version from openssl.org, then you needn't do these changes.     
### Verification
As the author said, directly use dd for copying the files into the SD card, but I failed. 
#### SD Card
Use following command for write the image to the SD card:     

```
$ sudo dd if=bin/omap/openwrt-omap-combined-vfat-ext4.img of=/dev/sdb
$ sync

```
Then we have to do following operation in order to change the bootup sequence and parameters:    

```
$ mount /dev/mmcblk0p1 /mnt
$ cp openwrt-omap-zImage /mnt/
$ cp dtbs/am335x-boneblack.dtb /mnt/dtbs/
$ vim uEnv.txt
kernel_file=zImage
fdtfile=am335x-boneblack.dtb

loadzimage=load mmc ${mmcdev}:${mmcpart} ${loadaddr} ${kernel_file}
loadfdt=load mmc ${mmcdev}:${mmcpart} ${fdtaddr} /dtbs/${fdtfile}

console=ttyO0,115200n8
mmcroot=/dev/mmcblk0p2 ro
mmcrootfstype=ext4 rootwait

mmcargs=setenv bootargs console=${console} root=${mmcroot} rootfstype=${mmcrootfstype} ${optargs}

uenvcmd=run loadzimage; run loadfdt; run mmcargs; bootz ${loadaddr} - ${fdtaddr}

optargs="debug init=/etc/preinit"

```
With above modification you could directly use the SD card for booting the BBB and use OpenWRT!     
#### NFS
Create NFS via following command:    

```
[root@TrustyArch omap]# pwd
/media/y/embedded/BBB/OpenWRT/openwrt-bbb/bin/omap
[root@TrustyArch omap]# cp openwrt-omap-zImage /srv/tftp/
[root@TrustyArch omap]# cp dtbs/am335x-boneblack.dtb /srv/tftp/
[root@TrustyArch omap]# mkimage -A arm -O linux -T kernel -C none -a 0x80008000 -e 0x80008000 -n "Linux" -d /srv/tftp/openwrt-omap-zImage /srv/tftp/uImage
[root@TrustyArch omap]# rm -rf /srv/nfs4/BBBrootfs/
[root@TrustyArch omap]# mkdir -p /srv/nfs4/BBBrootfs
[root@TrustyArch omap]# tar xzvf openwrt-omap-Default-rootfs.tar.gz -C /srv/nfs4/BBBrootfs/

```
Wow, start from NFS got failed for:   

```
[    1.262675] VFS: Cannot open root device "nfs" or unknown-block(0,255): error -6
[    1.270603] Please append a correct "root=" boot option; here are the available partitions:
[    1.279456] b300         1875968 mmcblk0  driver: mmcblk
[    1.285084]   b301           72261 mmcblk0p1 00000000-01
[    1.290680]   b302         1799280 mmcblk0p2 00000000-02
[    1.296300] b310            1024 mmcblk0boot1  (driver?)
[    1.301895] b308            1024 mmcblk0boot0  (driver?)
[    1.307513] Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,255)

```
Later I will investigate this problem.     

### Re-Compile Kernel
First we enable the kernel .config support, so later we could directly output its .config for newer version:     

```
$ make menuconfig
General setup
[*] Kernel .config support
[*] Enable access to .config through /proc/config.gz

```
Enable the nfs support:    

```
Device Driver
[*] Block devices
[*] Network block device support
Networking options
[*] IP: kernel level autoconfiguration
[*]	IP: DHCP support
[*]	IP: BOOTP support
[*]
File Systems
[*] Netwrok File Systems

```
The detailed NFS client configuration is listed as following image:    
![/images/nfsconfiguration.jpg](/images/nfsconfiguration.jpg)      


Save the configuration and re-compile the kernel:   

```
$ make V=99 -j4

```

