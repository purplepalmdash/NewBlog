---
layout: post
title: "用Qemu模拟ARM(2)"
date: 2013-07-08 15:18
comments: true
categories: Linux Virtualization Embedded
---
1\. 关于Bootloader:

(引导程序)位于电脑或其他计算机应用上，是指引导操作系统启动的程序。引导程序启动方式和程序视应用机型种类而不同。例如在普通的个人电脑上，引导程序通常分为两部分：第一阶段引导程序位于主引导记录（MBR），用以引导位于某个分区上的第二阶段引导程序，如NTLDR、GNU
GRUB等。

 嵌入式系统中常见的Bootloader主要有以下几种:

* Das U-Boot
  是一个主要用于嵌入式系统的开机载入程序，可以支持多种不同的计算机系统结构，包括PPC、ARM、AVR32、MIPS、x86、68k、Nios与MicroBlaze。
* vivi是由mizi公司设计为ARM处理器系列设计的一个bootloader.
* Redboot (Red Hat Embedded Debug and Bootstrap)是Red
  Hat公司开发的一个独立运行在嵌入式系统上的BootLoader程序，是目前比较流行的一个功能、可移植性好的BootLoader。

2\. 关于“裸机编程(Bare-Metal)”:

微控制器开发人员很熟悉这个概念，
Bare-Metal是指的你的程序和处理器之间没有任何东西----你写的程序将直接运行在处理器上,
换言之，开发人员是在直接操控硬件。在裸机编程的场景中，需要由开发人员检查并排除任何一个可以导致系统崩溃的风险。

"Bare-Metal"要求开发人员了解关于硬件的细节，所以接下来我们将对编译链和qemu本身进行分析。

3\. 下载qemu源码包并查询相关硬件信息：

ArchLinux采用ABS(Arch Build
System)来管理源码包，下面的步骤将qemu源码包下载到本地，更详细的关于ABS的操作可以在ArchLinux的Wiki中找到

```
	$ pacman -S abs
	$ pacman -Ss qemu
	extra/qemu 1.4.2-2 [installed]
	$ abs extra/qemu 
	$ cp -r /var/abs/extra/qemu/ ~/abs 
	$ cd ~/abs && makepkg -s --asroot -o
```

得到versatilepb开发板的CPU型号, 可以看到"arm926"是我们要的结果。

```
	$ grep "arm" src/qemu-1.4.2/hw/versatilepb.c 
	#include "arm-misc.h"
	static struct arm_boot_info versatile_binfo;
	        args->cpu_model = "arm926";
	    cpu = cpu_arm_init(args->cpu_model);
	    cpu_pic = arm_pic_init_cpu(cpu);
	    arm_load_kernel(cpu, &versatile_binfo);
```

得到versatilepb开发板的串口寄存器硬件信息：

```
	$ grep "UART*" src/qemu-1.4.2/hw/versatilepb.c 
	    /*  0x10009000 UART3.  */
	    /*  0x101f1000 UART0.  */
	    /*  0x101f2000 UART1.  */
	    /*  0x101f3000 UART2.  */
```

所以说开源是王道嘛，很快就查到了每一个需要了解的细节。UART0在内存中map到的地址是0x101f1000,
我们直接往这个地址写数据，就可以在终端上看到数据输出了。

4\. 查看编译链支持的平台：

```
	$ cat ~/CodeSourcery/Sourcery_CodeBench_Lite_for_ARM_EABI/share/doc/arm-arm-none-eabi/info/gcc.info | grep arm926
	     `arm926ej-s', `arm940t', `arm9tdmi', `arm10tdmi', `arm1020t',
```

arm926ej-s是被支持的，因此我们可以用这套编译链来生成需要的裸机调试代码。

5\. 启动应用程序init.c的编写:

首先创建应用程序init.c：

{% codeblock init.c - init.c %}
volatile unsigned char * const UART0_PTR = (unsigned char *)0x0101f1000;
void display(const char *string){
    while(*string != '\0'){
        *UART0_PTR = *string;
        string++;
    }
}
 
int my_init(){
    display("Hello Open World\n");
}
{% endcodeblock %}
init.c中，我们首先声明一个volatile变UART0_PTR,volatile关键字用于告知编译器此变量是用于直接访问内存映像设备的，即串口0内存地址

display()函数则是用于将字符串中的字符按顺序输出到串口0, 直到遇到字符串结尾。

my_init()调用了display(), 接下来我们将把它作为C入口函数.

预编译init.c:

```
	$ arm-none-eabi-gcc -c -mcpu=arm926ej-s init.c -o init.o
