---
layout: post
title: "SPI连接raspberryPI和Arduino"
date: 2013-12-29 15:06
comments: true
categories: Arduino RaspberryPI Linux
---
下面是使用SPI在RaspberryPI和Arduino Nano w之间进行双机通信的一个例子。借助它可以很好的理解SPI的工作原理。    
###背景知识
RaspberryPI GPIO布局图：     
![/images/GPIOs.png](/images/GPIOs.png)    
从图中我们可以看到，RaspberryPI上与SPI通信相关的主要是GPIO 10（MOSI), GPIO 9(MISO)和GPIO 11(SCLK).    
Arduino布局图：    
SPI: 10 (SS), 11 (MOSI), 12 (MISO), 13 (SCK). These pins support SPI communication using the SPI library. SS代表Slava Select.        
事实上我们要使用的仅仅是11/12/13三个口而已。    
###连线图
如下图进行连线，简单来说，R(10 MOSI)->A(12 MISO), R(9, MISO)->A(11, MOSI), R(11, SCLK) ->A(13, SCK)：       
![/images/spiconnector.jpg](/images/spiconnector.jpg)
###Arduino端程序

```c spin.ino
// Written by Nick Gammon
// February 2011
/**
 * Send arbitrary number of bits at whatever clock rate (tested at 500 KHZ and 500 HZ).
 * This script will capture the SPI bytes, when a '\n' is recieved it will then output
 * the captured byte stream via the serial.
 */
 
#include <SPI.h>
 
char buf [100];
volatile byte pos;
volatile boolean process_it;
 
void setup (void)
{
  Serial.begin (115200);   // debugging
 
  // have to send on master in, *slave out*
  pinMode(MISO, OUTPUT);
  
  // turn on SPI in slave mode
  SPCR |= _BV(SPE);
  //SPCR is  Arduino SPI Control Register
  // __BV's definition is like : #define _BV(bit) (1 << (bit))
  // SPE is the register of the SPI Enable
  
  // get ready for an interrupt 
  pos = 0;   // buffer empty
  process_it = false;
 
  // now turn on interrupts
  SPI.attachInterrupt();
 
}  // end of setup
 
 
// SPI interrupt routine
ISR (SPI_STC_vect)
{
byte c = SPDR;  // grab byte from SPI Data Register
  
  // add to buffer if room
  if (pos < sizeof buf)
    {
    buf [pos++] = c;
    
    // example: newline means time to process buffer
    if (c == '\n')
      process_it = true;
      
    }  // end of room available
}  // end of interrupt routine SPI_STC_vect
 
// main loop - wait for flag set in interrupt routine
void loop (void)
{
  if (process_it)
    {
    buf [pos] = 0;  
    Serial.println (buf);
    pos = 0;
    process_it = false;
    }  // end of flag set
    
}  // end of loop

```
Code Walking through:    
Arduino SPI Control Register (SPCR), set it to 

```
	SPCR |= _BV(SPE);

```
SPI Data Register (SPDR), SPI数据寄存器。 中断程序中，每次从SPDR中取回一个byte 并存储在c中。    

```
	if (c == '\n')
		process_it = true;

```
这里通过设置全局变量process_it来影响loop中对接收数据的处理，在loop()中有如下代码段：

```
	if (process_it)
	{
		//.....
	}

```
从上面看到，如果process_it为0,则loop中一直在空循环，只有当所有的数据全部接收完毕后，才会一次性打印出所有的数据。在打印完数据后，程序将自动将buf清0, 清0是通过将pos简单置0而实现的，实际的数据其实还在。
###RaspberryPI 端程序

