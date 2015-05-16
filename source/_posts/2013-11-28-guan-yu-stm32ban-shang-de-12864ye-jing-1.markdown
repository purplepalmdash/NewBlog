---
layout: post
title: "关于STM32板上的12864液晶(2)"
date: 2013-11-28 10:13
comments: true
categories: Embedded stm32
---
###有关电路
上一章讲的是12864的基础知识。这一章里来看12864和stm32板的连接和驱动的问题。    

有关12864小LCD的连接，在PDF中我们可以找到如下的表项:     

|功能模块| 占用模块| 备注|
|--------|---------|-----|
|12864小LCD|PC4,PB2,PB11,PB13,PB15|PC4:A0,同时也是 CH375 和 TFT 的 A0;<br>PB2:BOOT1,LCD 的 CS 脚;<br>PB11:28J60 和大小 LCD 的复位脚|

再结合电路图：   
![stm32spi.jpg](/images/stm32spi.jpg)   

关于GPIO口的设置，我们可以看到有这样的定义： 

```c stm32f10x_gpio.h
	typedef enum
	{ GPIO_Mode_AIN = 0x0,
	  GPIO_Mode_IN_FLOATING = 0x04,
	  GPIO_Mode_IPD = 0x28,
	  GPIO_Mode_IPU = 0x48,
	  GPIO_Mode_Out_OD = 0x14,
	  GPIO_Mode_Out_PP = 0x10,
	  GPIO_Mode_AF_OD = 0x1C,
	  GPIO_Mode_AF_PP = 0x18
	}GPIOMode_TypeDef;

```
而在stm32的Datasheet中有如下的配置模式：    
![stmgpiomode.jpg](/images/stmgpiomode.jpg)    

最低的8个bit和表中是一一对应的，其中通用输出/复用功能输出的mode1/mode0的值为00.     
因为PB15是MOSI2口， PB13是SCK2口，所以这两个管脚需要被设置为AF模式的。AF代表复用功能。PP代表push-pull.      

```c LCDs.c
	/* PB15-MOSI2,PB13-SCK2*/
	/* Why PB14 should be enabled? */
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_13 |GPIO_Pin_14 | GPIO_Pin_15;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF_PP;
	GPIO_Init(GPIOB, &GPIO_InitStructure);

```
PB11和PB2属于output口，所以直接设置为out口即可。     
有关SPI2口的配置， 在STM中的代码如下：     

```c LCDs.c
	/* SPI2 configuration */
	    SPI_Cmd(SPI2, DISABLE); 												//必须先禁能,才能改变MODE
	SPI_InitStructure.SPI_Direction = SPI_Direction_2Lines_FullDuplex;		//两线全双工
	SPI_InitStructure.SPI_Mode = SPI_Mode_Master;							//主
	SPI_InitStructure.SPI_DataSize = SPI_DataSize_8b;						//8位
	SPI_InitStructure.SPI_CPOL = SPI_CPOL_High;								//CPOL=1 时钟悬空高
	SPI_InitStructure.SPI_CPHA = SPI_CPHA_2Edge;							//CPHA=1 数据捕获第2个
	SPI_InitStructure.SPI_NSS = SPI_NSS_Soft;								//软件NSS
	SPI_InitStructure.SPI_BaudRatePrescaler = SPI_BaudRatePrescaler_2;		//2分频
	SPI_InitStructure.SPI_FirstBit = SPI_FirstBit_MSB;						//高位在前
	SPI_InitStructure.SPI_CRCPolynomial = 7;								//CRC7
	
	    SPI_Init(SPI2, &SPI_InitStructure);
	SPI_Cmd(SPI2, ENABLE);

```
###有关SPI总线
SPI接口是Motorola 首先提出的全双工三线同步串行外围接口，采用主从模式（Master Slave）架构；支持多slave模式应用，一般仅支持单Master。时钟由Master控制，在时钟移位脉冲下，数据按位传输，高位在前，低位在后（MSB first）；SPI接口有2根单向数据线，为全双工通信，目前应用中的数据速率可达几Mbps的水平。     
stm32中关于SPI传送字节的函数编写

```c LCDs.c
	static u8 SPIByte(u8 byte)
	{
		/*等待发送寄存器空*/
		while((SPI2->SR & SPI_I2S_FLAG_TXE)==RESET);
	    /*发送一个字节*/
		SPI2->DR = byte;
		/* 等待接收寄存器有效*/
		while((SPI2->SR & SPI_I2S_FLAG_RXNE)==RESET);
		return(SPI2->DR);
	}

```
命令和数据是调用这个函数写入的，我们需要注意的是时序，在写入总线时需要先拉低/高A0线

```c LCDs.c
	//写命令
	void LcdCmd(u8 cmd)
	{
		CSLCDS_L;
		A0_L;
		//__nop();
		;
		SPIByte(cmd);
		//__nop();
		;
		CSLCDS_H;
	}
	
	//写数据
	void LcdDat(u8 dat)
	{
		CSLCDS_L;
		A0_H;
		//__nop();
		;
		SPIByte(dat);
		//__nop();
		;
		CSLCDS_H;
	}

```
