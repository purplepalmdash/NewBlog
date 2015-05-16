---
layout: post
title: "I2C between raspberryPI and Arduino"
date: 2013-12-29 19:32
comments: true
categories: i2c Arduino RaspberryPI
---
###连线
Arduino I2C 连线:    
![arduino.jpg](/images/arduino-i2c-pins.jpg)    
RaspberryPI I2C 连线:    
![rasp.jpg](/images/raspberry-pi-i2c-pins.jpg)    
连线图：    

```
	RPI               Arduino (Uno/Duemillanove)
	--------------------------------------------
	GPIO 0 (SDA) <--> Pin 4 (SDA)
	GPIO 1 (SCL) <--> Pin 5 (SCL)
	Ground       <--> Ground

```

![rasp-arduino.jpg](/images/RaspberryPI-I2c-Arduino.png)

###Arduino端代码

```c i2c.ino
#include <Wire.h>

#define SLAVE_ADDRESS 0x04
int number = 0;
int state = 0;

void setup() {
    pinMode(13, OUTPUT);
    Serial.begin(9600);         // start serial for output
    // initialize i2c as slave
    Wire.begin(SLAVE_ADDRESS);

    // define callbacks for i2c communication
    Wire.onReceive(receiveData);
    Wire.onRequest(sendData);

    Serial.println("Ready!");
}

void loop() {
    delay(100);
}

// callback for received data
void receiveData(int byteCount){

    while(Wire.available()) {
        number = Wire.read();
        Serial.print("data received: ");
        Serial.println(number);

        if (number == 1){

            if (state == 0){
                digitalWrite(13, HIGH); // set the LED on
                state = 1;
            }
            else{
                digitalWrite(13, LOW); // set the LED off
                state = 0;
            }
         }
     }
}

// callback for sending data
void sendData(){
    Wire.write(number);
}

```
###RaspberryPI端准备
在/etc/modules中增加一行:

```
	i2c-dev

```
注释掉黑名单：

```
	$ cat /etc/modprobe.d/raspi-blacklist.conf
	# blacklist spi and i2c by default (many users don't need them)
	# blacklist spi-bcm2708
	#blacklist i2c-bcm2708

```
安装i2c工具：

```
	apt-get install i2c-tools

```
安装python库： 

```
	apt-get install python-smbus

```
探测i2c设备

```
	i2cdetect -y 0

```
如果不是root用户，例如，如果是pi用户，则需要将当前用户增加到i2c组中:

```
	$ sudo adduser pi i2c

```
###RaspberryPI端代码

```py i2c.py
import smbus
import time
# for RPI version 1, use "bus = smbus.SMBus(0)"
bus = smbus.SMBus(0)

# This is the address we setup in the Arduino Program
address = 0x04

def writeNumber(value):
    bus.write_byte(address, value)
    # bus.write_byte_data(address, 0, value)
    return -1

def readNumber():
    number = bus.read_byte(address)
    # number = bus.read_byte_data(address, 1)
    return number

while True:
    var = input("Enter 1 - 9: ")
    if not var:
        continue

    writeNumber(var)
    print "RPI: Hi Arduino, I sent you ", var
    # sleep one second
    time.sleep(1)

    number = readNumber()
    print "Arduino: Hey RPI, I received a digit ", number
    print

```
运行代码时要注意，0～255的数字输入进去，会在arduino i2c slave端收到对应的数据，并原封不动的被返回。超过255的数值将溢出。    
