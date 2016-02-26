---
layout: post
title: "Tips On V-USB And Arduino(1)- USB Keyboard"
date: 2016-02-26 16:55:10 +0800
comments: true
categories: Embedded
---
### 参考
主要参考了:    

[Arduino学习笔记A11 - Arduino模拟电脑键盘（基于AVR-USB的USB-HID设备）](http://www.geek-workshop.com/thread-1137-1-1.html)     

### 电路图
安装Fritzing后，可以绘制出面包板连线图和电路图:    

![/images/2016_02_26_16_57_48_761x613.jpg](/images/2016_02_26_16_57_48_761x613.jpg)    

电路图:    

![/images/2016_02_26_17_00_04_668x679.jpg](/images/2016_02_26_17_00_04_668x679.jpg)   

注意事项:    

电阻换成100欧也可以，原帖中是68欧电阻。    
注意齐纳二极管的极性，带有色条的一端是负极。    
### 代码 
值得注意的配置如下:    

```
#define USB_CFG_IOPORTNAME D
	
USB输入输出引脚使用AVR单片机的PORTD，如果改成B就是使用PORTB
#define USB_CFG_DMINUS_BIT 4
	
USB的D-接PORTD的第四位PD4，对应Arduino D4
#define USB_CFG_DPLUS_BIT  2
	
USB的D+接PORTD的第二位PD2，对应Arduino D2
#define USB_CFG_PULLUP_IOPORTNAME D
	
USB上拉引脚使用AVR单片机的PORTD，如果改成B就是使用PORTB
#define USB_CFG_PULLUP_BIT  5
	
USB的上拉电阻接PORTD的第五位PD5，对应Arduino  D5
```

在Arduino1.0.5上编译/配置都没有问题，最好在0022～1.05的版本范围内进行实验。    

首先通过USBasp线写入编译后的程序，而后换上我们添加的USB线缆后，点击按键，每次即可输出
`hello world`字符串。     
