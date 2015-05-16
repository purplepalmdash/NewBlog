---
layout: post
title: "Qemu For RaspberryPI"
date: 2013-09-04 17:26
comments: true
categories: Linux Virtualization Embedded 
---
我用Qemu来仿真RaspberryPI以便快速测试内核模块的开发。下面是仿真的步骤：

1\. 下载镜像文件2013-07-26-wheezy-raspbian.img，并更改其配置使得可以被qemu-system-arm加载：
{% codeblock %}
$ fdisk -l 2013-07-26-wheezy-raspbian.img 
Disk 2013-05-25-wheezy-raspbian.img: 1939 MB, 1939865600 bytes, 3788800 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x000c7b31

                         Device Boot      Start         End      Blocks   Id  System
2013-05-25-wheezy-raspbian.img1            8192      122879       57344    c  W95 FAT32 (LBA)
2013-05-25-wheezy-raspbian.img2          122880     3788799     1832960   83  Linux

#从上面可以看到，根文件分区的地址偏移为512*122880=62914560

#更改根分区文件里preload信息:
$ sudo mount ./2013-07-26-wheezy-raspbian.img -o offset=62914560 /mnt3
$ sudo vim /mnt3/etc/ld.so.preload 
#注释掉这一行，否则在qemu启动完系统后将自动提示配置rpi而造成系统无法登陆
#/usr/lib/arm-linux-gnueabihf/libcofi_rpi.so
$ sudo umount /mnt3
{% endcodeblock %}

2\. 拷贝一个此时的img文件以便将来备用
{% codeblock %}
$ cp 2013-07-26-wheezy-raspbian.img 2.img
{% endcodeblock %}

3\. 配置qemu为bridge网络

qemu启动时需要调用的脚本： 
{% codeblock %}
$ cat /etc/qemu-ifup 
#!/bin/sh
  
echo "Executing /etc/qemu-ifup"
echo "Bringing up $1 for bridged mode..."
sudo /usr/bin/ip link set $1 up promisc on
echo "Adding $1 to br0..."
sudo /usr/bin/brctl addif br0 $1
sleep 2
{% endcodeblock %}

qemu关闭时自动调用的脚本：
{% codeblock %}
$ cat /etc/qemu-ifdown
#!/bin/sh
 
echo "Executing /etc/qemu-ifdown"
sudo /usr/bin/ip link set $1 down
sudo /usr/bin/brctl delif br0 $1
sudo /usr/bin/ip link delete dev $1
{% endcodeblock %}
在镜像的当前目录下，创建run-qemu文件：
{% codeblock %}
#!/bin/bash
USERID=$(whoami)

# Get name of newly created TAP device; see https://bbs.archlinux.org/viewtopic.php?pid=1285079#p1285079
precreationg=$(/usr/bin/ip tuntap list | /usr/bin/cut -d: -f1 | /usr/bin/sort)
sudo /usr/bin/ip tuntap add user $USERID mode tap
postcreation=$(/usr/bin/ip tuntap list | /usr/bin/cut -d: -f1 | /usr/bin/sort)
IFACE=$(comm -13 <(echo "$precreationg") <(echo "$postcreation"))

# This line creates a random mac address. The downside is the dhcp server will assign a different ip each time
printf -v macaddr "52:54:%02x:%02x:%02x:%02x" $(( $RANDOM & 0xff)) $(( $RANDOM & 0xff )) $(( $RANDOM & 0xff)) $(( $RANDOM & 0xff ))
# Instead, uncomment and edit this line to set an static mac address. The benefit is that the dhcp server will assign the same ip.
# macaddr='52:54:be:36:42:a9'
 
qemu-system-arm -net nic,macaddr=$macaddr -net tap,ifname="$IFACE" $*
  
sudo ip link set dev $IFACE down &> /dev/null
sudo ip tuntap del $IFACE mode tap &> /dev/null 
{% endcodeblock %}
因为tap需要用到tun模块，所以增加tun到自动加载的模块中
{% codeblock %}
$ cat /etc/modules-load.d/tun.conf 
# Load tun at boot
tun
{% endcodeblock %}

添加visudo条目：
{% codeblock %}
Cmnd_Alias      QEMU=/usr/bin/ip,/usr/bin/modprobe,/usr/bin/brctl
%kvm     ALL=NOPASSWD: QEMU
{% endcodeblock %}

添加用户到kvm组：
{% codeblock %}
$ usermod -a -G kvm username
{% endcodeblock %}

4\. 启动qemu，使用两个镜像，以调整磁盘大小。
{% codeblock %}
# 增加2G大小给镜像
$ qemu-img resize ./2013-07-26-wheezy-raspbian.img +2G
$ ./run-qemu -kernel kernel-qemu -cpu arm1176 -m 256 -M versatilepb -no-reboot -serial stdio -append "root=/dev/sda2 panic=1" -hda ./2.img -hdb ./2013-07-26-wheezy-raspbian.img 
进入Qemu后，
$ sudo apt-get install gparted
$ sudo gparted /dev/sdb
调整到自己想要的大小即可。
{% endcodeblock %}

5\. 重新启动后用下列命令启动Qemu:
{% codeblock %}
$ ./run-qemu -kernel kernel-qemu -cpu arm1176 -m 256 -M versatilepb -no-reboot -serial stdio -append "root=/dev/sda2 panic=1" -hda ./2013-07-26-wheezy-raspbian.img 
{% endcodeblock %}

使用上列步骤所启动起来的RaspberryPI镜像，具备完整的网络支持和足够的存储空间，而运行速度也令人满意。对比于真实的RaspberryPI板，编译、验证、烧写过程都较为简单，大部分研发工作可以基于这个平台来做。
