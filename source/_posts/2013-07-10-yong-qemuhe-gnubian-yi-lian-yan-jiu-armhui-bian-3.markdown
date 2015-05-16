---
layout: post
title: "用Qemu和GNU编译链研究ARM汇编(3)"
date: 2013-07-10 20:50
comments: true
categories: Linux Virtualization Embedded
---

在多个文件构成的程序中，源文件首先被编译成多个对象(object)文件(.o文件),
然后交由链接器生成最终的可执行文件，如下图所示：

{% img img /images/linker.png %}


在组建可执行文件时，链接器主要完成下列操作:

* 解析符号
* 重定位

1\. 符号解析

在编译单个文件组成的程序时，所有标号的解析都可以由汇编器替代为对应的地址。而在多文件组成的程序中，如果有储存在其他文件中的符号引用，汇编器会将其标识为"unresolved"(未解析).当对象文件被传递给链接器时，链接器从这些文件中决定对应的值，并把code中的unresolved的值替代为正确的值。

我们用上一节的求和函数来演示链接器是如何进行符号解析的。
这两个文件汇编后，会在链接时被检查未被解析的引用。
{% codeblock main.s - main.s %}
main.s
        .text
        b start                 @ Skip over the data
arr:    .byte 10, 20, 25        @ Read-only array of bytes
eoa:                            @ Address of end of array + 1

        .align
start:
        ldr   r0, =arr          @ r0 = &arr
        ldr   r1, =eoa          @ r1 = &eoa

        bl    sum               @ Invoke the sum subroutine

stop:   b stop
{% endcodeblock %}
{% codeblock sum-sub.s - sum-sub.s %}
sum-sub.s
        @ Args
        @ r0: Start address of array
        @ r1: End address of array
        @
        @ Result
        @ r3: Sum of Array

        .global sum

sum:    mov   r3, #0            @ r3 = 0
loop:   ldrb  r2, [r0], #1      @ r2 = *r0++    ; Get array element
        add   r3, r2, r3        @ r3 += r2      ; Calculate sum
        cmp   r0, r1            @ if (r0 != r1) ; Check if hit end-of-array
        bne   loop              @    goto loop  ; Loop
        mov   pc, lr            @ pc = lr       ; Return when done
{% endcodeblock %}

查看.o文件符号信息：

```
	$ arm-none-eabi-nm main.o
	00000004 t arr
	00000007 t eoa
	00000008 t start
	00000014 t stop
	         U sum
	$ arm-none-eabi-nm sum-sub.o 
	00000004 t loop
	00000000 T sum
```

t代表符号已经被定义了， 而u则代表符号未被定义。大写字母表示该符号是全局变量。

从上面的输出结果看，sum是被定义在sum-sub.o的全局变量，而该变量在main.o中未被解析到。当linker被调用时，符号引用将被解析到，对应的可执行文件将被生成。

总结： as程序负责把.s文件编译成object文件，而生成最终的可执行文件时，ld负责把未被定位的符号定位到实际的库函数所在的位置。

2\. 重定位.

重定位用于改变已经分配给标号的地址。它包括将所有符号引用映射到新分配的内存地址。


合并段后的符号列表情况，可以对比于上面的main.o和sum-sub.o来看：

```
	$ arm-none-eabi-ld -Ttext=0x0 -o sum.elf main.o sum-sub.o
	arm-none-eabi-ld: warning: cannot find entry symbol _start; defaulting to 00000000
	$ arm-none-eabi-nm sum.elf
	00000004 t arr
	00008038 T __bss_end__
	00008038 T _bss_end__
	00008038 T __bss_start
	00008038 T __bss_start__
	00008038 T __data_start
	00008038 T _edata
	00008038 T _end
	00008038 T __end__
	00000007 t eoa
	00000024 t loop
	00080000 T _stack
	00000008 t start
	         U _start
	00000014 t stop
	00000020 T sum
```

可以看到stop后面的sum已经被定位好了(之前是main.o中的U标记)，而loop则相应延后，被定位到了再往后的00000024。

地址的变更： loop原本地址为00000004, 现在是00000024, 而sum原本为0x00000000，现在为00000020, 这是因为sum-sub.o中的.text和main.o中的.text部分一起组成了sum.elf中的.text部分。

整体移动某个段到指定内存位置, 注意在-Ttext中我们增加的0x100的偏移量，使得地址对比于上面的结果整体上移了0x100:

```
	$ arm-none-eabi-ld -Ttext=0x100 -o sum100.elf main.o sum-sub.o
	arm-none-eabi-ld: warning: cannot find entry symbol _start; defaulting to 00000100
	$ arm-none-eabi-nm sum100.elf 
	00000104 t arr
	00008138 T __bss_end__
	00008138 T _bss_end__
	00008138 T __bss_start
	00008138 T __bss_start__
	00008138 T __data_start
	00008138 T _edata
	00008138 T _end
	00008138 T __end__
	00000107 t eoa
	00000124 t loop
	00080000 T _stack
	00000108 t start
	         U _start
	00000114 t stop
	00000120 T sum
```

3\. 重定位.data到RAM中。

我们可以通过撰写链接脚本，将程序的.data段放置在RAM中。这也是通常嵌入式系统所谓bootloader干的活儿，从Flash中加载启动代码到RAM中而后执行。

例程从RAM中加载两个数值，将两者相加而后将结果写回RAM，两个值和结果都放置在.data部分。 

代码：
{% codeblock sum_ram.s - sum_ram.s %}
        .data
val1:   .4byte 10               @ First number
val2:   .4byte 30               @ Second number
result: .4byte 0                @ 4 byte space for result

        .text
        .align
