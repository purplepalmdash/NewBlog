---
layout: post
title: "HC-SR501人体感应模块 &amp; Arduino"
date: 2013-12-27 19:52
comments: true
categories: Arduino
---
###连线图
led -- pin 6, SR501 pin 7.     
 ![/images/wiring1.jpg](/images/wiring1.jpg)
###代码

```c HC-SR501.ino
//红外感应
//信号接 7 端口
//LED will be 6 port
int sigpin = 7;
int ledpin = 6;
 
void setup()
{
  pinMode(sigpin, INPUT);
  pinMode(ledpin, OUTPUT);
  digitalWrite(ledpin, HIGH);
  
  Serial.begin(9600);  // 打开串口，设置波特率为9600 bps
}
 
int storefun = 0;
int ledstatus = HIGH;

void loop()
{
  int in = digitalRead(sigpin); 
  
  
  //Change the led ON/OFF accoriding to the status sensor
  if(in != storefun)
  {
    Serial.println("They are not equal!");
    if(ledstatus == LOW)
    {
      digitalWrite(ledpin,HIGH);
      ledstatus = HIGH;
    }
    else if(ledstatus == HIGH)
    {
      digitalWrite(ledpin, LOW);
      ledstatus = LOW;
    }
  }
  storefun = in; 
  Serial.println(in); //有人的时候输出高电平1 无人0
  Serial.println(storefun);
  Serial.println("***");
  delay(2000);    
}

```

