---
layout: post
title: "用Qemu模拟ARM(1)"
date: 2013-07-08 10:45
comments: true
categories: Linux Virtualization Embedded
---
前面已经安装并配置了编译链和qemu，现在可以用qemu来模拟arm平台了。

1\. Hello, Qemu!

输入下面的代码:
{% codeblock hello.c - hello.c %}
#include<stdio.h>
int main()
{
    printf("Hello, Qemu!\n");
    return 0;
}
{% endcodeblock %}
编译并运行:

```
	$ arm-none-linux-gnueabi-gcc -o hello hello.c -static
	$ qemu-arm ./hello
	$ file hello
	hello: ELF 32-bit LSB  executable, ARM, EABI5 version 1 (SYSV), \
	 statically linked, for GNU/Linux 2.6.16, not stripped
```

不加-static变量的话，运行时则需要使用-L选项链接到相应的运行库

```
	$ qemu-arm -L /home/Trusty/CodeSourcery/\
	Sourcery_CodeBench_Lite_for_ARM_GNU_Linux/\
	arm-none-linux-gnueabi/libc/  ./hello_1 
	Hello, Qemu!
	$ file hello_1
	hello_1: ELF 32-bit LSB  executable, ARM, EABI5 version 1 (SYSV),\
	 dynamically linked (uses shared libs), for GNU/Linux 2.6.16, not stripped
```

动态编译和静态编译生成的文件大小差别：

```
	$ ls -l -h
	total 656K
	-rwxr-xr-x 1 Trusty root 640K Jul  7 18:46 hello
	-rwxr-xr-x 1 Trusty root 6.6K Jul  7 18:48 hello_1
```

###小插曲1：

系统里安装了两套编译链arm-none-eabi-和arm-none-linux-eabi-,很容易让人混淆，可参考编译链的命名规则：

arch(架构)-vendor(厂商名)-(os(操作系统名)-)abi(Application Binary
Interface，应用程序二进制接口)

举例说明：

* x86_64-w64-mingw32 = x86_64 "arch"字段 (=AMD64), w64 (=mingw-w64
是"vendor"字段), mingw32 (=GCC所见的win32 API)
* i686-unknown-linux-gnu = 32位 GNU/linux编译链
* arm-none-linux-gnueabi = ARM 架构, 无vendor字段, linux 系统, gnueabi ABI.
* arm-none-eabi = ARM架构, 无厂商, eabi ABI(embedded abi)

两种编译链的主要区别在于库的差别，前者没有后者的库多，后者主要用于在有操作系统的时候编译APP用的。前者不包括标准输入输出库在内的很多C标准库，适合于做面向硬件的类似单片机那样的开发。因而如果采用arm-none-eabi-gcc来编译hello.c会出现链接错误。

###小插曲2：

qemu-arm和qemu-system-arm的区别：

* qemu-arm是用户模式的模拟器(更精确的表述应该是系统调用模拟器)，而qemu-system-arm则是系统模拟器，它可以模拟出整个机器并运行操作系统
* qemu-arm仅可用来运行二进制文件，因此你可以交叉编译完例如hello
world之类的程序然后交给qemu-arm来运行，简单而高效。而qemu-system-arm则需要你把hello
world程序下载到客户机操作系统能访问到的硬盘里才能运行。

2\. 使用qemu-system-arm运行Linux内核

从www.kernel.org下载最新内核,而后解压

```
	$ tar xJf linux-3.10.tar.xz
	$ cd linux-3.10
	$ make ARCH=arm versatile_defconfig
	$ make menuconfig ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi-
```

上面的命令指定内核架构为arm，交叉编译链为arm-none-linux-gnueabi,
需要在make menuconfig弹出的窗口中选择到 “Kernel Features”, 激活“Use the ARM
EABI to compile the kernel”,
如果不激活这个选项的话，内核将无法加载接下来要制作的initramfs。

如果需要在u-boot上加载内核，就要编译为uImage的格式，uImage通过mkimage程序来压缩的，ArchLinux的yaourt仓库里可以找到这个包：

```
	$ yaourt -S mkimage
```

安装好mkimage后，开始编译内核，因为CPU有4核，所以开启了-j8选项以加速编译:

```
	$ make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi- all -j8 uImage 
```

接下来我们可以在qemu-system-arm中测试我们的内核了

```
	$ qemu-system-arm -M versatilepb -m 128M -kernel ./arch/arm/boot/uImage
```

在弹出的窗口中可以内核运行到了kernel
panic状态，这是因为内核无法加载root镜像的缘故，我们将制作一个最简单的hello
world的文件系统，告知kernel运行之。

{% codeblock init.c - init.c %}
#include <stdio.h>
 
void main() {
	  printf("Hello World!\n");
	  while(1);
}
{% endcodeblock %}
编译并制作启动镜像:

```
	$ arm-none-linux-gnueabi-gcc -o init init.c -static
	$ echo init |cpio -o --format=newc > initramfs
	1280 blocks
	$ file initramfs 
	initramfs: ASCII cpio archive (SVR4 with no CRC)
```

接下来我们回到编译目录下执行：

```
	$ qemu-system-arm -M versatilepb -kernel ./arch/arm/boot/uImage  -initrd
	../initramfs -serial stdio -append "console=tty1"
```

这时候可以看到，kernel运行并在Qemu自带的终端里打印出"Hello World!"。

如果我们改变console变量为ttyAMA0, 将在启动qemu-system-arm的本终端上打印出qemu的输出。
