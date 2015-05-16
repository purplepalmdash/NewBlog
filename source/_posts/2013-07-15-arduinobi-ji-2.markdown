---
layout: post
title: "Arduino笔记(2)"
date: 2013-07-15 16:33
comments: true
categories: Embedded arduino
---
1\. PWM概念：
PWM( Pulse Width Modulation).简单来说，在arduino中我们可以理解为就是通过调节占空比来实现不同电压输出。

图片：

2\. analogWrite()

描述

从一个引脚输出模拟值（PWM）。可用于让LED以不同的亮度点亮或驱动电机以不同的速度旋转。analogWrite()输出结束后，该引脚将产生一个稳定的特殊占空比方波，直到下次调用analogWrite()（或在同一引脚调用digitalRead()或digitalWrite()）。PWM信号的频率大约是490赫兹。

在大多数arduino板（ATmega168或ATmega328），只有引脚3，5，6，9，10和11可以实现该功能。在aduino Mega上，引脚2到13可以实现该功能。老的Arduino板（ATmega8）的只有引脚9、10、11可以使用analogWrite()。在使用analogWrite()前，你不需要调用pinMode()来设置引脚为输出引脚。

analogWrite函数与模拟引脚、analogRead函数没有直接关系。

通过读取电位器的阻值控制LED的亮度

{% codeblock %}
int ledPin = 9;  // LED连接到数字引脚9
int analogPin = 3;  //电位器连接到模拟引脚3
int val = 0;  //定义变量存以储读值
 
void setup()
 
{
pinMode（ledPin,OUTPUT）;  //设置引脚为输出引脚
}
 
void loop()
{
val = analogRead（analogPin）;  //从输入引脚读取数值
analogWrite（ledPin，val / 4）;  // 以val / 4的数值点亮LED（因为analogRead读取的数值从0到1023，而analogWrite输出的数值从0到255）
}
{% endcodeblock %}


3\. 调节PWM值的程序：

{% codeblock %}
int n=0;
void setup ()
{
  pinMode(4,INPUT);
  pinMode(6,OUTPUT);      //该端口需要选择有#号标识的数字口
  pinMode(10,INPUT);
}
 
void loop()
{
  int up =digitalRead(4);          //读取4号口的状态
  int down = digitalRead(10);      //读取10号口的状态   
  if (up==HIGH)                    //判断4号口目前是否是高电平
  { 
   n=n+5;                         //每次累加值为5
    if (n>=255) {
      n=255;
    }            //限定最大值为255   
analogWrite(6,n);               //使用PWM控制6号口输出，变量n的取值范围是0-255 
    delay (300);
  }
  if (down==HIGH)                    //减少亮度
  {
   n=n-5;
    if (n<=0) {
      n=0;
    }
 analogWrite(6,n);
    delay (300);
  }
}
{% endcodeblock %}

需要选择#号标识的数字口是因为这些端口需要支持PWM功能。而后在loop()函数中，将修改后的n值输出到6号端口。

4\. analogRead()

描述

从指定的模拟引脚读取数据值。
Arduino板包含一个6通道（Mini和Nano有8个通道，Mega有16个通道），10位模拟数字转换器。这意味着它将0至5伏特之间的输入电压映射到0至1023之间的整数值。这将产生读数之间的关系：5伏特/
1024单位，或0.0049伏特（4.9
mV）每单位。输入范围和精度可以使用analogReference()改变。
它需要大约100微秒（0.0001）来读取模拟输入，所以最大的阅读速度是每秒10000次。

语法

analogRead（PIN）

数值的读取

引脚：从输入引脚（大部分板子从0到5，Mini和Nano从0到7，Mega从0到15）读取数值

返回

从0到1023的整数值


5\. 实现呼吸灯：
{% codeblock %}
void setup ()
{
  pinMode(11,OUTPUT);
}
 
