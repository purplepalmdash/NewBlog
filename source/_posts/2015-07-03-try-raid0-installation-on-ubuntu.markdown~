---
layout: post
title: "Try raid0 installation on Ubuntu"
date: 2015-07-03 10:58:55 +0800
comments: true
categories: linux
---
### Preparation
Prepare the disks:     

```
[root:/home/juju/img]# mkdir Raid0
[root:/home/juju/img]# cd Raid0/
[root:/home/juju/img/Raid0]# ls
[root:/home/juju/img/Raid0]# qemu-img create -f qcow2 disk0.qcow2 10G
Formatting 'disk0.qcow2', fmt=qcow2 size=10737418240 encryption=off cluster_size=65536 
[root:/home/juju/img/Raid0]# qemu-img create -f qcow2 disk1.qcow2 10G
Formatting 'disk1.qcow2', fmt=qcow2 size=10737418240 encryption=off cluster_size=65536 
[root:/home/juju/img/Raid0]# qemu-img create -f qcow2 disk2.qcow2 10G
Formatting 'disk2.qcow2', fmt=qcow2 size=10737418240 encryption=off cluster_size=65536 
```

Prepare the Virtual Machine:    
![/images/2015_07_03_11_06_03_658x441.jpg](/images/2015_07_03_11_06_03_658x441.jpg)    

![/images/2015_07_03_11_06_57_556x325.jpg](/images/2015_07_03_11_06_57_556x325.jpg)    

### Partition


![/images/2015_07_03_11_12_18_615x311.jpg](/images/2015_07_03_11_12_18_615x311.jpg)    

![/images/2015_07_03_11_15_30_476x216.jpg](/images/2015_07_03_11_15_30_476x216.jpg)    

![/images/2015_07_03_11_15_36_384x205.jpg](/images/2015_07_03_11_15_36_384x205.jpg)    

![/images/2015_07_03_11_18_30_499x265.jpg](/images/2015_07_03_11_18_30_499x265.jpg)    

### Raid
Configure the Software Raid0:    

![/images/2015_07_03_11_19_31_441x260.jpg](/images/2015_07_03_11_19_31_441x260.jpg)    

![/images/2015_07_03_11_20_41_655x244.jpg](/images/2015_07_03_11_20_41_655x244.jpg)    

![/images/2015_07_03_11_22_43_728x243.jpg](/images/2015_07_03_11_22_43_728x243.jpg)    

After Configuration of SoftRaid1, the screen displayed like:    

![/images/2015_07_03_11_28_28_687x457.jpg](/images/2015_07_03_11_28_28_687x457.jpg)    


Continue to install.   

### Verify Raid.    
Use df and fdisk to verify the partition information:    

```
clouder@UbuntuRaid1:~$ df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/md0        9.3G  870M  7.9G  10% /
none            4.0K     0  4.0K   0% /sys/fs/cgroup
udev            235M  4.0K  235M   1% /dev
tmpfs            50M  440K   49M   1% /run
none            5.0M     0  5.0M   0% /run/lock
none            246M     0  246M   0% /run/shm
none            100M     0  100M   0% /run/user
clouder@UbuntuRaid1:~$ sudo fdisk -l
[sudo] password for clouder: 

Disk /dev/vda: 10.7 GB, 10737418240 bytes
255 heads, 63 sectors/track, 1305 cylinders, total 20971520 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00035942

   Device Boot      Start         End      Blocks   Id  System
/dev/vda1   *        2048    19922943     9960448   fd  Linux raid autodetect
/dev/vda2        19924990    20969471      522241    5  Extended
/dev/vda5        19924992    20969471      522240   fd  Linux raid autodetect

Disk /dev/vdb: 10.7 GB, 10737418240 bytes
255 heads, 63 sectors/track, 1305 cylinders, total 20971520 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x000715e9

   Device Boot      Start         End      Blocks   Id  System
/dev/vdb1   *        2048    19922943     9960448   fd  Linux raid autodetect
/dev/vdb2        19924990    20969471      522241    5  Extended
/dev/vdb5        19924992    20969471      522240   fd  Linux raid autodetect

Disk /dev/md0: 10.2 GB, 10190979072 bytes
2 heads, 4 sectors/track, 2488032 cylinders, total 19904256 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00000000

Disk /dev/md0 doesn't contain a valid partition table

Disk /dev/md1: 534 MB, 534446080 bytes
2 heads, 4 sectors/track, 130480 cylinders, total 1043840 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00000000

Disk /dev/md1 doesn't contain a valid partition table
```

