---
layout: post
title: "Little tricky on SPI"
date: 2013-12-29 17:13
comments: true
categories: Arduino RaspberryPi Linux
---
接着上一个日志来，玩一个小tricky，通过SPI总线自己想输入的字符。   
主机端，添加下列头文件
	#include <string.h>
这使得可以使用strcpy等函数。    
重写transfer()函数

```c spidev_test.c
static void transfer_mine(int fd, char *buf)
{
	int ret;

	uint8_t tx[140];
	int len = strlen(buf)+1;
	memcpy(tx, buf, strlen(buf)+1);
	tx[strlen(tx)] = '\n';

	uint8_t rx[ARRAY_SIZE(tx)] = {0, };
	struct spi_ioc_transfer tr = {
		.tx_buf = (unsigned long)tx,
		.rx_buf = (unsigned long)rx,
		//.len = ARRAY_SIZE(tx),
		.len = len,
		.delay_usecs = delay,
		.speed_hz = speed,
		.bits_per_word = bits,
	};
 
	ret = ioctl(fd, SPI_IOC_MESSAGE(1), &tr);
	if (ret < 1)
		pabort("can't send spi message");
}

```
在main()函数里，改写调用的方式：

```c spidev_test.c
	char myinput[140]="Trustywill, Hi, this is Trusty";
	transfer_mine(fd, myinput);

```
这样就可以将自定义的字符传输过去了，140是随便设置的值，可以设置为别的更大或者更小的值。   
当然你也可以从命令行输入想传输的字符, 这里就不深入了。。   


