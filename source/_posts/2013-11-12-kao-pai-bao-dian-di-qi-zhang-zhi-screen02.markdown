---
layout: post
title: "烤派宝典第七章之Screen02"
date: 2013-11-12 16:51
comments: true
categories: Raspberry Pi Linux
---
#烤派宝典第七章之Screen02    
Screen02这一章基于Screen01，将教会你如何在屏幕上画直线，还将教会你一个如何生成随机数的技巧。我们设想你已经拥有了[烤派宝典第6章之Screen01](http://Tomcat.no-ip.biz/blog/2013/11/11/kao-pai-bao-dian-di-liu-zhang-zhi-screen01/)中介绍的背景知识和代码作为基础。

|内容       |
|---------- |
|1 [点](#Dots) |
|2 [线](#Lines) |
|3 [随机数](#Randomness) |
|4 [Pi-加索](#Picasso) |
###1. 点<a name="Dots"></a>
既然我们之前已经让屏幕工作起来了，自然我们现在就可以开始创建出形形色色的图形了。如果我们能在上面真正画出点什么来自然是最好的。绘制图形中一个最基础的任务往往是绘制两个点之间的直线，有了直线，我们就可以用直线的组合来创建出更复杂的图形了。      

> 在执行更复杂的渲染时候，很多系统创建的着色函数可以使用不同颜色来绘制形状。每个像素点可以通过调用着色函数来确定在其上使用怎样的颜色。      

我们将试着在汇编语言中实现这个函数，但是最开始时我们需要另外的一些辅助函数。我们需要一个叫SetPixel的函数用于改变特定像素点的颜色，它的输入值应该是r0和r1。在将来如果我们需要往任意内存中绘图(而不是仅仅往屏幕上绘图)时这个函数将很有用。因此最开始时我们需要一个系统用于控制我们绘制的目标。我觉得最佳的解决方案是我们在内存中开辟一块区域，在里头存储我们需要绘制的目标地址。这一系统运行完毕后，我们将得到一个存储好的地址，这个地址通常指向上一次我们使用过的frame buffer。 我们将在我们的绘图函数中始终使用这一地址。这样一来，如果我们在操作系统中的其他任何地方都可以调用这个函数来绘制出不同的图像，要做的只是改变这个地址使其指向一个新的结构而已，绘制代码则可以不用做任何修改。为了简单起见，我们使用一段数据用来控制我们要画的颜色。      

将下列代码拷贝入一个新的文件中，起名为'drawing.s'.

```
	.section .data
	.align 1
	foreColour:
	.hword 0xFFFF
	
	.align 2
	graphicsAddress:
	.int 0
	
	.section .text
	.globl SetForeColour
	SetForeColour:
	cmp r0,#0x10000
	movhs pc,lr
	ldr r1,=foreColour
	strh r0,[r1]
	mov pc,lr
	
	.globl SetGraphicsAddress
	SetGraphicsAddress:
	ldr r1,=graphicsAddress
	str r0,[r1]
	mov pc,lr
```

以上代码能实现上面我详细描述过的功能，我们在'main.s'将和它们的数据一起，在绘制任何图像前调用完，以便控制我们在哪里绘制、如何绘制的问题。      
> 创建一个类似于SetPixel般的通用方法，以便我们可以在别的函数中使用是一个很好的主意。我们需要确保这个通用方法运行得足够快，因为我们将频繁调用它。    

我们最后的任务是实现一个SetPixel方法。这个函数需要两个参数，像素点的x 和y坐标，它还需要使用我们刚才精确定义的graphicAddress和前景色取值已确定绘制的对象和位置。 如果你认为自己可以直接实现之，那就动手吧；如果觉得自己实现有难度，那么我将大体列举出如何实现的步骤，然后我将给出一个实现的例子。    

1. 载入graphicsAddress。 
2. 检查x和y坐标所在的位置是否小于宽度和高度。 
3. 计算像素点需要写入的地址（提示： frameBufferAddress + (x + y \* width)\* 像素大小 ）
4. 载入前景色。
5. 存储入相应的地址。  

下面是按照上述规则的代码实现。   
1\.  

```
	.globl DrawPixel
	DrawPixel:
	px .req r0
	py .req r1
	addr .req r2
	ldr addr,=graphicsAddress
	ldr addr,[addr]
```

2\. 

```
	height .req r3
	ldr height,[addr,#4]
	sub height,#1
	cmp py,height
	movhi pc,lr
	.unreq height
	
	width .req r3
	ldr width,[addr,#0]
	sub width,#1
	cmp px,width
	movhi pc,lr
```

回忆一下，宽度和高度存储在framebuffer开始起的0和4个byte的偏移位置。如果需要的话，你可以返回上一章参考'framebuffer.s'。     
3\. 

```
	ldr addr,[addr,#32]
	add width,#1
	mla px,py,width,px
	.unreq width
	.unreq py
	add addr, px,lsl #1
	.unreq px
```

坦白来说，上面的代码是为高彩色的frame buffer而专门设计的，因此我使用了一个二进制偏移方式来计算该地址。你可以把这个函数改得更为通用一点，无需指定高颜色的frame buffer，记得在修改的同时你也需要更新SetForeColour的代码。通用设计的实现难度可能更为复杂。     
4\. 

```
	fore .req r3
	ldr fore,=foreColour
	ldrh fore,[fore]
```

如上所述，专为高彩色定制的代码。    
5\. 

```
	strh fore,[addr]
	.unreq fore
	.unreq addr
	mov pc,lr
```

如上所述，专为高彩色定制的代码。    
###2. 线<a name="Lines"></a>
我们遇到的麻烦是，画一条直线并非你想象中那么简单。但是现在你必须啃完这块硬骨头，以便实现出我们的操作系统，那么我们就只能自己动手丰衣足食了，绘制直线也不例外。我建议你花上几分钟先自行思考一下如何在两个点之间画出一条直线来。     

我考虑出的方案着眼于计算出直线的斜率，然后步进之。这听起来合理极了，但是事实上这个念头很可怕。问题出在这样一来我们将引入大量的除法运算，我们知道在汇编语言中要处理好除法是很棘手的一件事情，还有我们需要跟踪十进制数字，就进一步增加了难度。事实上，有一种现成的算法，叫Bresenham's算法，它是实现画直线的绝佳算法，因为它只引入了加、减和比特移位操作。     
> 编程的正常思维是，我们想投机取巧，比如使用下除法就OK了。但是操作系统需要想象不到的高效率，所以我们要关注要解决的问题应该是让它变成卓越的，而不是解决了就可以。    

Bresenham's算法可以通过下列伪代码来描述，伪代码是看起来像计算机指令的文字，但是它实际上是便于程序员理解算法，而不是为了机器可读而设计的。     

```
	/* We wish to draw a line from (x0,y0) to (x1,y1), using only a function setPixel(x,y) which draws a dot in the pixel given by (x,y). */
	if x1 > x0 then
		set deltax to x1 - x0
		set stepx to +1
	otherwise
		set deltax to x0 - x1
		set stepx to -1
	end if
	
	set error to deltax - deltay
	until x0 = x1 + stepx or y0 = y1 + stepy
		setPixel(x0, y0)
		if error × 2 ≥ -deltay then 
			set x0 to x0 + stepx
			set error to error - deltay
		end if
		if error × 2 ≤ deltax then 
			set y0 to y0 + stepy
			set error to error + deltax
		end if
	repeat
```

这个算法的实现很常见。你可以试试看自己能否直接实现之。我在下面也给出了自己的实现代码：

```
	.globl DrawLine
	DrawLine:
	push {r4,r5,r6,r7,r8,r9,r10,r11,r12,lr}
	x0 .req r9
	x1 .req r10
	y0 .req r11
	y1 .req r12
	
	mov x0,r0
	mov x1,r2
	mov y0,r1
	mov y1,r3
	
	dx .req r4
	dyn .req r5 /* Note that we only ever use -deltay, so I store its negative for speed. (hence dyn) */
	sx .req r6
	sy .req r7
	err .req r8
	
	cmp x0,x1
	subgt dx,x0,x1
	movgt sx,#-1
	suble dx,x1,x0
	movle sx,#1
	
	cmp y0,y1
	subgt dyn,y1,y0
	movgt sy,#-1
	suble dyn,y0,y1
	movle sy,#1
	
	add err,dx,dyn
	add x1,sx
	add y1,sy
	
	pixelLoop$:
	teq x0,x1
	teqne y0,y1
	popeq {r4,r5,r6,r7,r8,r9,r10,r11,r12,pc}
	
	mov r0,x0
	mov r1,y0
	bl DrawPixel
	
	cmp dyn, err,lsl #1
	addle err,dyn
	addle x0,sx
	
	cmp dx, err,lsl #1
	addge err,dx
	addge y0,sy
	
	b pixelLoop$
	
	.unreq x0
	.unreq x1
	.unreq y0
	.unreq y1
	.unreq dx
	.unreq dyn
	.unreq sx
	.unreq sy
	.unreq err
```

###3. 随机数<a name="Randomness"></a>
现在我们可以来画直线了。虽然我们现在已经得偿所望，可以用它来绘制出任何我们想要的图像（随便你怎么画！）， 我觉得还是借这个机会引入一点点计算机随机数的概念。 我们要做的是，选择一堆随机的坐标，然后在它们之间用渐变的颜色绘制出直线。我之所以这么做是因为它看起来很漂亮。    

所以现在，我们来思考一下，如何得到随机数？不幸的是在Raspberry Pi上没有专门用于产生随机数的设备（这样的设备通常贵得惊人）。 所以我们只能用我们至今所学到的知识来发明出来一个‘随机数’。 我们不需要太长时间就可以实现出来。 操作通常都能拥有明确定义好的结果，执行同一个序列的指令，寄存器中得到的值也是一样的结果。我们要做到额是引入一个序列用于产生伪随机数。这意味着，数字对于外界观察者而言，看起来是完全随机的，然而事实上它们是完全定制的。站在实现的角度，我们需要一个公式，用于产生随机数，我们能想到的一个很垃圾的数学运算符，例如4x2! /4，但实际上，这样生成的随机数，其质量是很低的。在这种情况下，如果输入为0,完了，答案也是0,太愚蠢了。但是它给出了一个思路，经过良好定义的公式，确实可以产生出高品质的随机数。    
> 硬件随机数产生器很少被用在安全场合，因为可预测的随机数序列可能会影响到安全或是加密。     

我要使用的公式叫做quadratic congruence产生器。 它是个很好的选择，因为仅仅用5条指令就可以实现它，然后它能产生出0到2的32次方-1个数之间的任意随机数。   
> 有关随机数产生器的讨论经常会引出一个问题，到底什么是随机数？我们通常是指统计上的随机性： 一连串数字是没办法通过显而易见的样式或是属性用于产生它们。    

这个随机数产生器能用如此简洁的代码产生出如此大的随机数的原因已经超出了本课程的讨论范围，但是我鼓励有兴趣的各位去研究它。可以从下面的公式着手研究， xn是产生的第n个随机数。    

![fumula](/images/formula.jpg)

这个公式受到以下限制：   

1. a必须是偶数。
2. b=a+1mod 4。 
3. c是奇数。 

如果你从未见过mod操作符，这里简单说明一下，它指的是对某个数除以被除数后，剩下的数值。例如b=a+1mod4以为着将a+1的值除以4,得到的余数就是b。 如果a 是12,那么(12+1)/4，mod的结果应该是1,因为13除以4的余数是1.     

将下列代码拷贝进你的文件夹中，命名为'random.s'   

```
	.globl Random
	Random:
	xnm .req r0
	a .req r1
	
	mov a,#0xef00
	mul a,xnm
	mul a,xnm
	add a,xnm
	.unreq xnm
	add r0,a,#73
	
	.unreq a
	mov pc,lr

```

这是一个随机函数的实现，最后产生的数字被存储在r0中，这个数字将用于产生下一个随机数。在我们的例子中，我们给定的a=EF00，b=1, c=73， 这样的选择足够产生出上面我们需要的随机数。 你可以使用任何你想要的数字进行替代，只要它们符合我们预定义的规则就可以。    
###4. Pi-加索<a name="Picasso"></a>
好，现在我们已经拥有了所有需要的函数，让我们来画图吧。修改你的main文件，在得到framebuffer的地址后，完成以下内容:    

1. 调用SetGraphicsAddress， r0中传递的参数为frame buffer info的地址。 
2. 设置4个寄存器的初始值为0。 一个是最后产生的随机数，一个是颜色，一个是上一个x坐标值，一个是上一个y坐标值。    
3. 调用随机数产生器生成下一个x坐标值， 使用上一次产生的随机数字作为输入。 
4. 再次调用随机数产生器生成下一个y坐标值，使用上一次你生成的x 坐标值作为输入。 
5. 用y坐标值更新上一个随机数。 
6. 使用给定的颜色值调用SetForeColour， 然后对颜色加1. 如果这个值达到十六进制的FFFF，要记得将它归零。 
7. x和y坐标的值需要在0到FFFFFFFF之间。 我们可以转化他们为数字，为0到102310之间，使用一个逻辑右移22位即可。 
8. 检查y坐标是否在屏幕上，验证y坐标的值在0到76710之间，如果不是，返回第3步。 
9. 从上一个x和y的坐标绘制一条直线到当前的x和y坐标。 
10. 更新当前的x和y坐标。
11. 返回第3步。     

如以前所提到的，解决方案可以在下载页面找到。

如果你完成了编码，在你的Raspberry Pi上测试之。你可以看到非常快的一系列的随机线条在屏幕上被绘制出来，颜色有着渐变色， 它永远不会被停止。 如果你的Raspberry Pi不能显示出正常结果，请参考troubleshooting页面。     

如果你成功运行了，恭喜你！ 我们已经学会了如何绘制多姿多彩的图形，还学会了如何产生随机数。 我孤立你多玩玩直线绘制，因为它可以用来渲染任何你想要的东西。 你可能还希望探索更为复杂的图形。 这些复杂的图形都可以通过直线来产生，但是有没有更好的策略用来产生呢？留给你自己思考。如果你喜欢画直线的程序，你可以试着修改下SetPixel函数。 如果在设置每一个像素值时候，你添加上一个小的数值，它会发生什么呢？如果你想创建出别的图案，你应该如何修改呢？在下一章里，[烤派宝典第8章之Screen03](http://tbd.com)里，我们来看看一个非常非常有用的技巧--绘制文字。 
