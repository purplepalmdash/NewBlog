---
layout: post
title: "用Qemu和GNU编译链研究ARM汇编(1)"
date: 2013-07-09 20:42
comments: true
categories: Linux Virtualization Embedded
---
1\. 汇编程序代码格式

汇编代码由一系列的声明所组成，每行一个。每条声明由下列格式组成：

```
	label(标签):	instruction	@comment(注释)
```


说明：

* label:
标签的引入使得在内存中查询指令地址变得很方便，标签可以在任意一个内存地址使用，
例如分支指令中就可以用到标签, 标签可以包括字母、数字_和$符号。
* 注释：
注释内容必须在@符号之后
* 指令:
指令可以是ARM指令集或是汇编器指令，汇编器指令是需要传递给汇编器的命令，总是以.开头。

2\. 一个简单的汇编语言文件:
{% codeblock add.s -add.s %}
        .text
start:                       @ Label, not really required
        mov   r0, #5         @ Load register r0 with the value 5
        mov   r1, #4         @ Load register r1 with the value 4
        add   r2, r1, r0     @ Add r0 and r1 and store in r2

stop:   b stop               @ Infinite loop to stop execution
{% endcodeblock %}

上面代码的意思是，把立即数5载入到寄存器r0, 4载入到r1,
以r1和r0相加的结果填充r2.

.text是汇编器指令，用于告知汇编器需要把代码组装到code段,而不是.data段。有关section的概念在后面将被讲到。

3\. 编译二进制文件

GNU的汇编器名字叫as， 用下列命令将源文件编译成.o文件

```
	$ arm-none-eabi-as -o add.o add.s
```

链接器的名字叫ld，用下列命令可以将二进制文件链接成elf文件

```
	$ arm-none-eabi-ld -Ttext=0x0 -o add.elf add.o
```

-Ttext指明需要分配给label的地址,
这条指令告诉链接器从地址0x0开始装载指令。我们可以用nm来查看具体的地址分配信息。

```
	$ arm-none-eabi-nm add.elf 
	00008010 T __bss_end__
	00008010 T _bss_end__
	00008010 T __bss_start
	00008010 T __bss_start__
	00008010 T __data_start
	00008010 T _edata
	00008010 T _end
	00008010 T __end__
	00080000 T _stack
	00000000 t start
	         U _start
	0000000c t stop
```

start和stop之间由0c个字节，因为stop是在start开始后三条指令，
每条指令的长度为4个Byte，3*4=12=0xc

更改链接的参数将得到不同的地址分配。

```
	$ arm-none-eabi-ld -Ttext=0x20000000 -o add.elf add.o
	arm-none-eabi-ld: warning: cannot find entry symbol _start; defaulting to 20000000
	$ arm-none-eabi-nm add.elf
	20008010 T __bss_end__
	20008010 T _bss_end__
	20008010 T __bss_start
	20008010 T __bss_start__
	20008010 T __data_start
	20008010 T _edata
	20008010 T _end
	20008010 T __end__
	00080000 T _stack
	20000000 t start
	         U _start
	2000000c t stop
```

ld得到的文件一般是ELF文件，在有操作系统的时候ELF可以工作的很好，但是我们将在裸机模式下(Bare
Metal)运行此程序， 因此需要将文件类型转化为更简单的binary类型。

GNU编译链的objcopy可以完成不同可执行文件之间的转换：

```
	$ arm-none-eabi-objcopy -O binary add.elf add.bin
	$ file add.bin
	add.bin: Hitachi SH big-endian COFF
```

4\. 在Qemu中执行二进制文件。

我们将使用connex开发板来模拟运行此程序，它把16MB的Flash放在地址0x0，而通常arm处理器重启时都会执行0x0处的代码。
因而我们需要把add.bin写入到16MB Flash文件的头部。

首先创建一个空的16MB Flash文件

```
	$ dd if=/dev/zero of=flash.bin bs=4k count=4k
	4096+0 records in
	4096+0 records out
	16777216 bytes (17 MB) copied, 0.0153106 s, 1.1 GB/s
```

而后，使用下列命令将add.bin放到Flash头部

```
	$ dd if=add.bin of=flash.bin bs=4K conv=notrunc
	0+1 records in
	0+1 records out
	16 bytes (16 B) copied, 0.00011154 s, 143 kB/s
```

add.bin大小刚好为16B, notrunc参数代表no truncated，意思是直接覆盖掉原有内容。 

用下列命令执行此改动后的flash文件:

```
	$ qemu-system-arm -M connex -pflash flash.bin -nographic -serial /dev/null
	QEMU 1.4.2 monitor - type 'help' for more information
```

-M connex 指定connex机器， -pflash指定flash.bin代替flash闪存。

-pflash file    use 'file' as a parallel flash image 并行flash镜像

-serial /dev/null 将connex的串口输出重定向到/dev/null

查看寄存器信息：

```
	(qemu) info registers
	R00=00000005 R01=00000004 R02=00000009 R03=00000000
	R04=00000000 R05=00000000 R06=00000000 R07=00000000
	R08=00000000 R09=00000000 R10=00000000 R11=00000000
	R12=00000000 R13=00000000 R14=00000000 R15=0000000c
	PSR=400001d3 -Z-- A svc32
	FPSCR: 00000000
```

R02的值正是计算后的结果4+5=9.
R15=0000000c 猜测应该为指令寄存器，指向stop(0xc)

5\. 更多的查看命令:
{% codeblock %}
help	 List available commands
quit	 Quits the emulator
xp /fmt addr	 Physical memory dump from addr
system_reset	 Reset the system.
{% endcodeblock %}


```
	(qemu) help xp
	xp /fmt addr -- physical memory dump starting at 'addr'
	(qemu) xp /4iw 0x0
	0x00000000:  e3a00005      mov	r0, #5	; 0x5
	0x00000004:  e3a01004      mov	r1, #4	; 0x4
	0x00000008:  e0812000      add	r2, r1, r0
	0x0000000c:  eafffffe      b	0xc
```


4: 4 个条目被显示, i表示打印出指令，即内建的反汇编，
w表明条目的大小为32个bit，即一个全字。

