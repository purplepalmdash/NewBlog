---
layout: post
title: "Tips On V-USB And Arduino(2)--用v-usb控制LED"
date: 2016-02-26 17:07:20 +0800
comments: true
categories: embedded
---
### 参考
参考链接如下(需翻墙):    

[V-USB examples for Arduino](http://coopermaa2nd.blogspot.tw/2011/10/v-usb-examples-for-arduino.html)    

### 连线图
链接里的连线图如下:    

![/images/image_thumb1354.png](/images/image_thumb1354.png)    

这个图我想了很久，对比上一节里键盘的连线图对比，发现D+/D-的连线刚好是反过来的。此外就是
D-上加了一个上拉电阻， 电阻值为1.5K， 这个其实没关系，在我们的例子中，用到2.2K，是因为
我们用的参考电压是5V的。     

对上一章我们的连线图进行修改，得出的连线图如下:    

![/images/2016_02_26_17_51_59_789x620.jpg](/images/2016_02_26_17_51_59_789x620.jpg)    

电路图如下:    

![/images/2016_02_26_17_52_42_699x689.jpg](/images/2016_02_26_17_52_42_699x689.jpg)   

上一章用到的开关可以不用拆除。   

值得注意的是，2.2K的上拉电阻接到了5V输入。   

### 代码
下载Windows版0022 Arduino，编译原帖中pde文件并上传，修改
hardware/arduino/cores/arduino/wiring.c里的:     

```
SIGNAL(TIMER0_OVF_vect) 
{
++++++   sei()
......
}
```

客户端程序编译:    

```
➜  pwd
......../custom_class/examples/custom_class_demo/commandline
➜  make clean
rm -f *.o set-led
➜  make

```

使用`./set-led`即可，编译前需要修改头文件:    


```
$ vim set-led.c
//#include "../firmware/requests.h"   /* custom request numbers */
//#include "../firmware/usbconfig.h"  /* device's VID/PID and names */
#include "../../../requests.h"   /* custom request numbers */
#include "../../../usbconfig.h"  /* device's VID/PID and names */

```