void loop()
{
  for (int a=0; a<=255;a++)                //循环语句，控制PWM亮度的增加
  {
    analogWrite(11,a);
    delay(16);                             //当前亮度级别维持的时间,单位毫秒            
  }
    for (int a=255; a>=0;a--)             //循环语句，控制PWM亮度减小
  {
    analogWrite(11,a);
    delay(16);                             //当前亮度的维持的时间,单位毫秒  
  }
  delay(800);                             //完成一个循环后等待的时间,单位毫秒
}

{% endcodeblock %}


或者：
{% codeblock %}

int n = 0; // n 从 1 至 255，控制led亮度
int i = 5;  // 递进数

void setup()
{
  pinMode( 11, OUTPUT); //设置11口为PWM输出端
}

void loop()
{
  n += i;                               // n每次增加 i 

  

  if ( n == 255 || n == 0)
//在n升至255或者降至0时，i进行反转。这样led灯能在亮暗间转换
   i = -i; 

  analogWrite( 11, n );
  delay( 50 );       //延迟50ms，进行下一次亮度调整
  
   if( n == 0)
     delay(1800);
  
}
{% endcodeblock %}

6\. 实现温度计

主要器件LM315.
{% codeblock %}

void setup() {
 
  Serial.begin(9600);         //使用9600速率进行串口通讯
}
 
void loop() {
 
  int n = analogRead(A0);    //读取A0口的电压值
 
  float vol = n * (5.0 / 1023.0*100);
//使用浮点数存储温度数据，温度数据由电压值换算得到
 
  Serial.println(vol);                   //串口输出温度数据
  delay(2000);                           //等待2秒，控制刷新速度
}
{% endcodeblock %}

Serial.begin()

将串行数据传输速率设置为位/秒（波特）。与计算机进行通信时，可以使用这些波特率：300，1200，2400，4800，9600，14400，19200，28800，38400，57600或115200。当然，您也可以指定其他波特率- 例如，引脚0和1和一个元件进行通信，它需要一个特定的波特率。 

Serial.println()
打印数据到串行端口，输出人们可识别的ASCII码文本并回车 (ASCII 13, 或 '\r') 及换行(ASCII 10, 或 '\n')。此命令采用的形式与Serial.print ()相同 。

和DS18b20有什么区别？

DS18b20是数字的，数字的出来的是方波，用脉冲方波和协议来通讯，模拟的出来的是电压，利用AD转换（ARDUINO的模拟脚可以理解为就是数字脚+AD/DA转换模块，如果你需要大量的模拟脚但是不要求数字脚，可以直接外接AD/DA转换器来实现）来得到测量值并换算成温度

0-100度 对应0-5v  模拟口返回数值0-1024  所以。模拟口的值 1=0.48828125

7\. 光敏电阻的程序改动：

"达文西的手电筒"，有光才能亮，没光，绝对不会亮！
{% codeblock %}
int a =300;     //此处需是环境基础亮度变量，请查看自己的亮度数值，
                //填写到此处数值要略大于所测得的数据但小于灯光下的数据
void setup ()
{
  Serial.begin(9600);
  pinMode(13,OUTPUT);
}
void loop()
{
  int n = analogRead(A0);            //读取模拟口A0数值
  Serial.println(n);
  if (n>= a )                   //对光线强度进行判断，如果比我们的预设值大
就点亮LED否则就关闭
  {
    digitalWrite(13,HIGH);
  }
  else
  {
    digitalWrite(13,LOW);
  }
}
{% endcodeblock %}

修改为符合逻辑的光控电路：

{% codeblock %}
/* 光强度小于临界值 */
if ( n < a)
  {
    digitalWrite(13,HIGH); 		// 点亮LED
  }
  else
  {
    digitalWrite(13,LOW);		// 超过临界值时，关闭
  }
{% endcodeblock %}
	
 光敏三极管有凸起的一边为发射极，此端接A0检测口，同时并联一个10K欧姆的分压电阻到地线以扩展光敏三极管的灵敏度（此处电阻越小灵敏度越高）。另一极使用5V输入。



