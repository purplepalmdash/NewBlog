---
layout: post
title: "GPIO Advanced in STM32"
date: 2013-12-01 11:53
comments: true
categories: embedded stm32
---
直接操作寄存器的好处，最主要的就是看中它的快。缺点在于比较晦涩，因为你需要了解到实现的底层。在官方库中，我们可以找到如下的定义： 

```c unknown.c
//./Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x/stm32f10x.h:
#define PERIPH_BASE           ((uint32_t)0x40000000) /*!< Peripheral base address in the alias region */
//./Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x/stm32f10x.h:
#define APB2PERIPH_BASE       (PERIPH_BASE + 0x10000)
//./Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x/stm32f10x.h:
#define GPIOA_BASE            (APB2PERIPH_BASE + 0x0800)
//./Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x/stm32f10x.h:
#define GPIOA               ((GPIO_TypeDef *) GPIOA_BASE)
// Definition of the GPIO Types
/** 
  * @brief General Purpose I/O
  */

typedef struct
{
  __IO uint32_t CRL;
  __IO uint32_t CRH;
  __IO uint32_t IDR;
  __IO uint32_t ODR;
  __IO uint32_t BSRR;
  __IO uint32_t BRR;
  __IO uint32_t LCKR;
} GPIO_TypeDef;

/**
 * IO definitions
 *
 * define access restrictions to peripheral registers
 */

#ifdef __cplusplus
  #define     __I     volatile                /*!< defines 'read only' permissions      */
#else
  #define     __I     volatile const          /*!< defines 'read only' permissions      */
#endif
#define     __O     volatile                  /*!< defines 'write only' permissions     */
#define     __IO    volatile                  /*!< defines 'read / write' permissions   */
;

```
从上面就可以基本看出GPIO的相关知识。在GPIO的使用中我们需要注意7个寄存器：     
CRL, CRH, IDR, ODR, BSRR, BRR, LCKR.    
使用起来很简单，直接调用相应的寄存器操作就好：    
GPIOA->CRL=0x00;     
寄存器的定义在手册中有详细的介绍。简单的说，CRL和CRH被称之为Configuration Register， 配置寄存器，而IDR和ODR则是数据寄存器，一个是INPUT一个是OUTPUT。 置位/复位寄存器BSRR，还有一个16位的复位寄存器BRR， 还有一个32位的锁定寄存器LCKR，设置好对应的寄存器则可执行相应的操作。    

输入和输出操作可以直接操作寄存器，例如点亮和熄灭LED都是可以直接用操作寄存器来完成。而对键盘的操作，则是读入值。    

```
	#define GET_LEFT()	(!(GPIOD->IDR&GPIO_Pin_3)) 

```

能使用库函数的场合，除非对IO要求非常高，否则不建议直接操作寄存器。因为出错误的概率会远远增大。