```

6\. 启动代码start.s编写：
{% codeblock start.s - start.s %}
.global _Start
_Start:
LDR sp, = sp_top
BL my_init
B .
{% endcodeblock %}
处理器加电后，将跳转到指定的内存地址,从此地址开始读入并执行代码。

\_Start被声明为全局函数，\_Start的实现中，首先将栈地址指向sp_top, LDR(load),
sp是栈地址寄存器(stack pointer),

BL则是跳转指令，跳转到my_init函数，事实上你可以跳转到任何一个你想跳转的函数，临时写一个their_init()跳转过去也行。Debug时常更改这里以调试不同的子系统功能。

"B."可以理解为汇编里的while(1)或for(;;)循环，处理器空转，什么也不做。如果不调用它，系统就会崩溃。所谓嵌入式编程的一个基本理念就是，代码无限循环。

预编译汇编文件start.s:
	$ arm-none-eabi-as -mcpu=arm926ej-s startup.s -o startup.o


7\. 接下来我们需要用一个可以被编译器识别的链接脚本链接两文件, linker.ld:
{% codeblock %}
	ENTRY(_Start)
	SECTIONS
	{
	. = 0x10000;
	startup : { startup.o(.text)}
	.data : {*(.data)}
	.bss : {*(.bss)}
	. = . + 0x500;
	sp_top = .;
	}
{% endcodeblock %}
ENTRY(\_Start)用于告知链接器程序的入口点(entry point)是\_Start(start.s中定义).
Qemu模拟器如果加上-kernel选项时，将自动从0x10000开始执行，所以我们必须将代码放到这个地址。所以第四行我们指定".
= 0x10000". SECTIONS就是用于定义程序的不同部分的。

startup.o组成了代码的text部分，然后是data部分和bss部分，最后一步则定义了栈指针(sp,
stack pointer)地址. 栈通常是向下增长的，所以最好给它一个比较安全的地址， . =
.+0x500就是用于避免栈被改写的。sp_top用于存储栈顶地址。

有关程序结构：

* BSS段:  在采用段式内存管理的架构中，BSS段（bss segment）通常是指用来存放程序中未初始化的全局变量的一块内存区域。BSS是英文Block Started by Symbol的简称。BSS段属于静态内存分配。.bss section的空间结构类似于stack, 主要用于存储静态变量、未显式初始化、在变量使用前由运行时初始化为零。
* 数据段(data segment): 通常是指用来存放程序中已初始化且不为0的全局变量的一块内存区域。数据段属于静态内存分配。
* 代码段(code segment/text segment): 通常是指用来存放程序执行代码的一块内存区域。这部分区域的大小在程序运行前就已经确定，并且内存区域通常属于只读,某些架构也允许代码段为可写，即允许程序自修改。在代码段中，也有可能包含一些只读的常数变量，例如字符串常量等。

编译:

```
	$ arm-none-eabi-ld -T linker.ld init.o startup.o -o output.elf
	$ file output.elf 
	output.elf: ELF 32-bit LSB  executable, ARM, EABI5 version 1 (SYSV),statically linked, not stripped
	$  arm-none-eabi-objcopy -O binary output.elf output.bin
	$ file output.bin 
	output.bin: data
```

8\. 使用qemu-system-arm运行output.bin:

```
	$ qemu-system-arm --help | grep nographic 
	-nographic      disable graphical output and redirect serial I/Os to console.
	$ qemu-system-arm -M versatilepb -nographic -kernel output.bin
	Hello Open World
```


9\. Play more tricks:
改动init.c里的串口输出地址为串口1：

```
	volatile unsigned char * const UART0_PTR = (unsigned char *)0x0101f2000;
		// 0x101f1000  --> 0x101f2000
```

按照步骤3～7里重新编译，并运行以查看结果:

```
	# 没有反应！
	$ qemu-system-arm -M versatilepb -nographic -kernel output.bin
	# 终端有输出字符。
	$ qemu-system-arm -M versatilepb -kernel output.bin -serial vc:800x600 -serial stdio
	Hello Open World
```

同样你也可以把字符输出到第三个串口，只不过前两个-serial的重定向需要指定到别的设备而已。

