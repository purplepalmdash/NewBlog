---
layout: post
title: "STM使用库函数读写Flash"
date: 2013-11-30 15:55
comments: true
categories: embedded stm32
---
代码非常之简单：    

```c main.c
#define	FLASH_ADR	0x08008000		//要写入数据的地址
#define	FLASH_DATA	0x5a5a5a5a		//要写入的数据


int main(void)
{
	u32 tmp;
	ChipHalInit();			//片内硬件初始化
	ChipOutHalInit();		//片外硬件初始化

	//判断此FLASH是否为空白
	tmp=*(vu32*)(FLASH_ADR);
	if(tmp==0xffffffff)
	{
		FLASH_Unlock();
		FLASH_ProgramWord(FLASH_ADR,FLASH_DATA);
		FLASH_Lock();
		USART1_Puts("The destination is empty, Data has been written in!\r\n");
	}
	else if(tmp==FLASH_DATA)
	{
		USART1_Puts("The destination data is the same as certification data!\r\n");
	}
	else
	{
		USART1_Puts("The destination data is not equal to certification data, may caused via written error, or the destination is not empty!\r\n");
		FLASH_Unlock();
		FLASH_ErasePage(FLASH_ADR);
		FLASH_Lock();
		USART1_Puts("Erased the written destination!\r\n");
	}

```
运行结果为：

```
	The destination is empty, Data has been written in!
	The destination data is the same as certification data!
	The destination data is the same as certification data!
	The destination data is the same as certification data!
	The destination data is the same as certification data!
```

原理在于，直接读取到目的地址的值，与预设的值相比较。 要注意如何写入。先unlock，写入字后，lock住。
