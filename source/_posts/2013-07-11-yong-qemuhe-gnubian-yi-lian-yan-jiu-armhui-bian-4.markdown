---
layout: post
title: "用Qemu和GNU编译链研究ARM汇编(4)"
date: 2013-07-11 21:46
comments: true
categories: Linux Embedded Virtualization
---
1\. 有关异常向量

前面的例子中存在一个大BUG，内存布局中的前8个全字是为异常向量而保留的。当异常发生时控制逻辑将转到这些位置以执行对应的异常处理代码。异常向量和它们的地址如下：

* Exception	 Address
* Reset	 0x00
* Undefined Instruction	 0x04
* Software Interrupt (SWI)	 0x08
* Prefetch Abort	 0x0C
* Data Abort	 0x10
* Reserved, not used	 0x14
* IRQ	 0x18
* FIQ	 0x1C

按理说，这些个异常向量应该对应到异常处理程序中，既然我们代码中不会有异常发生，索性就用死循环来代替，如下：
{% codeblock vector.s -vector.s %}
        .section "vectors"
reset:  b     start
undef:  b     undef
swi:    b     swi
pabt:   b     pabt
dabt:   b     dabt
        nop
irq:    b     irq
fiq:    b     fiq
{% endcodeblock %}

对应的，为了确保这些指令被放置在异常向量地址中，链接脚本也需要做相应的改动：
{% codeblock %}
SECTIONS {
        . = 0x00000000;
        .text : {
                * (vectors);
                * (.text);
                ...
        }
        ...
}
{% endcodeblock %}

异常向量需要放置在所有代码之前，这确保了代了向量是从0x0地址开始。

2\. C启动代码

直接执行C代码会造成CPU直接重启，因为和汇编代码不同的是C语言需要初始化运行环境。
{% codeblock sum.c -sum.c %}
static int arr[] = { 1, 10, 4, 5, 6, 7 };
static int sum;
static const int n = sizeof(arr) / sizeof(arr[0]);

int main()
{
        int i;

        for (i = 0; i < n; i++)
                sum += arr[i];
}
{% endcodeblock %}
C语言运行环境需要设置
1. 栈
2. 全局变量： 已初始化的 && 未初始化的
3. 只读数据

2\.1 栈设置

栈被用来存储自动变量，传递函数变量，存储返回地址等等。ARM Architecture
Procedure Call Standard
(AAPCS)是ARM体系结构中用于生成栈的规则。r13被用于作栈指针。

对于特定的开发板来说，栈开始地址可能不同，对于connex开发板来说，地址可以用下面的代码来定义：

```
	ldr sp, =0xA4000000
```

2\.2 全局变量

C代码在编译时会把已初始化的全局变量放在.data段中，因而在初始化的汇编代码中，需要把.data段从Flash搬移到RAM中。

C代码确保未初始化的全局变量被初始化成0.
当C程序被编译时，独立的.bss段被用作未初始化的变量。因为未初始化的值都是0,我们无需将其存储在FLASH中。只不过在搬移的时候，我们需要在程序中将它们初始化为0而已。

2\.3 只读数据

const常量会被初始化为.rodata， .rodata也被用于存储字符常量。

.rodata在运行时不会被改变，所以它们可以被直接放置在FLASH中。

2\.4 启动代码

Linker脚本需要做下面的事：
1. .bss部分代替
2.  vectors部分代替
3. .rodata部分代替

{% codeblock %}
SECTIONS {
        . = 0x00000000;
        .text : {
              * (vectors);
              * (.text);
        }
        .rodata : {
              * (.rodata);
        }
        flash_sdata = .;

        . = 0xA0000000;
        ram_sdata = .;
        .data : AT (flash_sdata) {
              * (.data);
        }
        ram_edata = .;
        data_size = ram_edata - ram_sdata;

        sbss = .;
        .bss : {
             * (.bss);
        }
        ebss = .;
        bss_size = ebss - sbss;
}
{% endcodeblock %}

启动代码需要完成下列任务：
1. 中断向量设置
2. 将.data部分从FLASH拷贝到RAM
3. 将.bss置0后拷贝到RAM
4. 设置栈指针(stack pointer)
5. 分支程序到main函数

{% codeblock startup.s - startup.s %}
        .section "vectors"
reset:  b     start
undef:  b     undef
swi:    b     swi
pabt:   b     pabt
dabt:   b     dabt
        nop
irq:    b     irq
fiq:    b     fiq

        .text
start:
        @@ Copy data to RAM.
        ldr   r0, =flash_sdata
        ldr   r1, =ram_sdata
        ldr   r2, =data_size

        @@ Handle data_size == 0
        cmp   r2, #0
        beq   init_bss
copy:
        ldrb   r4, [r0], #1
        strb   r4, [r1], #1
        subs   r2, r2, #1
        bne    copy

init_bss:
        @@ Initialize .bss
        ldr   r0, =sbss
        ldr   r1, =ebss
        ldr   r2, =bss_size

        @@ Handle bss_size == 0
        cmp   r2, #0
        beq   init_stack

        mov   r4, #0
zero:
        strb  r4, [r0], #1
        subs  r2, r2, #1
        bne   zero

init_stack:
        @@ Initialize the stack pointer
        ldr   sp, =0xA4000000

        bl    main

stop:   b     stop
{% endcodeblock %}

我们将直接用arm-none-eabi-gcc来编译所有程序：
	arm-none-eabi-gcc -nostdlib -o csum.elf -T csum.lds csum.c startup.s
-nostdlib选项用于指定标准C不应该被链接。

查看符号信息：

```
	arm-none-eabi-nm -n csum.elf 
	00000000 t reset
	00000004 A bss_size
	00000004 t undef
	00000008 t swi
	0000000c t pabt
	00000010 t dabt
	00000018 A data_size
	00000018 t irq
	0000001c t fiq
	00000020 T main
	00000094 t start
	000000a8 t copy
	000000b8 t init_bss
	000000d0 t zero
	000000dc t init_stack
	000000e4 t stop
	00000100 r n
	00000104 R flash_sdata
	a0000000 d arr
	a0000000 D ram_sdata
	a0000018 D ram_edata
	a0000018 D sbss
	a0000018 b sum
	a000001c B ebss
```

可以看到： 中断向量从0x0开始; 汇编代码从8个全字后开始(0x20==32==8*4);
只读数据n放在代码之后; arr，初始化后的数据，放在RAM中;
未初始化的数据,sum放在6个int之后6*4==24==0x18

转化成.bin二进制格式后，在Qemu中运行之，检查结果：

```
	$ arm-none-eabi-objcopy -O binary csum.elf csum.bin	
	$ dd if=/dev/zero of=./flash.bin bs=4K count=4K
  	$ dd if=csum.bin of=flash.bin bs=4096 conv=notrunc
  	$ qemu-system-arm -M connex -pflash flash.bin -nographic -serial /dev/null
	(qemu) xp /6dw 0xa0000000
	a0000000:          1         10          4          5
	a0000010:          6          7
	(qemu) xp /1dw 0xa0000018
	a0000018:         33
```

我们可以看到，1, 10, 4, 5, 6, 7 分别为数组元素，而结果为33,
储存在0x18的地址。如果感兴趣，我们大可查找出别的数据地址，这里就不一一述说了。

