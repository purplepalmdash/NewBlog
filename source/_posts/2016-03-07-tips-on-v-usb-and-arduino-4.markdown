---
layout: post
title: "Tips on V-USB and Arduino(4)"
date: 2016-03-07 21:07:53 +0800
comments: true
categories: embedded
---
前面把玩了一下ebuddy, 回去想了一下, 觉得基于v-usb和arduino来实现
一个自己的ebuddy也不是特别难的事情.     

### 思路
还是参考:     

[V-USB examples for Arduino](http://coopermaa2nd.blogspot.tw/2011/10/v-usb-examples-for-arduino.html)

以`hid_custom_rq`项目来改. 例子里已经实现了Arduino板载的LED亮/灭. 我们只需要在
原例上修改, 添加自定义命令和硬件即可.     

### 代码
示例代码我做完后放到了github上, 可以通过以下命令获得:     

```
$ git clone git@github.com:purplepalmdash/arduino-usb-led.git
```

### 主要修改
#### request.h
这个头文件被USB固件和主机所共享, 定义了USB的request number数字, request number
被用于主机和设备之间的通信.    

添加:    

```
#define CUSTOM_RQ_BLINK    3
```

#### hid_custom_rq.h
这个文件是Arduino板上固件程序中对各种来自主机的request信息的响应, 或者说, 消息
处理函数.    


针对上面在`requst.h`文件中添加的消息, 我们需要在`usbFunctionSetup()`函数中添加
对应的消息处理代码, 为简单起见, 直接添加在函数的入口处就好.     

```c

usbMsgLen_t usbFunctionSetup(uchar data[8])
{
    usbRequest_t    *rq = (usbRequest_t *)((void *)data);    

+    if(rq->bRequest == CUSTOM_RQ_BLINK){ /* blink -- used for blink the LED */
+            /* First set the led pin to high  */
+             unsigned char i = 6;
+             while(i >= 1)
+             {
+             digitalWrite(hid_custom_rq.ledPin, HIGH);
+             delay(1000);
+             digitalWrite(hid_custom_rq.ledPin, LOW);
+             delay(1000);
+             i--;
+             }
+    }

    if((rq->bmRequestType & USBRQ_TYPE_MASK) == USBRQ_TYPE_VENDOR){
        if(rq->bRequest == CUSTOM_RQ_SET_STATUS){
```
上面添加的代码, 在监测到`CUSTOM_RQ_BLINK`消息后, 会将led闪烁6次.     

#### set-led.c
`set-led.c`文件用于编译出主机端程序, 编译出来的程序将接受用户输入, 将对应的输
入发送给USB设备.     

在`set-led.c`文件中我们添加一条命令,用于发送`CUSTOM_RQ_BLINK`消息:     

```c
$ vim examples/hid_custom_rq_demo/commandline/set-led.c
int main(int argc, char **argv)
{

//.......

+ else if(strcasecmp(argv[1], "blink") == 0){ /* set blink goes here */
+         cnt = usb_control_msg(handle, USB_TYPE_VENDOR | USB_RECIP_DEVICE | USB_ENDPOINT_OUT, CUSTOM_RQ_BLINK, 0, 0, buffer, 0, 5000);
+         if(cnt < 0){
+             fprintf(stderr, "USB error: %s\n", usb_strerror());
+         }
+ }

//.......

}
``` 

### 验证
将代码拷贝到Arduino IDE的`libraries`目录下:    

```
$ pwd
/media/y/arduino/1.0.5/libraries/hid_custom_rq
```
IDE菜单里的`File -> Examples -> hid_custom_rq`下将出现`hid_custom_rq_demo`, 点
击, 开始编译. 编译完以后, 上传到Arduino板.    

按
[http://purplepalmdash.github.io/blog/2016/02/26/tips-on-v-usb-and-arduino-2/](http://purplepalmdash.github.io/blog/2016/02/26/tips-on-v-usb-and-arduino-2/)
设置并检查Arduino连线.    


现在拔掉Arduino串口的USB线, 插上我们新加的USB连线, 而后运行以下验证例程:    

```
➜  hid_custom_rq git:(master) cd examples/hid_custom_rq_demo/commandline 
➜  commandline git:(master) ./set-led blink
USB error: Connection timed out
```
出现USB error是因为在板子上的服务例程中耗费了太多时间. 问题不大. 每次运行
`./set-led blink`命令将使得板子上13口的led闪烁6次.   


做到这里, 我们已经能模拟出ebuddy的心脏灯光效果了. 通过编写不同的request消息,发
送给Arduino板子即可.   

下面将研究添加一个新的LED灯, 等同于ebuddy的头灯.        