```c spi_test.c
/*
 * SPI testing utility (using spidev driver)
 *
 * Copyright (c) 2007  MontaVista Software, Inc.
 * Copyright (c) 2007  Anton Vorontsov <avorontsov@ru.mvista.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License.
 *
 * Cross-compile with cross-gcc -I/path/to/cross-kernel/include
 */
 
#include <stdint.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/types.h>
#include <linux/spi/spidev.h>
 
#define ARRAY_SIZE(a) (sizeof(a) / sizeof((a)[0]))
 
static void pabort(const char *s)
{
	perror(s);
	abort();
}
 
static const char *device = "/dev/spidev0.0";
static uint8_t mode;
static uint8_t bits = 8;
static uint32_t speed = 500000;
static uint16_t delay;
 
static void transfer(int fd)
{
	int ret;
	uint8_t tx[] = {
        0x48, 0x45, 0x4C, 0x4C, 0x4F,
        0x20, 
        0x57, 0x4F, 0x52, 0x4C, 0x44,
        0x0A 
	};
	uint8_t rx[ARRAY_SIZE(tx)] = {0, };
	struct spi_ioc_transfer tr = {
		.tx_buf = (unsigned long)tx,
		.rx_buf = (unsigned long)rx,
		.len = ARRAY_SIZE(tx),
		.delay_usecs = delay,
		.speed_hz = speed,
		.bits_per_word = bits,
	};
 
	ret = ioctl(fd, SPI_IOC_MESSAGE(1), &tr);
	if (ret < 1)
		pabort("can't send spi message");
 
    /*
	for (ret = 0; ret < ARRAY_SIZE(tx); ret++) {
		if (!(ret % 6))
			puts("");
		printf("%.2X ", rx[ret]);
	}
	puts("");
    */
}
 
static void print_usage(const char *prog)
{
	printf("Usage: %s [-DsbdlHOLC3]\n", prog);
	puts("  -D --device   device to use (default /dev/spidev1.1)\n"
	     "  -s --speed    max speed (Hz)\n"
	     "  -d --delay    delay (usec)\n"
	     "  -b --bpw      bits per word \n"
	     "  -l --loop     loopback\n"
	     "  -H --cpha     clock phase\n"
	     "  -O --cpol     clock polarity\n"
	     "  -L --lsb      least significant bit first\n"
	     "  -C --cs-high  chip select active high\n"
	     "  -3 --3wire    SI/SO signals shared\n");
	exit(1);
}
 
static void parse_opts(int argc, char *argv[])
{
	while (1) {
		static const struct option lopts[] = {
			{ "device",  1, 0, 'D' },
			{ "speed",   1, 0, 's' },
			{ "delay",   1, 0, 'd' },
			{ "bpw",     1, 0, 'b' },
			{ "loop",    0, 0, 'l' },
			{ "cpha",    0, 0, 'H' },
			{ "cpol",    0, 0, 'O' },
			{ "lsb",     0, 0, 'L' },
			{ "cs-high", 0, 0, 'C' },
			{ "3wire",   0, 0, '3' },
			{ "no-cs",   0, 0, 'N' },
			{ "ready",   0, 0, 'R' },
			{ NULL, 0, 0, 0 },
		};
		int c;
 
		c = getopt_long(argc, argv, "D:s:d:b:lHOLC3NR", lopts, NULL);
 
		if (c == -1)
			break;
 
		switch (c) {
		case 'D':
			device = optarg;
			break;
		case 's':
			speed = atoi(optarg);
			break;
		case 'd':
			delay = atoi(optarg);
			break;
		case 'b':
			bits = atoi(optarg);
			break;
		case 'l':
			mode |= SPI_LOOP;
			break;
		case 'H':
			mode |= SPI_CPHA;
			break;
		case 'O':
			mode |= SPI_CPOL;
			break;
		case 'L':
			mode |= SPI_LSB_FIRST;
			break;
		case 'C':
			mode |= SPI_CS_HIGH;
			break;
		case '3':
			mode |= SPI_3WIRE;
			break;
		case 'N':
			mode |= SPI_NO_CS;
			break;
		case 'R':
			mode |= SPI_READY;
			break;
		default:
			print_usage(argv[0]);
			break;
		}
	}
}
 
int main(int argc, char *argv[])
{
	int ret = 0;
	int fd;
 
	parse_opts(argc, argv);
 
	fd = open(device, O_RDWR);
	if (fd < 0)
		pabort("can't open device");
 
	/*
	 * spi mode
	 */
	ret = ioctl(fd, SPI_IOC_WR_MODE, &mode);
	if (ret == -1)
		pabort("can't set spi mode");
 
	ret = ioctl(fd, SPI_IOC_RD_MODE, &mode);
	if (ret == -1)
		pabort("can't get spi mode");
 
	/*
	 * bits per word
	 */
	ret = ioctl(fd, SPI_IOC_WR_BITS_PER_WORD, &bits);
	if (ret == -1)
		pabort("can't set bits per word");
 
	ret = ioctl(fd, SPI_IOC_RD_BITS_PER_WORD, &bits);
	if (ret == -1)
		pabort("can't get bits per word");
 
	/*
	 * max speed hz
	 */
	ret = ioctl(fd, SPI_IOC_WR_MAX_SPEED_HZ, &speed);
	if (ret == -1)
		pabort("can't set max speed hz");
 
	ret = ioctl(fd, SPI_IOC_RD_MAX_SPEED_HZ, &speed);
	if (ret == -1)
		pabort("can't get max speed hz");
 
	printf("spi mode: %d\n", mode);
	printf("bits per word: %d\n", bits);
	printf("max speed: %d Hz (%d KHz)\n", speed, speed/1000);
 
	transfer(fd);
 
	close(fd);
 
	return ret;
}

```
解析： 在main()函数中，设置完spi总线的相关参数后，调用transfer(fd)来传递参数。    
transfer()函数的实现如下:    

