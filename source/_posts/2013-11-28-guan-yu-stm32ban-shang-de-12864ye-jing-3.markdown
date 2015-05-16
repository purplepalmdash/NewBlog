---
layout: post
title: "关于STM32板上的12864液晶(3)"
date: 2013-11-28 16:01
comments: true
categories: Embedded stm32
---
###如何控制液晶屏幕
ASCII码的可打印字符的范围在0x20 ~ 0x7f之间， 0x20 是空格字符，0x7f是delete字符。 最开始我们需要在内存中建立一张关于可打印字符的表。用于表示在液晶屏幕上如何显示出该字符，即该字符的点阵排列。    
下图是可以打印的ASCII/Unicode 0-127的值： 

![ascii.jpg](/images/ascii.jpg)

点阵数组：

```
	const u8 Asii8[] = {
		0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
		0x06,0x5F,0x06,0x00,0x00,0x07,0x03,0x00,
		0x07,0x03,0x00,0x24,0x7E,0x24,0x7E,0x24,
		0x00,0x24,0x2B,0x6A,0x12,0x00,0x00,0x63,
		0x13,0x08,0x64,0x63,0x00,0x36,0x49,0x56,

```
来个例子：

```
	#: 0x00, 0x24, 0x7e, 0x24, 0x7e, 0x24
	00000000
	00100100
	01111110
	00100100
	01111110
	00100100

```
对应的1代表将该点的液晶点点上。      
要注意，实际的显示应该是倒过来的，即： 把你的脖子顺时针转90度看上面的二进制表达式。    

在LCD上设置需要写入的坐标， 

```c LCDs.c
	/**************************************************************
	**函数名 :LcdSetXP
	**功能:设置坐标**
	**注意事项:这里设置的坐标不是X,Y,而是X,PAGE.因为黑白屏一次写入的数据为8个点,而且为竖
	**			式写入,故纵坐标是以页为单位,64个点共8页
	***************************************************************/
	void LcdSetXP(u8 x,u8 page)
	{
		LcdCmd((page&0x07)+0xb0);	//设置页指针
	    LcdCmd((x>>4)|0x10);
	    LcdCmd(x&0x0f);
	}

```
128X64的屏幕一共有8192个点， 每一个字符用48个点来表示，即8X6。所以每一个字的X坐标长度应该是6, 而Y坐标应该是8. 一个page代表8个点。    
考虑下面代码: 

```c main.c
	LcdSetXP(0,1);
	LcdChar8('T');
	LcdChar8('E');
	LcdChar8('S');
	LcdChar8('T');
	LcdChar8(' ');
	LcdChar8('O');
	LcdChar8('K');
	LcdChar8('!');

	LcdSetXP(0,2);
	LcdChar8('T');
	LcdSetXP(6,2);
	LcdChar8('E');
	LcdSetXP(24,2);
	LcdChar8('S');
	LcdChar8('T');
	LcdChar8(' ');
	LcdChar8('O');
	LcdChar8('K');
	LcdChar8('!');

```
得到的结果应该是：    
TEST OK!     
TE  ST OK!     
对应上面的解释不难明白在屏幕上填写字符的原理。     

有关在屏幕上写字符的函数是：

```c LCDs.c
/**************************************************************
**函数名 :LcdChar8
**功能:写一个宽6高8的ASCII
**注意事项:这里忽略了坐标的设置,此函数作为子函数被其他函数调用,使用前需要设置坐标
			使用内部的点阵表
***************************************************************/
void LcdChar8(char chr)
{
	u8 i;
	u8* p_data;

	/* 0x20 is the space character
	 * 0x7f is the delete character
	 * Seems all of the printable character are listed in the global array
	 */
	if((chr<0x20)||(chr>0x7f))
	{
		return;
	}

	/* Asii8 is the global variable(Glbal Array), So now we retrieve the
	 * character's address via first address plus the (asii code number)*6
	 * Because, each entry size if 6, all of the entry start from 0x20
	 */
	p_data = (u8*)Asii8 + (chr-0x20)*6;	//要写字符的首地址

	for(i=0;i<6;i++)
	{
		LcdDat(*p_data++);
	}
}

```
举例说明， !的字符表示为
00000000    
00000000     
00000110     
01011111      
00000110      
00000000     
则看起来应该像：
000100     
001110     
000100     
000000     
000100     
000000     
把1想象为点，就能对应想象出!在屏幕上的样子。     


原有的代码中关于GPIO初始化的时候，多初始化了一个PB14口，删除后一切正常。 
