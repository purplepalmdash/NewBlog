---
layout: post
title: "arduino笔记(1)"
date: 2013-07-15 09:39
comments: true
categories: arduino Embedded
---
1\. 稳压IC的作用：

稳压器IC就是使输出电压稳定的设备中的电子元器件。所有的稳压器，都利用了相同的技术实现输出电压的稳定输出电压通过连接到误差放大器（Error Amplifier）反相输入端（Inverting Input）的分压电阻（Resistive Divider）采样（Sampled），误差放大器的同相输入端（Non-inverting Input）连接到一个参考电压Vref。 参考电压由IC内部的带隙参考源(Bandgap Reference)产生。误差放大器总是试图迫使其两端输入相等。为此，它提供负载电流以保证输出电压稳定。

2\. ICSP(In-circuit serial programming)

3\. FT232: USB->UART

 The FT232BM is the 2nd generation of FTDI's popular USB UART device and the FT232BL is a lead free version of it.  The FT232BQ provides the same functionality as the FT232BM and FT232BL in a QFN-32 lead free package.

4\. ATmega328P Parameters:
{% codeblock %}
Parameter 		Value
Flash (Kbytes):		32 Kbytes
Pin Count:		32
Max. Operating Frequency: 20 MHz
CPU:			8-bit AVR
# of Touch Channels:	16
Hardware QTouch Acquisition: No
Max I/O Pins:		23
Ext Interrupts:		24
USB Speed:		No
USB Interface:		No
SPI:			2
TWI (I2C):		1
UART:			1
Graphic LCD:		No
Video Decoder:		No
Camera Interface:	No
ADC channels:		8
ADC Resolution (bits):	10
ADC Speed (ksps):	15
Analog Comparators:	1
Resistive Touch Screen:	No
DAC Resolution (bits):	0
Temp. Sensor:		Yes
Crypto Engine:		No
SRAM (Kbytes):		2
EEPROM (Bytes):		1024
Self Program Memory:	YES
External Bus Interface:	0
DRAM Memory:		No
NAND Interface:		No
picoPower:		Yes
Temp. Range (deg C):	-40 to 85
I/O Supply Class:	1.8 to 5.5
Operating Voltage (Vcc):1.8 to 5.5
FPU:			No
MPU / MMU:		no / no
Timers:			3
Output Compare channels: 	6
Input Capture Channels:		1
PWM Channels:		6
32kHz RTC:		Yes
Calibrated RC Oscillator:	Yes
Watchdog:		Yes
{% endcodeblock %}

5\. ATmega328P主要特性如下：

{% codeblock %}
高性能、低功耗的 8 位AVR 微处理器
先进的RISC 结构
131 条指令 – 大多数指令执行时间为单个时钟周期
32 个8 位通用工作寄存器
全静态工作
工作于20 MHz 时性能高达20 MIPS
只需两个时钟周期的硬件乘法器
非易失性程序和数据存储器
32K字节的系统内可编程Flash
擦写寿命: 10,000 次
具有独立锁定位的可选Boot 代码区
通过片上Boot 程序实现系统内编程
真正的同时读写操作
1024字节的EEPROM
擦写寿命: 100,000 次
2K字节的片内SRAM
可以对锁定位进行编程以实现用户程序的加密
外设特点
两个具有独立预分频器和比较器功能的8位定时器/计数器
一个具有预分频器、比较功能和捕捉功能的16位定时器/计数器
具有独立振荡器的实时计数器RTC
六通道PWM
8路10 位ADC
可编程的串行USART
可工作于主机/ 从机模式的SPI 串行接口
基于字节的2-wire串行接口
具有独立片内振荡器的可编程看门狗定时器
片内模拟比较器
引脚电平变化可引发中断及唤醒MCU
特殊的微控制器特点
上电复位(POR) 以及可编程的掉电检测(BOD)
经过校准的片内RC 振荡器
片内、片外中断源
6种休眠模式：空闲模式、ADC 噪声抑制模式、省电模式、掉电模式、待机模式和延长待机模式
I/O 和封装
23个可编程的I/O 口
28引脚PDIP，32引脚TQFP，28引脚QFN/MLF，与32引脚QFN/MLF封装
工作电压
1.8 - 5.5V
工作温度范围:
-40℃至85℃
工作速度等级
0 - 20 MHz @ 1.8 - 5.5V
超低功耗
正常模式：
1 MHz, 1.8V, 25°C: 0.2 mA
掉电模式:
1.8V, 0.1 μA
省电模式:
1.8V, 0.75 μA
{% endcodeblock %}


6\. LED闪烁测试程序

{% codeblock %}
/*
 * Let the LED shinning per 1 seconds 
 */
 
 void setup()
 {
   // Arduino's port 13 has a LED
   pinMode(13, OUTPUT);
 }
 
 void loop()
 {
   digitalWrite(13, HIGH);  // LED is on
   delay(1000);             // Last for 1 second
   digitalWrite(13, LOW);   // LED is off
   delay(1000);             // Last for 1 second
 }
{% endcodeblock %}

在Arduino中程序运行时将首先调用 setup() 函数。用于初始化变量、设置针脚的输出\输入类型、配置串口、引入类库文件等等。每次 Arduino 上电或重启后，setup 函数只运行一次。

pinMode(): 将指定的引脚配置成输出或输入。详情请见digital pins。

在 setup() 函数中初始化和定义了变量，然后执行 loop() 函数。顾名思义,该函数在程序运行过程中不断的循环，根据一些反馈,相应改变执行情况。通过该函数动态控制 Arduino 主控板。

digitalWrite() 给一个数字引脚写入HIGH或者LOW。

如果一个引脚已经使用pinMode()配置为OUTPUT模式，其电压将被设置为相应的值，HIGH为5V（3.3V控制板上为3.3V），LOW为0V。

如果引脚配置为INPUT模式，使用digitalWrite()写入HIGH值，将使内部20K上拉电阻（详见数字引脚教程）。写入LOW将会禁用上拉。上拉电阻可以点亮一个LED让其微微亮，如果LED工作，但是亮度很低，可能是因为这个原因引起的。补救的办法是 使用pinMode()函数设置为输出引脚。

注意：数字13号引脚难以作为数字输入使用，因为大部分的控制板上使用了一颗LED与一个电阻连接到他。如果启动了内部的20K上拉电阻，他的电压将在1.7V左右，而不是正常的5V，因为板载LED串联的电阻把他使他降了下来，这意味着他返回的值总是LOW。如果必须使用数字13号引脚的输入模式，需要使用外部上拉下拉电阻。

delay(): 使程序暂定设定的时间（单位毫秒）。（一秒等于1000毫秒）

编译并烧入到开发板后，可以看到系统的LED灯开始闪烁。

7\. 更多的LED
{% codeblock %}
void setup()
{
  for (int i=2; i<=7; i++)    //通过循环的方式设置2-7号引脚为输出状态
  {
    pinMode(i,OUTPUT);
  }
}
void loop()
{
  for (int x=2; x<=7; x++)
//通过循环的方式依次让每个引脚的led在1秒内完成明灭
  {
    digitalWrite(x,HIGH);
    delay(500);
    digitalWrite(x,LOW);
    delay(500);
  }
}
{% endcodeblock %}