```c spidev_test.c
static void transfer(int fd)
{
	int ret;
	uint8_t tx[] = {
        0x48, 0x45, 0x4C, 0x4C, 0x4F,
        0x20, 
        0x57, 0x4F, 0x52, 0x4C, 0x44,
        0x0A 
	};
	uint8_t rx[ARRAY_SIZE(tx)] = {0, };
	struct spi_ioc_transfer tr = {
		.tx_buf = (unsigned long)tx,
		.rx_buf = (unsigned long)rx,
		.len = ARRAY_SIZE(tx),
		.delay_usecs = delay,
		.speed_hz = speed,
		.bits_per_word = bits,
	};
 
	ret = ioctl(fd, SPI_IOC_MESSAGE(1), &tr);
	if (ret < 1)
		pabort("can't send spi message");
 
    /*
	for (ret = 0; ret < ARRAY_SIZE(tx); ret++) {
		if (!(ret % 6))
			puts("");
		printf("%.2X ", rx[ret]);
	}
	puts("");
    */
}

```
tx即为字符串，'H'=0x48, 'E'=0x45, 'L'=0x4c, 'L'=0x4c, 'O'=0x4f, ' '=0x20, 'W'=0x57, 'O'=0x4f, 'R'=0x52, 'L'=0x4c, 'D'=0x44, '\n'=0x0a.    
实际传送则是调用：
	ret = ioctl(fd, SPI_IOC_MESSAGE(1), &tr);
有关它的解释如下：

```c include/uapi/linux/spi/spidev.h
	SPI_IOC_MESSAGE gives userspace the equivalent of kernel spi_sync().
	  72 * Pass it an array of related transfers, they'll execute together.
	  73 * Each transfer may be half duplex (either direction) or full duplex.
	  74 *
	  75 *      struct spi_ioc_transfer mesg[4];
	  76 *      ...
	  77 *      status = ioctl(fd, SPI_IOC_MESSAGE(4), mesg);

	#define SPI_IOC_MESSAGE(N) _IOW(SPI_IOC_MAGIC, 0, char[SPI_MSGSIZE(N)])

```
调用完transfer()函数后，调用close()来关闭文件描述符。    
