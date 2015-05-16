---
layout: post
title: "STM32上的定时器"
date: 2013-11-29 19:27
comments: true
categories: embedded stm32
---
使用定时器的好处是，等待某个时隙的同时还可以干别的事，而定时器的时间一到，得到一个中断后对应执行中断函数中的服务例程而已。STM32的定时器非常之复杂而强大，配置和使用都要花很大精力。    
打开TIM2线的程序如下：

```c TIM.c
void TIM_Configuration(void)
{
	//......

	/* TIM2 clock enable */
  	RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM2, ENABLE);

	//......

```

有关定时器的设置如下：     

```c TIM.c
	/* 基础设置*/
	TIM_TimeBaseStructure.TIM_Period = 8000;			//计数值   
	TIM_TimeBaseStructure.TIM_Prescaler = 7200-1;    	//预分频,此值+1为分频的除数
	TIM_TimeBaseStructure.TIM_ClockDivision = 0x0;  	//
	TIM_TimeBaseStructure.TIM_CounterMode = TIM_CounterMode_Up; 	//向上计数

```
这里设置的是定时器溢出控制,分频值的计算就是上述代码中提到的预分频的设置。 TIM2属于低速总线，这条总线最高只能达到36M的速度，芯片内部还有一个X2的倍频器，用于将低速的32M倍频成72M， 库中已经默认有实现。所以我们这里使用的TIM2其速度依然是72M， 如果预设分频为7200的话，分频后的结果就是72M/7200=10K(72000000/7200). 我们可以把这个值变大或变小，以获得更慢或更快的分频速度。    
计数值设置的是8000，计数器向上计数到8000的时候会溢出。因而溢出的时间是8000/10K=0.8s 比较值的设置如下：     

```c TIM.c
	u16 CCR1_Val = 4000;
	u16 CCR2_Val = 2000;
	u16 CCR3_Val = 1000;
	u16 CCR4_Val = 500; 
	/* 比较通道1*/
	TIM_OCInitStructure.TIM_OCMode = TIM_OCMode_Inactive;      		//输出比较非主动模式
	TIM_OCInitStructure.TIM_Pulse = CCR1_Val;  
	TIM_OCInitStructure.TIM_OCPolarity = TIM_OCPolarity_High;		//极性为正
	  
	TIM_OC1Init(TIM2, &TIM_OCInitStructure);
	TIM_OC1PreloadConfig(TIM2, TIM_OCPreload_Disable);				//禁止OC1重装载,其实可以省掉这句,因为默认是4路都不重装的.

```
则得到的四个比较值的大小分别为: 4000/10000=0.4s, 2000/10000=0.2s, 1000/10000=0.1s, 500/10000=0.05    

不同的分频值设置，如果把Prescaler设置为14400-1,则得到的分频结果是72000000/14400=5K，对应的时间也随着调整。    
简单来说，我们需要得到分频结果，还有就是预设的几个值与其结果作运算得出的真正时间。     


Timer到达后会产生中断，通道的捕获中断发生时，对应会执行相应的动作。这些中断处理函数是在"stm32f10x_it.c"中实现的：

```c stm32f10x_it.c
/*******************************************************************************
* Function Name  : TIM2_IRQHandler TIM2中断
* Description    : This function handles TIM2 global interrupt request.
* Input          : None
* Output         : None
* Return         : None
*******************************************************************************/

void TIM2_IRQHandler(void)
{
	if (TIM_GetITStatus(TIM2, TIM_IT_CC1) != RESET)
	{
		/*必须清空标志位*/
		TIM_ClearITPendingBit(TIM2, TIM_IT_CC1);
	
		/*点亮LED5*/
		LED5_ON;
		//LED1直接操作寄存器方式的闪烁
		GPIOA->ODR^=GPIO_Pin_8;
	
	}
	else if (TIM_GetITStatus(TIM2, TIM_IT_CC2) != RESET)
	{
		TIM_ClearITPendingBit(TIM2, TIM_IT_CC2);
	
		/*点亮LED6*/
		LED6_ON;
	}
	else if (TIM_GetITStatus(TIM2, TIM_IT_CC3) != RESET)
	{
		TIM_ClearITPendingBit(TIM2, TIM_IT_CC3);
		
		/* 点亮LED7*/
		LED7_ON;
	}
	else if (TIM_GetITStatus(TIM2, TIM_IT_CC4) != RESET)
	{
	  	TIM_ClearITPendingBit(TIM2, TIM_IT_CC4);
	    
	  	/*点亮LED8*/
		LED8_ON;
	
	}
	else if (TIM_GetITStatus(TIM2, TIM_IT_Update) != RESET)
	{
		TIM_ClearITPendingBit(TIM2, TIM_IT_Update);
		/*熄灭所有LED*/
		LED5_OFF;
		LED6_OFF;
		LED7_OFF;
		LED8_OFF;
	}
}

```
需要注意的是， GPIOA->ODR^=GPIO_Pin_8, 直接操作了寄存器，用于将LED1反向输出。GPIO->ODR就是GPIOA的输出寄存器，而LED1用的就是GPIOA的8脚， 在这个中断函数中，如果TIM_IT_CC1的值达到了，将点亮LED5和控制LED1的闪烁。     
在IO速度要求很高的场合，建议采用IO直接操作寄存器的方法，比用库函数要快得多。   

