---
layout: post
title: "Use TFTP/NFS Testing  BBB Kernel "
date: 2014-11-02 20:25
comments: true
categories: embedded
---
### Prerequisite
You have a tftp server and NFS server configured, in my environment these 2 server runs on ArchLinux, ip address is 10.0.0.221, while BBB takes another ip address, for example, 10.0.0.16.     
### NFS Server Preparation
Create the nfs server's rootfs for BBB Black ,and open all of the priviledges :    

```
# pwd
/media/y/embedded/BBB/svnco/trunk/bin/omap
# mkdir /srv/nfs4/BBBrootfs
# tar xzvf openwrt-omap-Default-rootfs.tar.gz -C /srv/nfs4/BBBrootfs/
# chmod 777 -R /srv/nfs4/BBBrootfs/

```
Now you have the NFS Server available.     
### TFTP Server Preparation
Since we are using u-boot for booting, we need create uImage, but in OpenWRT, its default generated file is zImage, so we need use following command for generate our own uImage:    

```
# mkimage -A arm -O linux -T kernel -C none -a 0x80008000 -e 0x80008000 -n "Linux" -d ./zImage ./uImage
Image Name:   Linux
Created:      Sun Nov  2 20:39:08 2014
Image Type:   ARM Linux Kernel Image (uncompressed)
Data Size:    1710568 Bytes = 1670.48 kB = 1.63 MB
Load Address: 80008000
Entry Point:  80008000

```
Also we have to copy the dtd file into our tftp folder:    

```
[root@TrustyArch omap]# pwd
/media/y/embedded/BBB/svnco/trunk/bin/omap
[root@TrustyArch omap]# cp dtbs/am335x-boneblack.dtb /srv/tftp/

```
### Easy Making Script
Following script will easy your life:     

```
$ cat ~/autobuildnfs.sh
# First copy the kernel and dtd files into the tftp server
echo "##### Start copy to /srv/tftp####"
cp /media/y/embedded/BBB/svnco/trunk/bin/omap/openwrt-omap-zImage /srv/tftp/
cp /media/y/embedded/BBB/svnco/trunk/bin/omap/dtbs/am335x-boneblack.dtb /srv/tftp/
echo "###############Finished Copy!!!###############"
# Generate the uImage in /srv/tftp folder
mkimage -A arm -O linux -T kernel -C none -a 0x80008000 -e 0x80008000 -n "Linux" -d /srv/tftp/openwrt-omap-zImage /srv/tftp/uImage
# Remove the BBBrootfs content, all of them should be deleted. 
rm -rf /srv/nfs4/BBBrootfs/
mkdir -p /srv/nfs4/BBBrootfs
# Now extract the newly generatd rootfs into the /srv/nfs4/BBBrootfs
tar xzvf /media/y/embedded/BBB/svnco/trunk/bin/omap/openwrt-omap-Default-rootfs.tar.gz -C /srv/nfs4/BBBrootfs/

```

### U-boot Configuration
#### CheetSheet
When system startup, click 'enter' for getting the u-boot prompt interface, then set following:    

```
setenv ipaddr 10.0.0.16
setenv serverip 10.0.0.221
tftpboot ${fdtaddr} am335x-boneblack.dtb
tftpboot ${kloadaddr} uImage
setenv bootargs console=ttyO0,115200n8 root=/dev/nfs rw nfsroot=10.0.0.221:/srv/nfs4/BBBrootfs ip=10.0.0.16:::::eth0
bootm ${kloadaddr} - ${fdtaddr}

```
#### CheetSheet2

```
setenv ipaddr 192.168.1.16
setenv serverip 192.168.1.221
tftpboot ${fdtaddr} am335x-boneblack.dtb
tftpboot ${kloadaddr} uImage
# For NFS
setenv bootargs console=ttyO0,115200n8 root=/dev/nfs rw nfsroot=192.168.1.221:/srv/nfs4/BBBrootfs ip=192.168.1.16:::::eth0 rootpath=/etc/preinit
# NFS with 192.168.1.1
setenv bootargs console=ttyO0,115200n8 root=/dev/nfs rw nfsroot=192.168.1.221:/srv/nfs4/BBBrootfs ip=192.168.1.1:::::eth0 rootpath=/etc/preinit
# For SD-Card
setenv bootargs console=ttyO0,115200n8 root=/dev/mmcblk0p2 ro rootfstype=ext4 rootwait
bootm ${kloadaddr} - ${fdtaddr}

```

#### setting and testing the network
Set the ipaddr, and save it into the u-boot, next time you won't set it again.   

```
U-Boot# setenv ipaddr 10.0.0.16
U-Boot# printenv ipaddr
ipaddr=10.0.0.16
U-Boot# setenv serverip 10.0.0.221
U-Boot# ping 10.0.0.221
link up on port 0, speed 100, full duplex
Using cpsw device
host 10.0.0.221 is alive
U-Boot# saveenv

```
#### Load Files From TFTP
Use following commands for loading uImage and dtb files from 10.0.0.221:    

```
U-Boot# tftpboot ${fdtaddr} am335x-boneblack.dtb
U-Boot# tftpboot ${kloadaddr} uImage

```
#### Set NFS Startup Parameter
Following will let the kernel startup from the nfs server.    

```
setenv bootargs console=ttyO0,115200n8 root=/dev/nfs rw nfsroot=10.0.0.221:/srv/nfs4/BBBrootfs ip=10.0.0.16:::::eth0

```
Now startup:   

```
bootm ${kloadaddr} - ${fdtaddr}

```

### Start Debugging Under NFS
First we met following error:   

```
[    1.015532] List of all partitions:
[    1.019292] No filesystem could mount root, tried: 
[    1.024439] Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,255)

```
This is because we don't enable NFS and ROOT on NFS in kernel configuration.   
File System ->  Network File System -> NFS Client Support, etc, see following picture:    
![/images/nfskernelconfigure.jpg](/images/nfskernelconfigure.jpg)    

