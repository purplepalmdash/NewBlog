---
layout: post
title: "Arm1136 Kernel For Raspberry PI"
date: 2013-09-04 20:36
comments: true
categories: Linux Embedded Virtualization
---
qemu-system-arm可以直接使用内核用于加载系统。通常情况下我们可以用预编译好的第三方提供的内核来启动系统，然而如果我们需要用到定制的内核，就需要对内核进行编译了。下面的步骤将讲述如何编译出基于arm1136架构的raspberry PI内核。

1\. 安装交叉编译链。

ArchLinux中，可以直接从Yaourt仓库里通过“yaourt gnueabihf”查找对应的包，编译的过程不再详述。安装完后，在终端输入arm-(Tab)应该可以看到arm-linux-gnueabihf-开头的编译器。

2\. 准备内核源码。
{% codeblock %}
# 从github下载源码
$ git clone https://github.com/raspberrypi/linux.git
# Apply Patch
$ wget http://xecdesign.com/downloads/linux-qemu/linux-arm.patch
$ patch -p1 -d linux/ < linux-arm.patch
{% endcodeblock %}

3\. 配置、编译内核。
{% codeblock %}
# 加载默认配置
$ cd linux
$ make ARCH=arm versatile_defconfig

# 自定义内核
$ make ARCH=arm menuconfig

# 设置编译器
General Setup --->
Cross-compiler tool prefix
(arm-linux-gnueabihf-)

# 选择正确的CPU
System Type --->
[*] Support ARM V6 processor
[*] ARM errata: Invalidation of the Instruction Cache operation can fail
[*] ARM errata: Possible cache data corruption with hit-under-miss enabled

# 激活浮点运算
Floating point emulation  --->
[*] VFP-format floating point maths

# 激活ARM EABI
Enable ARM EABI:
Kernel Features --->
[*] Use ARM EABI to compile the kernel
[*] Allow old ABI binaries to run with this kernel

# 激活QEMU磁盘支持
Bus Support --->
[*] PCI Support
Device Drivers --->
SCSI Device Support --->
[*] SCSI Device Support
[*] SCSI Disk Support
[*] SCSI CDROM support
[*] SCSI low-lever drivers --->
[*] SYM53C8XX  Version 2 SCSI support

# 激活devtmpfs
Device Drivers --->
Generic Driver Options--->
[*] Maintain a devtmpfs filesystem to mount at /dev
[*] Automount devtmpfs at /dev, after the kernel mounted the root

# 激活重要的文件系统
Enable the important file systems:
<*> Ext3 journalling file system support
 <*> The Extended 4 (ext4) filesystem

# 激活tmpfs
File systems --->
Pseudo filesystems--->
[*] Virtual memory file system support (former shm fs)

# 激活event接口
Device Drivers --->
Input device support--->
[*] Event interface

# 激活/proc/config.gz
General Setup --->
[*] Kernel .config support
[*] Enable access to .config through /proc/config.gz

# 启动时字体配置和LOGO配置
Device Drivers --->
Graphics Support --->
Console display driver support --->
[ ] Select compiled-in fonts
[*] Bootup logo (optional)

现在退出并保存.config

#开始编译内核
$ cd linux
$ make ARCH=arm
$ make ARCH=arm INSTALL_MOD_PATH=../modules modules_install

{% endcodeblock %}


4\. 使用新编译出的内核启动系统

{% codeblock %}
$ cp arch/arm/boot/zImage /Your_Qemu_Directory
$ qemu-system-arm -kernel zImage //Your Options.
{% endcodeblock %}


使用自定义内核的好处是可以方便的激活某些高阶功能，例如NFS, Netfilter等等，一般情况下，默认提供的内核就已经可以满足我们的需要了。
