---
layout: post
title: "用Qemu模拟ARM(3)"
date: 2013-07-08 16:35
comments: true
categories: Linux Virtualization Embedded
---
1\. 下载并交叉编译u-boot。

新版本的u-boot我加载后总有问题，2009.11版则可以顺利通过编译和测试。

```
	$ wget ftp://ftp.denx.de/pub/u-boot/u-boot-2009.11.tar.bz2
	$ tar xjvf u-boot-2009.11.tar.bz2 
	$ cd u-boot-2009.11
	$ make versatilepb_config arch=ARM CROSS_COMPILE=arm-none-eabi-
	$ make all arch=ARM CROSS_COMPILE=arm-none-eabi- 
```

编译完成后会在目录下生成u-boot.bin和u-boot文件。

2\. 运行u-boot.bin: 

```
	$ qemu-system-arm -M versatilepb -kernel u-boot.bin -nographic
```

如果采用-nographic来运行qemu-system-arm，终端将无法再响应任何系统输入譬如Ctrl+c/ctrl+d_，要终止qemu-system-arm就只能查到进程号再kill。所以我一般不带-nographic选项，启动后ctrl+alt+2去看serial0输出,保留在终端窗口直接ctrl+c杀死qemu-sytem-arm进程的权力。

3\. 用u-boot引导镜像文件:

改动上一篇文章里用于构建启动镜像的linker.ld文件，因为u-boot.bin文件大小的缘故，我们需要把启动镜像的起始地址整体上移.

```
	$ ls -l -h u-boot.bin 
	-rwxr-xr-x 1 Trusty root 85K Jul  8 15:57 u-boot.bin
```

linker.ld文件里， 0x100000，这个大小相比于85K显然已经足够。

```
	ENTRY(_Start)
	SECTIONS
	{
	. = 0x100000;
	startup : { startup.o(.text)}
	.data : {*(.data)}
	.bss : {*(.bss)}
	. = . + 0x500;
	sp_top = .;
	}
```

按上一章的编译方法生成output.bin，不再重述。

使用mkimage工具创建u-boot可识别的image文件：

```
	$ mkimage -A arm -C none -O linux -T kernel -d output.bin -a 0x00100000 -e 0x00100000 output.uimg
	Image Name:   
	Created:      Mon Jul  8 16:04:11 2013
	Image Type:   ARM Linux Kernel Image (uncompressed)
	Data Size:    152 Bytes = 0.15 kB = 0.00 MB
	Load Address: 00100000
	Entry Point:  00100000
	
	$ file *.uimg
	output.uimg: u-boot legacy uImage, , Linux/ARM, OS Kernel Image (Not \
	compressed), 152 bytes, Mon Jul  8 16:04:11 2013, Load Address: 0x00100000,\
	Entry Point: 0x00100000, Header CRC: 0x3C62F575, Data CRC: 0x69CE9647
```

将u-boot.bin和output.uimg打包为一个文件：

```
	$ cat u-boot.bin output.uimg >flash.bin
```

下面这条命令用于计算output.img在使用u-boot加载完flash.bin后在内存中的地址，-kernel选项告诉qemu从0x100000开始加载镜像，即65536。
65536+u-boot.bin后的大小，即output.img在内存中的地址。printf则是用16进制的格式打印出来，以便加载.

```
	$ printf "0x%X" $(expr $(stat -c%s u-boot.bin) + 65536)
	0x2525C
```

启动qemu-system-arm并运行自定义镜像:

```
	$ qemu-system-arm -M versatilepb -nographic -kernel flash.bin
	# iminfo 0x2525c
	
	## Checking Image at 0002525c ...
	   Legacy image found
	   Image Name:   
	   Image Type:   ARM Linux Kernel Image (uncompressed)
	   Data Size:    152 Bytes =  0.1 kB
	   Load Address: 00100000
	   Entry Point:  00100000
	   Verifying Checksum ... OK

	VersatilePB # bootm 0x2525c
	## Booting kernel from Legacy Image at 0002525c ...
	   Image Name:   
	   Image Type:   ARM Linux Kernel Image (uncompressed)
	   Data Size:    152 Bytes =  0.1 kB
	   Load Address: 00100000
	   Entry Point:  00100000
	   Loading Kernel Image ... OK
	OK
	
	Starting kernel ...
	
	Hello Open World
```

u-boot可以支持的选项还有很多，包括使用NFS/TFTP启动等等，留待以后慢慢研究。