start:
        ldr   r0, =val1         @ r0 = &val1
        ldr   r1, =val2         @ r1 = &val2

        ldr   r2, [r0]          @ r2 = *r0
        ldr   r3, [r1]          @ r3 = *r1

        add   r4, r2, r3        @ r4 = r2 + r3

        ldr   r0, =result       @ r0 = &result
        str   r4, [r0]          @ *r0 = r4

stop:   b stop
{% endcodeblock %}
链接脚本：
{% codeblock %}
SECTIONS {
        . = 0x00000000;
        .text : { * (.text); }

        . = 0xA0000000;
        .data : { * (.data); }
}
{% endcodeblock %}
从connex的内存布局来看，内存地址为0xa000_0000到0xa400_0000，因而A0000000刚好在内存中。

查看链接后的内存符号地址:

```
	$ arm-none-eabi-as -o sum.o sum.s
	$ arm-none-eabi-ld -T sum_link.ld -o sum.elf sum.o 
	$ arm-none-eabi-nm -n sum.elf 
	00000000 t start
	0000001c t stop
	a0000000 d val1
	a0000004 d val2
	a0000008 d result
```

这样就完了？NO！！！！！！！！因为：RAM is Volatile! 内存是易变的！

RAM是易失性介质，怎可保证每次加电时就有代码洗干净PP在等着被运行？嵌入式系统里必然有非易失性存储，所有的代码和数据在加电前都需要放在这些非易失性存储介质中，例如在FLASH中。这样在加电后我们就可以利用一段启动代码把代码从FLASH搬到RAM中。

从这个设计思路出发，我们需要程序的.data有两个地址，一个是加载地址，另一个是运行地址。
这就是常说的：LMA(Load Memory Address)  VS    VMA(Virtual Memory Address)。

上面的代码需要做两个修改:

1. 需要在.data中指定load地址和运行地址
2. 需要写一段代码用于将数据从FLASH读取到RAM中, 从存储地址到运行地址。

{% codeblock %}
SECTIONS {
        . = 0x00000000;
        .text : { * (.text); }
        etext = .;

        . = 0xA0000000;
        .data : AT (etext) { * (.data); }
}
{% endcodeblock %}

etext包含了FLASH中放置完地址后的空白地址，记住这个地址以便在接下来将这个数值传送给.data部分，以便程序将.data部分从FLASH拷贝到RAM中。etext只是符号表中的一个，本身并不占据任何内存(可以回去翻上一篇日志)。

关于AT关键字:  它指定了.data部分的加载地址，一个地址或符号被传递给AT关键字，以便它从该地址拷贝数据。 在这里，我们传递etext符号给AT。

要把代码从FLASH拷贝到RAM中，下列信息需要被提供：

1. Flash中数据地址(flash_sdata)
2. RAM中数据地址(ram_sdata)
3. .data部分大小(data_size)

拷贝代码：
{% codeblock modified_sum_ram.s - modified_sum_ram.s %}
        ldr   r0, =flash_sdata
        ldr   r1, =ram_sdata
        ldr   r2, =data_size

copy:
        ldrb  r4, [r0], #1
        strb  r4, [r1], #1
        subs  r2, r2, #1
        bne   copy
{% endcodeblock %}
由此，我们需要在链接脚本中生成这三个数值：
{% codeblock %}
SECTIONS {
        . = 0x00000000;
        .text : {
              * (.text);
        }
        flash_sdata = .;

        . = 0xA0000000;
        ram_sdata = .;
        .data : AT (flash_sdata) {* (.data); }
        ram_edata = .;
        data_size = ram_edata - ram_sdata;
}
{% endcodeblock %}
ram_sdata为ram中数据开始地址，而ram_edata为结束地址，两者相减则为数据块大小。

改变后的带有copy数据的代码：
{% codeblock final_sum_ram.s - final_sum_ram.s %}
        .data
val1:   .4byte 10               @ First number
val2:   .4byte 30               @ Second number
result: .space 4                @ 1 byte space for result

        .text

        ;; Copy data to RAM.
start:
        ldr   r0, =flash_sdata
        ldr   r1, =ram_sdata
        ldr   r2, =data_size

copy:
        ldrb  r4, [r0], #1
        strb  r4, [r1], #1
        subs  r2, r2, #1
        bne   copy

        ;; Add and store result.
        ldr   r0, =val1         @ r0 = &val1
        ldr   r1, =val2         @ r1 = &val2

        ldr   r2, [r0]          @ r2 = *r0
        ldr   r3, [r1]          @ r3 = *r1

        add   r4, r2, r3        @ r4 = r2 + r3

        ldr   r0, =result       @ r0 = &result
        str   r4, [r0]          @ *r0 = r4

stop:   b stop
{% endcodeblock %}

使用修改过的final_sum_ram.s和link脚本编译，并生成flash.bin后，就可以在qemu-system-arm中验证结果了。

{% codeblock %}
$ qemu-system-arm -M connex -pflash flash.bin -nographic -serial /dev/null
QEMU 1.4.2 monitor - type 'help' for more information
(qemu) info registers
R00=a0000008 R01=a0000004 R02=0000000a R03=0000001e
R04=00000028 R05=00000000 R06=00000000 R07=00000000
R08=00000000 R09=00000000 R10=00000000 R11=00000000
R12=00000000 R13=00000000 R14=00000000 R15=00000038
PSR=600001d3 -ZC- A svc32
FPSCR: 00000000

(qemu) xp /4dw 0xA0000000
00000000a0000000:         10         30         40          0
{% endcodeblock %}

R04包含了我们相加后的结果, 为0x28=40, R02/R03则分别为操作数10/30. 而通过显示0xA0000000也显示了内存中的值分别为val1/val2/result的值。

接下来的章节中，我们将讲到C代码入口。

