---
layout: post
title: "Using HMC5883L to control Servo"
date: 2013-11-18 13:35
comments: true
categories: Arduino 
---
###Wired
__Servo   __     
5V/GND      
Input--> D4     

__HMC5883L     __
3.3V/GND     
SCL--> A5     
SDA--> A4    

###Code:

``` c mywire.ino
#include <Wire.h>
#include <HMC5883L.h>

HMC5883L compass;

//Definition of servopin
int servopin = 4; 


void setup(){
  Serial.begin(9600);
  Wire.begin();
  
  compass = HMC5883L(); //new instance of HMC5883L library
  setupHMC5883L(); //setup the HMC5883L
  
  pinMode(servopin,OUTPUT);//设定舵机接口为输出接口
}

// Our main program loop.
void loop(){
  
  float heading = getHeading();
  //Serial.println(heading);
  
  int angle = (int)heading/2;
  /*
  int angle = (int)heading;
  if(angle > 180)
  {
    angle = angle - 180;
  }
  */
  Serial.println(angle);
    //发送50个脉冲
  for(int i=0;i<50;i++)
  {
    //引用脉冲函数
    servopulse(angle);
  }

  delay(100); //only here to slow down the serial print

}

void setupHMC5883L(){
  //Setup the HMC5883L, and check for errors
  int error;  
  error = compass.SetScale(1.3); //Set the scale of the compass.
  if(error != 0) Serial.println(compass.GetErrorText(error)); //check if there
is an error, and print if so

  error = compass.SetMeasurementMode(Measurement_Continuous); // Set the
measurement mode to Continuous
  if(error != 0) Serial.println(compass.GetErrorText(error)); //check if there
is an error, and print if so
}

float getHeading(){
  //Get the reading from the HMC5883L and calculate the heading
  MagnetometerScaled scaled = compass.ReadScaledAxis(); //scaled values from
compass.
  float heading = atan2(scaled.YAxis, scaled.XAxis);

  // Correct for when signs are reversed.
  if(heading < 0) heading += 2*PI;
  if(heading > 2*PI) heading -= 2*PI;

  return heading * RAD_TO_DEG; //radians to degrees
}

void servopulse(int angle)//定义一个脉冲函数
{
  int pulsewidth=(angle*11)+500;  //将角度转化为500-2480的脉宽值
  digitalWrite(servopin,HIGH);    //将舵机接口电平至高
  delayMicroseconds(pulsewidth);  //延时脉宽值的微秒数
  digitalWrite(servopin,LOW);     //将舵机接口电平至低
  delayMicroseconds(20000-pulsewidth);
}

```
#Result:
The servo will change direction according to the compass's direction. because the compass's range is from 0 to 360, while Servo could only serve for 180 degrees, we need to change th input parameter of compass by divide 2.     

![tuoji1.jpg](/images/tuoji1.jpg)


![tuoji2.jpg](/images/tuoji2.jpg)  


![tuoji3.jpg](/images/tuoji3.jpg)
