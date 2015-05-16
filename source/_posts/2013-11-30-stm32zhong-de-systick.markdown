---
layout: post
title: "STM32中的Systick"
date: 2013-11-30 11:24
comments: true
categories: embedded stm32
---
Cortx-M3特有的SysTick可以很方便的实现定时。系统始终的频率和开启系统时钟中断主要在RCC.c里进行设置：

```c RCC.c
	//SYSTICK分频--1ms的系统时钟中断
	if (SysTick_Config(SystemCoreClock / 1000))
  	{
  	  	/* Capture error */
    	while (1);
  	}
// The definition of the SysTick_Config:

/**
 * @brief  Initialize and start the SysTick counter and its interrupt.
 *
 * @param   ticks   number of ticks between two interrupts
 * @return  1 = failed, 0 = successful
 *
 * Initialise the system tick timer and its interrupt and start the
 * system tick timer / counter in free running mode to generate 
 * periodical interrupts.
 */

/*
  *      - SystemCoreClock variable: Contains the core clock (HCLK), it can be used
  *                                  by the user application to setup the SysTick 
  *                                  timer or configure other parameters.
*/

```
　　系统时钟SYSCLK，它是供STM32中绝大部分部件工作的时钟源。系统时钟可选择为PLL输出、HSI或者HSE。系统时钟最大频率为72MHz，它通过AHB分频器分频后送给各模块使用，AHB分频器可选择1、2、4、8、16、64、128、256、512分频。其中AHB分频器输出的时钟送给5大模块使用：    
　　①、送给AHB总线、内核、内存和DMA使用的HCLK时钟。    
　　②、通过8分频后送给Cortex的系统定时器时钟。    
　　③、直接送给Cortex的空闲运行时钟FCLK。    
　　④、送给APB1分频器。APB1分频器可选择1、2、4、8、16分频，其输出一路供APB1外设使用(PCLK1，最大频率36MHz)，另一路送给定时器(Timer)2、3、4倍频器使用。该倍频器可选择1或者2倍频，时钟输出供定时器2、3、4使用。    
　　⑤、送给APB2分频器。APB2分频器可选择1、2、4、8、16分频，其输出一路供APB2外设使用(PCLK2，最大频率72MHz)，另一路送给定时器(Timer)1倍频器使用。该倍频器可选择1或者2倍频，时钟输出供定时器1使用。另外，APB2分频器还有一路输出供分频器使用，分频后送给ADC模块使用。ADC分频器可选择为2、4、6、8分频。    
Cortex-M3允许为SysTick提供2个时钟源以供选择，第一个是内核的“自由运行时钟”FCLK，“自由”表现在它不是来自系统时钟HCLK，因此在系统时钟停止时，FCLK也能继续运行。第2个是一个外部的参考时钟，但是使用外部时钟时，因为它在内部是通过FCLK来采样的，因此其周期必须至少是FCLK的两倍（采样定理）。    


```c stm32f10x_it.c
/*******************************************************************************
* Function Name  : SysTickHandler
* Description    :系统时钟，一般调教到1MS中断一次
*******************************************************************************/

void SysTick_Handler(void)
{
	if(Timer1)
		Timer1--;
}

```
Timer1 为全局变量,我们将设置这个全局变量，以决定其定时期限。

```c RCC.c
/********************************************
**函数名:SysTickDelay
**功能:使用系统时钟的硬延迟
**注意事项:一般地,不要在中断中调用本函数,否则会存在重入问题.另外如果屏蔽了全局中断,则不要使用此函数
********************************************/
volatile u16 Timer1;
void SysTickDelay(u16 dly_ms)
{
	Timer1=dly_ms;
	while(Timer1);
}

```
而设置这个全局变量则是在main.c的loop函数中设置的。

```c main.c
	for(;;)
	{
		SysTickDelay(500);
		GPIOA->ODR^=GPIO_Pin_8;
	}

```
如果把500改成其它的值，则很方便可以实现不同大小的定时器。 
