---
layout: post
title: "Using HardDisk For Booting RaspberryPI"
date: 2014-05-19 20:21
comments: true
categories: linux
---
### 准备
RaspberryPI, SD卡（4G以上), 移动硬盘，操作系统镜像文件，最好有一个外接供电带电路隔离的USB HUB。 鼠标、键盘等。    
### 用SD卡启动
将SD卡插入电脑，将镜像文件写入到SD卡后，将写好的SD卡插入RaspberryPI，加电开机。各种配置（譬如显存大小，是否启动到X等等）完成之后，进入到Linux桌面。    
### 准备硬盘
将硬盘插入USB口，如果之前有分好区的，可以略过这一节，直接到`拷贝至硬盘`一节。     
在RaspberryPI系统里(wheezy or archLinux)，搜索gparted, 这个工具可以在图形化界面下对硬盘进行分区。    
命令行下你可以通过下列命令查看已挂载的存储设备信息：    

```
[root@alarmpi ~]# fdisk -l

Disk /dev/mmcblk0: 7.3 GiB, 7822376960 bytes, 15278080 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x00047c7a

Device         Boot     Start       End  Blocks  Id System
/dev/mmcblk0p1           8192    122879   57344   c W95 FAT32 (LBA)
/dev/mmcblk0p2         122880  15278079 7577600  83 Linux


Disk /dev/sda: 465.8 GiB, 500105740288 bytes, 976769024 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x0004f23a

Device    Boot     Start       End    Blocks  Id System
/dev/sda1           2048   1050623    524288  82 Linux swap / Solaris
/dev/sda2        1050624 126879743  62914560  83 Linux
/dev/sda3      126879744 546310143 209715200   7 HPFS/NTFS/exFAT
/dev/sda4      546310144 976769023 215229440   5 Extended
/dev/sda5      546312192 588255231  20971520  83 Linux
/dev/sda6      588257280 976769023 194255872  83 Linux

```
上面的代码中可以看到，我的RaspberryPI上挂载的硬盘大小是500G。分成了若干个区。    
### 拷贝文件系统到硬盘分区
分区决定于你自己，用gparted或者别的分区工具都可以分好，记得选择Linux ext4为文件系统。    
这里我选择`/dev/sda5`作为我的根分区，所以在终端上，执行下列命令：

```
$ mkfs.ext4 /dev/sda5
$ sudo mount /dev/sda5 /mnt
$ cd /mnt
$ tar cjvf /mnt/rootfs.tar.bz2 /

```
备份完毕后，解压： 

```
$ tar xjvf /mnt/rootfs.tar.bz2 -C /mnt/

```
这里用tar备份文件系统时主要是为了防止系统中某些可能的链接/设备文件的丢失，干脆先压缩后再解压，一劳永逸，代价是时间会花多一点。用rsync是既保险又快速的方法，如果你系统上安装了rsync，试下下面的命令：

```
rsync -rv --exclude=/mnt / /mnt

```
总之，这一步的目的是把SD卡上的文件系统完整复制到硬盘分区上。
### 修改启动选项
修改SD的boot分区上内容，文件`cmdline.txt`以使得其适配硬盘启动：    

```
$ cd /boot
$ cp cmdline.txt cmdline.txt.SD
$ >cmdline.txt
$ echo "smsc95xx.turbo_mode=N dwc_otg.lpm_enable=0 console=ttyAMA0,115200 kgdboc=ttyAMA0,115200 console=tty1 root=/dev/sda5 rootfstype=ext4 elevator=noop rootwait">cmdline.txt

```
上面命令的作用是把`root=`参数从`root=/dev/mmcblk0p2`换到`root=/dev/sda5`，你的硬盘分区可能不是sda5，这取决于你在上两步中采用了哪块分区。例如sda(1?2?3?4?)，这里的数值和你在上两步中应该保持一致。    
如果你的移动硬盘上创建了交换分区，即swap分区，记得在`/etc/fstab`文件中加入相应的条目，下面是的系统上，用sda1作为swap分区时的配置

```
# cat /etc/fstab
# 
# /etc/fstab: static file system information
#
# <file system>	<dir>	<type>	<options>	<dump>	<pass>
/dev/mmcblk0p1  /boot           vfat    defaults        0       0
/dev/sda1  	none		swap 	defaults        0       0

```

为了确保写入成功，在操作的最后，麻烦运行一下:     

```
$ sudo sync

```
这可以保证所有的外接设备上的数据被安全写入。     



没有问题的话，现在重新启动RaspberryPI，你的文件系统就应该跑在硬盘上了。

如果有失败的话，把SD卡插入电脑，把cmdline.txt文件恢复成cmdline.txt.SD文件即可。    

### 特别强调
特别强调的一点，彻底从硬盘启动是不可能的！！！也就是说，你依然需要插入一张SD卡在RaspberryPI的槽中。因为RaspberryPI每次都是从固定地址读取启动代码的。     
上述做法的好处是避免了频繁读写SD卡，延长了SD卡的使用寿命。      
缺点是： USB硬盘的速度，最多也就是USB2.0的极速。 SD卡，CLASS10的速度可能要超过USB2.0的速度。某些时候会慢一点，但是秒杀CLASS4的卡是没问题的。     
