---
layout: post
title: "烤派宝典第六章之Screen01"
date: 2013-11-11 19:34
comments: true
categories: Raspberry Pi Linux
---
#烤派宝典第六章之Screen01
欢迎来到Screen教程系列。在这一系列教程中，你将学会如何在汇编语言中控制Raspberry Pi的屏幕， 如何开始显示随机数据，然后我们将学会如何显示一个固定的图像，显示文字，如何将数字转换为文字。 我们假设你已经完成了之前的OK系列，OK系列里提到过的基本概念在本教程中不会再被提及。    
Screen01这一章讲述了一些基本的图像处理理论，我们将在这一章里，在屏幕上或是电视机（TV）上显示出一个渐变颜色的格式。   

|内容       |
|---------- |
|1 [开始](#GettingStarted) |
|2 [计算机图形](#ComputerGraphics) |
|3 [邮递员编程](#ProgrammingPostman) |
|4 [我最心爱的图像处理器](#DearGraphicProcessor) |
|5 [在一个框架内的连续像素](#pixelrow) |
|6 [曙光初现](#SeeLight) |

###1. 开始<a name="GettingStarted"></a>
我们希望你已经完成了OK系列，OK系列中已经完成的'gpio.s'和'systemTimer.s'文件中所撰写的函数会在本系列中被重复调用。如果你还没有这些文件，或者说你更愿意使用标准的参考文件，你可以从下载页面中下载到OK05的解决方案模板。 'main.s'文件同样是有用的，但是你需要把mov sp,#0x8000之后的内容删除。    
###2. 计算机图形<a name="ComputerGraphics"></a>
正如你所希望看到的，在很原始的层面上来看，计算机其实是很愚蠢的。它们的指令集是有限的，几乎不会解数学题目。但是不知为何它们拥有近乎无所谓不为的能力。我们目前所需要了解的，计算机如何在屏幕上显示出图像？我们如何将问题翻译成二进制而后扔给计算机去解决？答案非常简单，对于每一种颜色，我们为它编上一个唯一的编号，然后我们在计算机屏幕上的每一个点都储存上这个编号中的一个值。像素就是你屏幕上的这样一个小点，如果你凑近了看，你可能会在自己的屏幕上看到这样的点，你可以看到电脑上的每一幅图像，都是由这样的点的集合所组成的。    

随着计算机时代的演进，人们需要越来越复杂的图形，所以显卡被发明出来。显卡可以看作是你的计算机的第二个处理器，它仅仅负责在屏幕上画图。它的主要职责是将像素值信息转换为被送到屏幕上的光强度信息。 在现代计算机中，显卡能干的活儿远远不止这些，比如绘制3D图像也是它的拿手好戏。然而在本教程中，我们之关注于显卡的初级使用；从内存中获取到像素信息，输出到屏幕上。    

> 有很多种用数字来表达颜色的系统，这里我们使用RGB系统，但是HSL是另一种广泛被使用的系统。    

要注意到的一点是我们系统所使用的色彩编号系统。有很多种选择，每种选择将输出不同质量的图像。为了有助于你的完整理解，我在这里列举出了一些选择。    

> 尽管这里的图像有很多种颜色，它们都使用了一种被称作空间抖动的技术。这使得它们能用很少的颜色表现出绝佳的图像效果。许多早期的操作系统中都运用了这种技术。    

<table class="tableTopCells">
  <caption>
    表 2.1 一些颜色调色板
  </caption>

  <thead>
    <tr>
      <th>名称</th>

      <th>单色</th>

      <th>描述</th>

      <th>例子</th>
    </tr>
  </thead>

  <tbody>
    <tr>
      <td>单色画</td>

      <td>2</td>

      <td>使用一个位来存储每个像素点，1代表白色，0代表黑色
      </td>

      <td><img alt="鸟-单色" src=
      "/images/colour1bImage.png"></td>
    </tr>

    <tr>
      <td>灰阶</td>

      <td>256</td>

      <td>使用1byte来表示每个像素点，有255中表示白色的方式，0代表黑色，0～255之间的任意数字都代表两者的线性组合
      </td>
      <td><img alt="鸟-灰阶" src=
      "/images/colour8gImage.png"></td>
    </tr>

    <tr>
      <td>8位色</td>

      <td>8</td>

      <td>使用3个位来存储每个像素点，第1个位代表红色通道的值，第2个位代表绿色通道的值，第3个位代表蓝色通道的值。
      </td>

      <td><img alt="鸟-八位色" src=
      "/images/colour3bImage.png"></td>
    </tr>

    <tr>
      <td>低彩色</td>

      <td>256</td>

      <td>使用8个位来存储每个像素点的信息，前3个位代表红色通道的强度，接下来的3个位代表绿色通道的强度，最后2个位代表蓝色通道的强度。
      </td>

      <td><img alt="鸟- 256色（低彩色)" src=
      "/images/colour8bImage.png"></td>
    </tr>

    <tr>
      <td>高彩色</td>

      <td>65,536</td>

      <td>使用16个位来存储每个像素点的信息，前5个位用于表示红色通道的强度，接下来的6个位用于表示绿色通道的强度，最后的5个位用来表示蓝色通道的强度。
      </td>

      <td><img alt="鸟- 高彩色" src=
      "/images/colour16bImage.png"></td>
    </tr>

    <tr>
      <td>真彩色</td>

      <td>16,777,216</td>

      <td>使用24个位来存储每个像素点的信息，前8个位用于表示红色通道的强度，接下来的8个位用于表示绿色通道强度，最后的8个位用于表示蓝色通道的强度。
      </td>

      <td><img alt="鸟 - 真彩色" src=
      "/images/colour24bImage.png"></td>
    </tr>

    <tr>
      <td>RGBA32</td>

      <td>16,777,216(256个透明度级别)</td>

      <td colspan="2">使用32个位来存储每个像素点的信息，前8个位用于表示红色通道的强度，接下来的8个位用于表示绿色通道的强度，第3组8个位用于表示蓝色通道的强度，最后的8个位用于表示透明度通道。同名读通道通常用于在一幅图片上绘制另一幅图片，0用于代表后置图片的颜色，255代表当前图片的颜色，所有其之间的值代表两者的组合。
      </td>

      <td></td>
    </tr>
  </tbody>
</table>

在本指南中我们将使用高彩色。从上面的图片中我们可以看到，高彩彩色已经相当清晰，图片质量也不错，对比于真彩色，它不会占据太大的空间。也就是说，显示一张800x600像素大小的图片，它只会占据大概1M byte的空间。它还有个优势是，它是2的幂次方的大小，对比于真彩图片，很容易得到其信息。    

Raspberry Pi上的图形处理器有一点点怪异。在Raspberry Pi上，图形显示器最先运行，并负责启动主处理器（中央处理器)。对比于正常的操作系统，这有点“不太正常”。 虽然最终这种启动方式不会造成任何差别，但总给人感觉就是中央处理器被沦落为了第二处理器，图形处理器有喧宾夺主的感觉。Raspberry Pi的中央处理器和图形处理器之间的通信方式被称之为“邮箱(mailbox)”. 这两个处理器都可以给另一个处理器发送邮件，而对段处理器在收到邮件后将在可能的时间点处理之。我们可以使用邮箱机制从图形处理器取得一个地址。这个地址就是我们需要将色彩像素信息写在屏幕上的位置，被称为Frame Buffer， 显卡通常会检查这个位置，并从这里取得信息用于直接更新屏幕。     

> 存储Frame buffer会给计算机带来沉重的内存负载。基于这个原因，早期的计算机经常会使用一些欺诈的伎俩，比如，储存一个满是文字的屏幕，但是每次仅仅更新单个需要更新的字符。    
###3. 邮递员编程<a name="ProgrammingPostman"></a>
有关图形编程我们第一个要接触的就是‘邮箱’这个概念。邮箱只有两个方法需要注意，一个是MailboxRead, 用于从位于r0的邮箱通道里读出来一条消息。MailboxWrite，用于将r0中的前28个二进制位直接写入到位于r1的邮箱通道。Raspberry Pi有7个邮箱通道，可用于连接图像处理器，我们只能使用第一个通道，因为它直接和Frame Buffer交互。    

下面的表格和图标描述了有关邮箱的操作。    

<table>
  <caption>
    表 3.1 邮箱地址
  </caption>

  <thead>
    <tr>
      <th>地址</th>

      <th>大小/ Bytes</th>

      <th>名称</th>

      <th>描述</th>

      <th>读/ 写</th>
    </tr>
  </thead>

  <tbody>
    <tr>
      <td>2000B880</td>

      <td>4</td>

      <td>Read</td>

      <td>接收邮件.</td>

      <td>R</td>
    </tr>

    <tr>
      <td>2000B890</td>

      <td>4</td>

      <td>Poll</td>

      <td>接收邮件但不取回.</td>

      <td>R</td>
    </tr>

    <tr>
      <td>2000B894</td>

      <td>4</td>

      <td>Sender</td>

      <td>发送信息.</td>

      <td>R</td>
    </tr>

    <tr>
      <td>2000B898</td>

      <td>4</td>

      <td>Status</td>

      <td>信息.</td>

      <td>R</td>
    </tr>

    <tr>
      <td>2000B89C</td>

      <td>4</td>

      <td>Configuration</td>

      <td>配置.</td>

      <td>RW</td>
    </tr>

    <tr>
      <td>2000B8A0</td>

      <td>4</td>

      <td>Write</td>

      <td>发送邮件.</td>

      <td>W</td>
    </tr>
  </tbody>
</table>

>  消息传递是组件间通信的一种很常见的方式。一些操作系统使用虚拟的消息传递机制以允许应用程序之间的相互通信.

发送消息给特定的邮箱步骤如下：    

1. 发送端必须等待状态寄存器的最高位为0.   
2. 发送端写入Write寄存器， 第4个二进制位代表要写入的位置，高28个二进制位代表要写入的信息。

从邮箱读取一条信息的步骤如下：   

1. 接收端等待状态寄存器的第30个二进制位变为0. 
2. 接收端从Read寄存去读取。
3. 接收端确认消息是从正确的邮箱读出的，如果不是，则重试。 

如果你足够自信的话，你现在已经拥有足够的信息可以用于写出邮箱读/写函数了，如果你觉得还不够，那么请接着往下读。    

还是那句话，我推荐你一开始就把邮箱区域的取寄存器地址函数实现掉： 
	.globl GetMailboxBase
	GetMailboxBase:
	ldr r0,=0x2000B880
	mov pc,lr
发送流程最为简单，所以我们一开始就把它实现掉。随着你的函数越来越复杂，你需要开始计划如何组织它们。一个好的方式是实现将其实现步骤列举出来，越详细越好，比如下面的：    

1. 我们的输出需要写入的寄存器是(r0)， 邮箱需要写入的寄存器是(r1)。 我们需要检查邮箱地址是否有效，低4个二进制位的值是否是0,永远不要忘记校验输入值。    
2. 使用GetMailboxBase函数取得mailbox的地址。    
3. 读取状态寄存器的位。 
4. 检查最高位是否是0,如果不为0,则返回第3步。
5. 组合值，写入邮箱通道。 
6. 写入Write寄存器。 

让我们挨个来实现之：   
1\.     

```
	.globl MailboxWrite
	MailboxWrite: 
	tst r0,#0b1111
	movne pc,lr
	cmp r1,#15
	movhi pc,lr
```

以上代码实现了关于r0和r1寄存器的校验。 tst用于比较两个数字，通过对两个数字的逻辑与（and)运算， 并将结果与0作比较。 在这个例子这哦你哦个我们检查寄存器r0的低4位是否全为0。    
> tst reg,#val计算reg和#val作与运算的值，将其结果与0做比较。     


2\.    

```
	channel .req r1
	value .req r2
	mov value,r0
	push {lr}
	bl GetMailboxBase
	mailbox .req r0
```

上述代码确保调用函数时我们不会覆盖已有的寄存器的值和lr寄存器的值， 之后我们开始调用GetMailboxBase。     
3\.     

```
	wait1$:
	status .req r3
	ldr status,[mailbox,#0x18]
```

上述代码将加载入当前的状态。    
4\.     

```
	tst status,#0x80000000
	.unreq status
	bne wait1$
```

上述代码将检查状态寄存器的最高位是否为0,如果不是，则返回步骤3.     
5\.     

```
	add value,channel
	.unreq channel
```

上述代码将通道值和值做组合。      
6\.     

```
	str value,[mailbox,#0x20]
	.unreq value
	.unreq mailbox
	pop {pc}
```

上述代码将结果写入到write寄存器中。     

MailboxRead的代码也是类似的。    

1. 我们的输入值为需要读取的邮箱值(r0)。 我们需要实现校验之，以确定它是真实的邮箱地址。永远记得在函数调用前要校验输入值。    
2. 调用GetMailboxBase函数用于取回地址。   
3. 读取状态寄存器标志位。    
4. 检查第30个二进制位是否是0,如果不为0,则分支跳转回3. 
5. 从Read寄存器对应的地址开始读取数据。 
6. 检查mailbox是否是我们需要的那个，如果不是，则返回第3步继续执行。 
7. 返回结果。    

让我们按次序来实现之：    
1\.      

```
	.globl MailboxRead
	MailboxRead: 
	cmp r0,#15
	movhi pc,lr
```

上述代码用于校验r0，是否是通道0～16之间，事实上我们只能使用一个mailbox通道。   
2\.     

```
	channel .req r1
	mov channel,r0
	push {lr}
	bl GetMailboxBase
	mailbox .req r0
```

上述代码确保我们在调用GetMailboxBase函数时不会覆盖通用寄存器和lr寄存器值。     
3\.     

```
	rightmail$:
	wait2$:
	status .req r2
	ldr status,[mailbox,#0x18]
```

上述代码将载入当前的状态寄存器值，现在你可以在r2中看到当前的状态寄存器值。    
4\.     

```
	tst status,#0x40000000
	.unreq status
	bne wait2$
```

上述代码用于检查状态寄存器的第30个二进制位是否为0,如果不是，则返回到第3步继续等待。    
5\.      

```
	mail .req r2
	ldr mail,[mailbox,#0]
```

上述代码从邮箱中读入下一个条目。     
6\. 

```
	inchan .req r3
	and inchan,mail,#0b1111
	teq inchan,channel
	.unreq inchan
	bne rightmail$
	.unreq mailbox
	.unreq channel
```

上述代码检查我们刚才读取的通道就是我们所提供的通道，如果不是，我们将返回步骤3继续执行。因为低4位包含了地址，所以将其与输入值作对比就知道我们读取的是否是正确的，一般来说，这里可以看作是校验过程。     
7\.    

```
	and r0,mail,#0xfffffff0
	.unreq mail
	pop {pc}
```

上述代码将答案（mail的高28位)写入r0寄存器中。
###4. 我最心爱的图像处理器<a name="DearGraphicProcessor"></a>
有了上面写的两个函数充当邮递员，我们就拥有了往显卡发送消息的能力了。我们应该发送什么消息过去？这个答案很难回答，在所有线上文档中我没发现有确切的答案。 然而通过查阅Raspberry Pi的GNU/Linux文档，我们可以随心所欲的发送任何我们想要发送的东西。    

消息非常简单，我们描述好我们希望创建的framebuffer， 显卡要么同意我们的请求，要么拒绝。如果显卡同意我们开辟出如此大小的framebuffer，那它会返回0, 并填充我们所需要的内存区域；如果显卡拒绝我们的请求，将返回给我们一个非0值, 这代表可能分配了一小块或者根本就没分配。 不幸的是，我不知道这些非0值的真实含义是什么，我们只能以为如果显卡送回0时，它表示很高兴接收我们赋予它的任务。幸运的是，没有特殊情况的话，显卡总是乐呵呵的返回给我们0值，所以在返回值这个问题上，你不要有过多的担心。     

> 因为Pi上的内存被中央处理起和显示处理器所共享，我们只需要发送何处可以找到我们消息的地址就可以了， 这种技术叫做DMA，许多复杂的设备使用它以加速访问时间。

为简单起见，我们将提前实现我们的需求，将其存储在.data段中。 在文件'framebuffer.s'中我们输入下列代码：    

```
	section .data
	.align 4
	.globl FrameBufferInfo 
	FrameBufferInfo:
	.int 1024 /* #0 Physical Width */
	.int 768 /* #4 Physical Height */
	.int 1024 /* #8 Virtual Width */
	.int 768 /* #12 Virtual Height */
	.int 0 /* #16 GPU - Pitch */
	.int 16 /* #20 Bit Depth */
	.int 0 /* #24 X */
	.int 0 /* #28 Y */
	.int 0 /* #32 GPU - Pointer */
	.int 0 /* #36 GPU - Size */
```

上面就是我们需要传递给显示处理器的消息格式。前两个字描述了物理屏幕的宽度和高度。第二对字则是虚拟屏幕的的宽度和高度。framebuffer的宽度和高度属于虚拟宽度和高度，GPU会自动将其适配到物理的宽度和高度上。接下来的字用于表示GPU是否可以满足我们的请求，如果能则会被设置为framebuffer每一行的字节数，在这里是2x1024=2048。 接下来的字是每一个像素需要分配多少个二进制位用于表征色彩信息。使用16代表GPU支持高彩色，如果是24则代表真彩色，32则代表RGBA32。接下来的两个字分别代表x和y坐标，代表将framebuffer拷贝到屏幕上时需要忽略掉的像素值，x和y是相对于屏幕左上方而言。最后的两个字会被显示处理器所填充，第一个代表指向framebuffer的地址，第二个值代表framebuffer的实际大小，单位是byte。     

这里我很谨慎地使用了一个.align 4。 以前我们提起过，这条指令将保证下一条指令地址的低4个二进制为全0. 这样以来，我们就可以确保FrameBufferInfo放在可以直接传递给图形处理起的地址，因为我们的mailbox只能传送低4位全为0的地址。    
> 当和使用DMA的设备交互时，对齐限制变得非常重要。GPU希望消息以16个byte对齐。    

现在我们已经构建好了我们的消息结构，接下来我们写出发送这些消息的代码。消息通信将遵循一下流程：    
1. 将地址FrameBufferInfo + 0x40000000写入邮箱通道1。     
2. 读取邮箱通道1的结果，如果它为非0,这代表我们没有请求到合适的frame buffer。    
3. 拷贝图像到GPU的指针地址，它就会直接在屏幕上显示出来。   
 
在步骤1中，我们需要在FrameBufferInfo地址上加上偏移0x40000000后才发送之。这条指令是一条特殊信号，用于告诉GPU在何处写入结构。如果我们只传输地址，GPU将返回它的应答信息，而不会立即更新缓存。缓存是一段内存，被处理器用于记载其当前正在处理的值，以便稍后放入内存中的对应位置。如果加上0x40000000，我们将告诉GPU不用写入缓存，保证了我们可以直接看到更改。    

因为这里我们需要做很多事，最好是将其实现为一个函数，我们将写一个名为InitialiseFrameBuffer的函数，这个函数完成诊断和协调工作，并返回包含有frame buffer信息数据结构的指针。 为简单起见，我们应该把宽度，高度和frame buffer的颜色深度都作为这个函数的输入，这样在main.s中我们就很容易更改值，而不用关注到函数的实现细节。    

还是老路子，我们先把实现的步骤逐个写下来。如果你有足够的自信，你可以跳开这一步，直接进入到函数的编写阶段。    

1. 检验输入值。 
2. 将输入值写入到frame buffer中。
3. 将地址frame buffer + 0x40000000写入到mailbox地址。
4. 收到mailbox的应答信息。 
5. 如果应答信息非0,表示方法失败。我们将返回0代表失败。
6. 如果成功，我们将返回表征frame buffer信息的指针。   

现在我们将撰写一个巨大的实现函数，下面的代码是一个实现方案。    
1\. 

```
	.section .text
	.globl InitialiseFrameBuffer
	InitialiseFrameBuffer:
	width .req r0
	height .req r1
	bitDepth .req r2
	cmp width,#4096
	cmpls height,#4096
	cmpls bitDepth,#32
	result .req r0
	movhi result,#0
	movhi pc,lr
```

上述代码检查width和height是否在4096的范围内，颜色深度是否小于32。我们在这里又用到了条件执行的计谋。 请仔细检查你的代码是否能检查到输入值正确的取值。     
2\. 

```
	fbInfoAddr .req r4
	push {r4,lr}
	ldr fbInfoAddr,=FrameBufferInfo
	str width,[r4,#0]
	str height,[r4,#4]
	str width,[r4,#8]
	str height,[r4,#12]
	str bitDepth,[r4,#20]
	.unreq width
	.unreq height
	.unreq bitDepth
```

上面的代码用于直接加载预先定义过的frame buffer 结构。这里我还将r4和链接寄存器的值保存在了栈中，因为我们需要将framebuffer的值保存在r4中。   
3\. 

```
	mov r0,fbInfoAddr
	add r0,#0x40000000 
        mov r1,#1
	bl MailboxWrite
```

MailboxWrite函数的输入值分别是：r0中存储需要写入的值，r1中存储需要写入的通道值。    
4\. 

```
	mov r0,#1
	bl MailboxRead
```

MailboxRead的输入值是寄存器r0， 代表要读取的通道，输出值是我们读出的值。    
5\. 

```
	teq result,#0
	movne result,#0
	popne {r4,pc}
```

上述代码检查MailboxRead的返回值是否为0,如果不是0,代表我们读取失败，函数将返回0（本函数返回0代表失败, MailboxRead返回0却代表成功，这两者容易混淆，需要注意）。     
6\. 

```
	mov result,fbInfoAddr
	pop {r4,pc}
	.unreq result
	.unreq fbInfoAddr
```

上述代码是函数的结束，成功返回frame buffer 的地址。     
###5. 在一个框架内的连续像素<a name="pixelrow"></a>
现在我们来创建一个可以和显示处理器通信的函数。它将给出来一个指向frame buffer的指针(地址)，以便我们可以在该地址上绘图。现在我们可以开始画图了。    

在第一个例子中，我们将绘制一个持续颜色渐变的屏幕。它看起来不怎么美观，但是至少它代表了我们的程序是可以正常工作的。 实现的原理是我们将framebuffer中的每个像素点设置为一个持续渐变的值，并不停的更新它。    

将下列代码拷贝到'main.s'文件中的mov sp,#0x8000代码后。 

```
	mov r0,#1024
	mov r1,#768
	mov r2,#16
	bl InitialiseFrameBuffer
```

以上代码调用了InitialiseFrameBuffer函数，创建出一个宽1024,高768的frame buffer, 颜色深度为16。 你可以将这些值改成你所期待的数字， 只要你能让它运行起来就没问题。 如果图形处理器无法给出我们一个正确的frame buffer，这个函数将返回0, 我们最好检查这个函数的返回值，如果函数执行失败，我们将点亮OKLED等，以表示函数运行有误。    

```
	teq r0,#0
	bne noError$
	
	mov r0,#16
	mov r1,#1
	bl SetGpioFunction
	mov r0,#16
	mov r1,#0
	bl SetGpio
	
	error$:
	b error$
	
	noError$:
	fbInfoAddr .req r4
	mov fbInfoAddr,r0
```

现在我们已经拥有了frame buffer info的地址，我们需要从中得到frame buffer的指针地址，即frame buffer point， 以便我们可以直接绘制图形到屏幕上。 我们使用两个循环函数来完成绘制过程，一个循环绘制成行的像素点，另一个函数绘制成列的像素点。 在Raspberry Pi上，事实上，在几乎所有的应用程序中，图像的存储方式都是从左至右，从上而下的，我们的函数就是按照这样的方式来绘制图形的。      

```
	render$:
	fbAddr .req r3
	ldr fbAddr,[fbInfoAddr,#32]
	
	colour .req r0
	y .req r1
	mov y,#768
	drawRow$:
	x .req r2
	mov x,#1024
	drawPixel$:
	strh colour,[fbAddr]
	add fbAddr,#2
	sub x,#1
	teq x,#0
	bne drawPixel$
	
	sub y,#1
	add colour,#1
	teq y,#0
	bne drawRow$
	
	b render$
	
	.unreq fbAddr
	.unreq fbInfoAddr
```

这里有很多代码，loop里嵌套的loop里还有loop， 为了让你更便于浏览这些代码，我在这里使用了适当的缩进，用以标明不同的loop级别。 在高级编程语言里，使用缩进很常见，汇编代码中也支持缩进，因为编译器会自动去除tab缩进符。 我们看到代码中首先先我们往frame buffer地址中加载入frame buffer消息结构，然后循环设置一行的像素点，也就是说，给这一行里的每一个像素点分别赋值。在每个像素点，我们使用一条strh(存储高位字）指令用于存储当前的颜色信息，而后对我们当前所写入的地址执行加1操作。写完一行以后，我们对绘制的颜色执行加1操作。写完整个屏幕后，我们将跳转回开始点重新执行。     

> strh reg,[dest]将寄存器reg中的低半字存入dest给定的地址中。    


###6. 曙光初现<a name="SeeLight"></a>
现在你可以在Raspberry Pi上测试你的代码了。你将看到一个不断变化的渐变色屏幕。注意：在发送第一个消息给mailbox前，Raspberry Pi在四个角上显示一个静止的倾斜样式。如果你碰到问题，请参阅troubleshooting页面。    

如果你成功运行了本章例程，恭喜你！现在你学会控制屏幕了！你可以修改代码以便在屏幕上画出任何你想要的样式。你可以自己定义出一些好看的显示样式，你可以直接计算每个像素的值，因为y包含了y坐标，x包含了x坐标，你定义的点可以直接显示在屏幕上。 下一课中也就是[烤派宝典第7章之Screen02](http://tbd.com)中，我们将学习一种常见的绘制方法，画直线。
