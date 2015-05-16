---
layout: post
title: "EBC Exercises on BBB"
date: 2014-11-13 09:29
comments: true
categories: embedded
---
### Tips on Building Kenrel
Via following commands you could build the 3.8 kernel for BBB:    

```
$ git clone git://github.com/RobertCNelson/linux-dev.git
$ cd linux-dev
$ git checkout origin/am33x-v3.8 -b am33x-v3.8
$ time git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
$ cp system.sh.sample system.sh
$ diff system.sh*
15c15
< CC=arm-linux-gnueabi-
---
> #CC=arm-linux-gnueabi-
21c21
< LINUX_GIT=~/BeagleBoard/linux-stable/
---
> #LINUX_GIT=/home/user/linux-stable/
31c31
< ZRELADDR=0x80008000
---
> #ZRELADDR=0x80008000
$ ./build_kernel.sh

```
### U-boot Cross-compile
Download the U-boot and cross-compile it.    

```
# git clone git://git.denx.de/u-boot.git
# cd u-boot/
# git checkout v2013.07 -b tmp
# wget https://raw.github.com/eewiki/u-boot-patches/master/v2013.07/0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch
# patch -p1 < 0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch
# setpogo	# For setting my cross-compiler to arm-linux-gnueabi-
# export ARCH=arm
# export CROSS_COMPILE=arm-linux-gnueabi-
# make

```
After building you will get MLO and u-boot.img.     

### Test on NFS
Prepare the NFS File System.    

```
mkdir dtbs
tar xzvf 3.8.13-bone53-dtbs.tar.gz -C ./dtbs
cp dtbs/am335x-boneblack.dtb /srv/tftp/
cp 3.8.13-bone53.zImage /srv/tftp/
mkimage -A arm -O linux -T kernel -C none -a 0x80008000 -e 0x80008000 -n "Linux" -d /srv/tftp/3.8.13-bone53.zImage  /srv/tftp/uImage
tar xJvf ubuntu-14.04-console-armhf-2014-08-13.tar.xz -C /srv/nfs4/
cd /srv/nfs4/ubuntu-14.04-console-armhf-2014-08-13
tar xvf armhf-rootfs-ubuntu-trusty.tar -C ../Ubuntu_fs/
chmod 777 -R Ubuntu_fs/

```
Then boot the system from U-boot Via:     

```
setenv ipaddr 192.168.1.16
setenv serverip 192.168.1.221
tftpboot ${fdtaddr} am335x-boneblack.dtb
tftpboot ${kloadaddr} uImage
setenv bootargs console=ttyO0,115200n8 root=/dev/nfs rootfstype=nfs rw nfsroot=192.168.1.221:/srv/nfs4/Ubuntu_fs ip=192.168.1.1 
bootm ${kloadaddr} - ${fdtaddr}

```
Now boot the BBB and we got the ssh enabled, via ssh ubuntu@192.168.1.1, password is temppwd.    

Sometimes you will meet sudo problem, just chown and chmod is OK

```
# chmod 4755 some_related_file
# chown root some_related_file

```  
Since NFS gonna the write priviledge error, go back for SD card.     

### SD Card
FileSystem Preparation:    

```
$ export DISK=/dev/mmcblk0
$ dd if=/dev/zero of=${DISK} bs=1M count=10
$ dd if=./u-boot/MLO of=${DISK} count=1 seek=1 conv=notrunc bs=128k
$ dd if=./u-boot/u-boot.img of=${DISK} count=2 seek=1 conv=notrunc bs=384k
 sfdisk --in-order --Linux --unit M ${DISK} <<-__EOF__
1,,0x83,*
__EOF__
$ mkfs.ext4 /dev/mmcblk0p1 -L rootfs

```
Copy the Operating system into the sd card partition 1, later we will use /mnt for mounting the partition 1:    

```
# mount /dev/mmcblk0p1 /mnt
# cd ubuntu-14.04.1-console-armhf-2014-10-29
# tar xvf armhf-rootfs-ubuntu-trusty.tar -C /mnt/
# sync

```
Now install the kernel image into the ubuntu system. Imagine your SD is mount to /mnt/    

```
cp /media/y/embedded/BBB/EBC/3.8Kernel/linux-dev/deploy/3.8.13-bone53.zImage /mnt/boot/vmlinuz-3.8.13-bone53
tar xzvf /media/y/embedded/BBB/EBC/3.8Kernel/linux-dev/deploy/3.8.13-bone53-dtbs.tar.gz -C /mnt/boot/dtbs/

```
Now create the following uEnv.txt located in /mnt/boot/ and /mnt/:     

```
##This will work with: Angstrom's 2013.06.20 u-boot.
 
loadaddr=0x82000000
fdtaddr=0x88000000
rdaddr=0x88080000
 
initrd_high=0xffffffff
fdt_high=0xffffffff

console=ttyO0,115200n8
mmcroot=/dev/mmcblk0p1 ro
 
loadximage=load mmc 0:1 ${loadaddr} /boot/vmlinuz-3.8.13-bone53
loadxfdt=load mmc 0:1 ${fdtaddr} /boot/dtbs/3.8.13-bone53/am335x-boneblack.dtb
loadxrd=load mmc 0:1 ${rdaddr} /boot/initrd.img-${uname_r}; setenv rdsize ${filesize}
loaduEnvtxt=load mmc 0:1 ${loadaddr} /boot/uEnv.txt ; env import -t ${loadaddr} ${filesize};
loadall=run loaduEnvtxt; run loadximage; run loadxfdt;
 
mmcargs=setenv bootargs console=tty0 console=${console} ${optargs} ${cape_disable} ${cape_enable} root=${mmcroot} rootfstype=${mmcrootfstype} ${cmdline}
 
uenvcmd=run loadall; run mmcargs; bootz ${loadaddr} - ${fdtaddr};
optargs="debug"

```

Enable the dhcp, /mnt/etc/network/interfaces:    

```
auto lo
iface lo inet loopback
 
auto eth0
iface eth0 inet dhcp

```
Enable the serial port:    

```
$ sudo vim /mnt/etc/init/serial.conf
start on stopped rc RUNLEVEL=[2345]
stop on runlevel [!2345]
 
respawn
exec /sbin/getty 115200 ttyO0

```
Now restart and you got the 3.8 kernel enabled, so next time if you want to change the kernel, simply change the uEnv.txt file is OK.     

```
ubuntu@arm:/boot$ uname -a
Linux arm 3.8.13-bone53 #1 SMP Tue Nov 11 18:40:19 CST 2014 armv7l armv7l armv7l GNU/Linux

```