Verify the raid status:    

```
root@UbuntuRaid1:/etc/initramfs-tools/conf.d# cat /proc/mdstat 
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 
md1 : active raid1 vda5[0] vdb5[1]
      521920 blocks super 1.2 [2/2] [UU]
      
md0 : active raid1 vda1[0] vdb1[1]
      9952128 blocks super 1.2 [2/2] [UU]
      
unused devices: <none>
```

Query the status of SoftRaid1:    

```
root@UbuntuRaid1:/etc/initramfs-tools/conf.d# sudo mdadm --query --detail /dev/md0
/dev/md0:
        Version : 1.2
  Creation Time : Fri Jul  3 11:24:46 2015
     Raid Level : raid1
     Array Size : 9952128 (9.49 GiB 10.19 GB)
  Used Dev Size : 9952128 (9.49 GiB 10.19 GB)
   Raid Devices : 2
  Total Devices : 2
    Persistence : Superblock is persistent

    Update Time : Fri Jul  3 11:46:19 2015
          State : clean 
 Active Devices : 2
Working Devices : 2
 Failed Devices : 0
  Spare Devices : 0

           Name : UbuntuRaid1:0  (local to host UbuntuRaid1)
           UUID : bc091921:c198c219:7162e35c:bfff3c4e
         Events : 19

    Number   Major   Minor   RaidDevice State
       0     253        1        0      active sync   /dev/vda1
       1     253       17        1      active sync   /dev/vdb1
```

### Remove One Disk
Remove one, and see if it could be startup.     

Result:    
Done, it could start into the system.     

```
clouder@UbuntuRaid1:~$ cat /proc/mdstat 
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 
md1 : active (auto-read-only) raid1 vda5[1]
      521920 blocks super 1.2 [2/1] [_U]
      
md0 : active raid1 vda1[1]
      9952128 blocks super 1.2 [2/1] [_U]
      
unused devices: <none>
```

### Add A New Empty Disk
Add a new disk into the system, and first partition.    

```
$ sudo fdisk -l 

Disk /dev/vdb: 10.7 GB, 10737418240 bytes
16 heads, 63 sectors/track, 20805 cylinders, total 20971520 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00000000

Disk /dev/vdb doesn't contain a valid partition table
```

Clone the partition table from the vda to the newly added partion:    

```
$ sudo sfdisk -d /dev/vda > vda.desc
$ cat vda.desc 
$ sudo sfdisk /dev/vdb<./vda.desc
```

Now Add the new disk for usage:    

```
clouder@UbuntuRaid1:~$ cat /proc/mdstat 
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 
md1 : active (auto-read-only) raid1 vda5[1]
      521920 blocks super 1.2 [2/1] [_U]
      
md0 : active raid1 vda1[1]
      9952128 blocks super 1.2 [2/1] [_U]
      
unused devices: <none>
clouder@UbuntuRaid1:~$ sudo mdadm --manage /dev/md0 --add /dev/vdb1
mdadm: added /dev/vdb1
clouder@UbuntuRaid1:~$ sudo mdadm --manage /dev/md1 --add /dev/vdb5
mdadm: added /dev/vdb5
clouder@UbuntuRaid1:~$ cat /proc/mdstat 
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 
md1 : active raid1 vdb5[2] vda5[1]
      521920 blocks super 1.2 [2/1] [_U]
        resync=DELAYED
      
md0 : active raid1 vdb1[2] vda1[1]
      9952128 blocks super 1.2 [2/1] [_U]
      [===>.................]  recovery = 16.6% (1662144/9952128) finish=1.8min speed=75552K/sec
      
unused devices: <none>
```

### Known Bugs
Error and Solution:    

```
error:  Diskfilter writes are not supported

Edit :/etc/grub.d/10_linux

Replace 'quick_boot="1"' with 'quick_boot="0"'

Then :

sudo update-grub

```
