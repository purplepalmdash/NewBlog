---
layout: post
title: "ArchLinux上安装arm编译链"
date: 2013-07-06 20:14
comments: true
categories: Linux Embedded
---
在X86_64的ArchLinux上安装Mentor Graphics提供的arm交叉编译链时出现下列问题：

```
	$ ./arm-2013.05-23-arm-none-eabi.bin 
	Checking for required programs: awk grep sed bzip2 gunzip
	===============================================================
	Error: Missing 32-bit libraries on 64-bit Linux host
	===============================================================
	Your 64-bit Linux host is missing the 32-bit libraries
	required to install and use Sourcery CodeBench.
```

解决方法：

编辑/etc/pacman.conf，去掉下列两行的注释

```
	[multilib]
	Include = /etc/pacman.d/mirrorlist
```

而后安装必要的ia32相关的包：

```
	$ pacman -Sy
	$ pacman -S lib32-glibc
	$ pacman -S lib32-gtk lib32-gtk2
```

安装好以后执行前面被中断的安装进程，这时候可以顺利安装了。

安装完毕后记得把交叉编译链的路径加入到系统路径中，最好在~/.bashrc里加上一笔:

```
	export PATH=$HOME/CodeSourcery/Sourcery_CodeBench_Lite_for_ARM_EABI/bin:$PATH
	export PATH=$HOME/CodeSourcery/Sourcery_CodeBench_Lite_for_ARM_GNU_Linux/bin:$PATH
```

ArchLinux的yaourt仓库里也有arm-none-eabi和arm-none-linux-eabi等交叉编译链，但是每次编译都会出现莫名其妙的错误，使用现成的编译链能大大节省开发时间。
