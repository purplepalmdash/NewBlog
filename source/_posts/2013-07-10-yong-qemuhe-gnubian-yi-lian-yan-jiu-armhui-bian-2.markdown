---
layout: post
title: "用Qemu和GNU编译链研究ARM汇编(2)"
date: 2013-07-10 16:30
comments: true
categories: Linux Virtualization Embedded
---
研究两个汇编程序, 通过研究这两个程序，初步了解ARM汇编的知识：

* 用于求数组和的程序
* 用于计算字符串长度的程序

1\. 数组求和
{% codeblock sum.s - sum.s %}
        .text
entry:  b start                 @ Skip over the data
arr:    .byte 10, 20, 25        @ Read-only array of bytes
eoa:                            @ Address of end of array + 1

        .align
start:
        ldr   r0, =eoa          @ r0 = &eoa
        ldr   r1, =arr          @ r1 = &arr
        mov   r3, #0            @ r3 = 0
loop:   ldrb  r2, [r1], #1      @ r2 = *r1++
        add   r3, r2, r3        @ r3 += r2
        cmp   r1, r0            @ if (r1 != r2)
        bne   loop              @    goto loop
stop:   b stop
{% endcodeblock %}

.byte声明：

.byte声明的变量在内存中以连续的比特存在，.2byte和.4byte与之类似，分别用于存储16位值和32位值。联想到C语言中的内建数据结构定义，不难想象char/int/long int 预编译完是哪一种类型。

通用语法结构如下：

```
	.byte   exp1, exp2, ...
	.2byte  exp1, exp2, ...
	.4byte  exp1, exp2, ...
```

你可以指定数据的格式，二进制用前缀0b/0B修饰，八进制以前缀0修饰，十进制/十六进制以0x/0X开头。整数也可以用字符常量来表示，加上单引号即可，在这种情况下ASCII码会被用到。

也可以用C表达式，包含文字和其他符号的组合，如下例：

```
	pattern:  .byte 0b01010101, 0b00110011, 0b00001111
	npattern: .byte npattern - pattern
	halpha:   .byte 'A', 'B', 'C', 'D', 'E', 'F'
	dummy:    .4byte 0xDEADBEEF
	nalpha:   .byte 'Z' - 'A' + 1
```

.align声明：

ARM指令需要32位对齐，指令的起始内存地址需要是4的倍数，所以用.align指令来插入无用的byte，来确保下一条指令的起始地址是4的倍数。在代码中存在byte或是半字(half words)的时候，需要用到这条指令。

编译&运行：

```
	# assemble
	$ arm-none-eabi-as -o sum.o sum.s 
	# link to elf file
	$ arm-none-eabi-ld -Ttext=0x0 -o sum.elf sum.o
	# form bin file
	$ arm-none-eabi-objcopy -O binary sum.elf sum.bin
	# form flash image
	$ dd if=/dev/zero of=flash.bin bs=4k count=4k
	$ dd if=sum.bin of=flash.bin bs=4K conv=notrunc
	# emulate with flash image
	$ qemu-system-arm -M connex -pflash flash.bin -nographic -serial /dev/null
	# examine the result
	R00=00000007 R01=00000007 R02=00000019 R03=00000037
	R04=00000000 R05=00000000 R06=00000000 R07=00000000
	R08=00000000 R09=00000000 R10=00000000 R11=00000000
	R12=00000000 R13=00000000 R14=00000000 R15=00000024
	PSR=600001d3 -ZC- A svc32
	FPSCR: 00000000
```


R03的值正是我们求和的结果:  0x37==55==10+20+25, 可以用一张流程图来表示程序的运行过程


2\. 字符串长度
{% codeblock string.s - string.s %}
        .text
        b start

str:    .asciz "Hello World"

        .equ   nul, 0

        .align
start:  ldr   r0, =str          @ r0 = &str
        mov   r1, #0

loop:   ldrb  r2, [r0], #1      @ r2 = *(r0++)
        add   r1, r1, #1        @ r1 += 1
        cmp   r2, #nul          @ if (r1 != nul)
        bne   loop              @    goto loop

        sub   r1, r1, #1        @ r1 -= 1
stop:   b stop
{% endcodeblock %}

运行结果：

```
	(qemu) info registers
	R00=00000010 R01=0000000b R02=00000000 R03=00000000
	R04=00000000 R05=00000000 R06=00000000 R07=00000000
	R08=00000000 R09=00000000 R10=00000000 R11=00000000
	R12=00000000 R13=00000000 R14=00000000 R15=0000002c
	PSR=600001d3 -ZC- A svc32
	FPSCR: 00000000
```

r1是用来存储字符串长度的，计算结果为11。

.asciz声明:
 .asciz声明接受一个字符串作为参数，字符串以双引号修饰的字符表示。汇编器自动在字符串后面加nul字符（即\0字符）

.equ声明
汇编器维持一张符号表，符号表维持键->值的格式。当汇编器遇到一个标号时，汇编器将在符号表中自动建立一个条目。以后当汇编器遇到一个关于label的引用时，将自动替换为符号表中储存的label的地址。

使用汇编器指令.equ，我们可以手动在符号表中插入条目。

.equ通常这样定义:
	.equ name, expression

.equ不会分配任何内存，它们只是在符号表中插入条目罢了。

bne的意思是(!=) , b means bit. bit not equal. ble (<=), beq (==), bge (>=), bgt (>), and bne (!=).
