---
layout: post
title: "Enlarge RootFS In CentOS7"
date: 2015-08-06 14:48:50 +0800
comments: true
categories: Virtualization
---
### Disk Preparation
Create a new disk via following command in host machine:    

```
# qemu-img create -f qcow2 Added.qcow2 200G
```
Boot the machine and you will have the newly added disk as `/dev/vdb`, format it via
`fdisk`.    

```
[root@spacewalker ~]# fdisk /dev/vdb
Welcome to fdisk (util-linux 2.23.2).

Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table
Building a new DOS disklabel with disk identifier 0x694e59ec.

Command (m for help): n
Partition type:
   p   primary (0 primary, 0 extended, 4 free)
   e   extended
Select (default p): p
Partition number (1-4, default 1): 
First sector (2048-419430399, default 2048): 
Using default value 2048
Last sector, +sectors or +size{K,M,G} (2048-419430399, default 419430399): 
Using default value 419430399
Partition 1 of type Linux and of size 200 GiB is set

Command (m for help): t
Selected partition 1
Hex code (type L to list all codes): 8e
Changed type of partition 'Linux' to 'Linux LVM'

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.
```

### Physical Volume
Create a physical volume and display the pv:    

```
[root@spacewalker ~]# pvcreate /dev/vdb1
  Physical volume "/dev/vdb1" successfully created
[root@spacewalker ~]# pvdisplay 
  --- Physical volume ---
  PV Name               /dev/vda3
  VG Name               rootvg01
  PV Size               96.46 GiB / not usable 23.00 MiB
  Allocatable           yes (but full)
  PE Size               32.00 MiB
  Total PE              3086
  Free PE               0
  Allocated PE          3086
  PV UUID               rq51pP-o3Pw-8mMs-kBiN-wLva-nfLf-Svd9uk
   
  "/dev/vdb1" is a new physical volume of "200.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/vdb1
  VG Name               
  PV Size               200.00 GiB
  Allocatable           NO
  PE Size               0   
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               cPijvf-qPYT-w4yi-MsFo-yEHs-O9t8-6FmXUU
```

### Add pv into VG(Volume group)
First vgdisplay for get the VG name, then added it into vg, check the free pe, now its
200 GiB available.   

```
[root@spacewalker ~]# vgdisplay 
  --- Volume group ---
  VG Name               rootvg01
  System ID             
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  2
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               1
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               96.44 GiB
  PE Size               32.00 MiB
  Total PE              3086
  Alloc PE / Size       3086 / 96.44 GiB
  Free  PE / Size       0 / 0   
  VG UUID               U98QSe-V6Kv-aYSf-cSsp-ln0H-IhuS-1oNsgV
   
[root@spacewalker ~]# vgextend  rootvg01 /dev/vdb1
  Volume group "rootvg01" successfully extended
[root@spacewalker ~]# vgdisplay 
  --- Volume group ---
  VG Name               rootvg01
  System ID             
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  3
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               1
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               296.41 GiB
  PE Size               32.00 MiB
  Total PE              9485
  Alloc PE / Size       3086 / 96.44 GiB
  Free  PE / Size       6399 / 199.97 GiB
  VG UUID               U98QSe-V6Kv-aYSf-cSsp-ln0H-IhuS-1oNsgV
```

### Enlarge the lv
Use following command for first get the lv name, then lvextend to the most available
space of the volume group.   

```
[root@spacewalker ~]# lvdisplay 
  --- Logical volume ---
  LV Path                /dev/rootvg01/lv01
  LV Name                lv01
  VG Name                rootvg01
  LV UUID                5U4JM5-nG7G-TdPd-6zZ0-fE05-oysa-jEJHQu
  LV Write Access        read/write
  LV Creation host, time localhost, 2015-07-29 18:11:18 +0800
  LV Status              available
  # open                 1
  LV Size                96.44 GiB
  Current LE             3086
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:0
   
[root@spacewalker ~]# lvextend -l +100%FREE /dev/rootvg01/lv01 
  Size of logical volume rootvg01/lv01 changed from 96.44 GiB (3086 extents) to 296.41 GiB (9485 extents).
  Logical volume lv01 successfully resized
[root@spacewalker ~]# lvdisplay 
  --- Logical volume ---
  LV Path                /dev/rootvg01/lv01
  LV Name                lv01
  VG Name                rootvg01
  LV UUID                5U4JM5-nG7G-TdPd-6zZ0-fE05-oysa-jEJHQu
  LV Write Access        read/write
  LV Creation host, time localhost, 2015-07-29 18:11:18 +0800
  LV Status              available
  # open                 1
  LV Size                296.41 GiB
  Current LE             9485
  Segments               2
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:0
```

Enlarge in the system level:    

```
[root@spacewalker ~]# df -HT
Filesystem                Type      Size  Used Avail Use% Mounted on
/dev/mapper/rootvg01-lv01 xfs       104G   19G   85G  19% /
devtmpfs                  devtmpfs  1.1G     0  1.1G   0% /dev
tmpfs                     tmpfs     1.1G     0  1.1G   0% /dev/shm
tmpfs                     tmpfs     1.1G  8.7M  1.1G   1% /run
tmpfs                     tmpfs     1.1G     0  1.1G   0% /sys/fs/cgroup
/dev/vda1                 xfs       207M  111M   96M  54% /boot
[root@spacewalker ~]# xfs_growfs /dev/rootvg01/lv01 
meta-data=/dev/mapper/rootvg01-lv01 isize=256    agcount=4, agsize=6320128 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=0        finobt=0
data     =                       bsize=4096   blocks=25280512, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=0
log      =internal               bsize=4096   blocks=12344, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
data blocks changed from 25280512 to 77701120
[root@spacewalker ~]# df -HT
Filesystem                Type      Size  Used Avail Use% Mounted on
/dev/mapper/rootvg01-lv01 xfs       319G   19G  300G   6% /
devtmpfs                  devtmpfs  1.1G     0  1.1G   0% /dev
tmpfs                     tmpfs     1.1G     0  1.1G   0% /dev/shm
tmpfs                     tmpfs     1.1G  8.7M  1.1G   1% /run
tmpfs                     tmpfs     1.1G     0  1.1G   0% /sys/fs/cgroup
/dev/vda1                 xfs       207M  111M   96M  54% /boot
```

Now you could enjoy the 300G size diskspace.     

### Tips on ext4

The Steps are quite the same, but resize via following command:    

```
# qemu-img resize xxx.qcow2 +300G
# lvextend -l +100%FREE /dev/vg_centos/lv_root 
# resize2fs /dev/vg_centos/lv_root 
```
