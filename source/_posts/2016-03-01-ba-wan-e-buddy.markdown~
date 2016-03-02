---
layout: post
title: "把玩e-Buddy"
date: 2016-03-01 10:47:55 +0800
comments: true
categories: embedded
---

### 状态
逆向工程得出的控制指令:     

```
################
#Commands
################
# GLADNESS =        00
# FEAR =            01
# FIZZ =            02
# PLEASANTSURPRISE =03
# GRIEF =                       04
# FURY =                        05
# QUELL =                       06
# REDHEAD =             07
# GREENHEAD =           08
# BLUEHEAD =            09
# YELLOWHEAD =          10
# BLAME =                       11
# BLUEGREENHEAD =       12
# WHITEHEAD =           13
# HEART =                       14
# WINGS =                       15
# BODY =                        16
# NOEFFECT =            17
# ONLINE =                      18
# BUSY =                        19
# DAZE =                        20
# BACKSOON =            21
# AWAY =                        22
# PHONE =                       23
# LUNCH =                       24
# OFFLINE =             25
```
功能列表:    

| 功能代码 | 描述          | 详细描述                                              |
| ---------|:-------------:| -----------------------------------------------------:|
| 00       | 开心          | 头灯变换彩色，翅膀扇动                                |
| 01       | 惊恐          | 头灯变换彩色，心灯红色，翅膀扇动                      |
| 02       | 嘶嘶          | 头灯变换彩色，心灯红色，翅膀扇动, 身体转动            |
| 03       | 惊喜          | 头灯变换彩色，心灯红色，翅膀扇动, 之后身体转动，头灯红|
| 04       | 酸溜溜        | 头灯变换彩色，翅膀扇动, 之后头灯变幻                  |
| 05       | 愤怒          | 头灯红色，翅膀扇动, 身体扭动                          |
| 06       | 扭动          | 头灯蓝色，翅膀扇动, 身体平缓扭动                      |
| 07       | 红头          | 头灯红色, 闪烁                                        |
| 08       | 绿头          | 头灯绿色，闪烁                                        |
| 09       | 蓝头          | 头灯蓝色，闪烁                                        |
| 10       | 黄头          | 头灯黄色，闪烁                                        |
| 11       | 责骂          | 头灯蓝色，闪烁                                        |
| 12       | 绿色->蓝色头  | 头灯绿色到蓝色变换                                    |
| 13       | 白头闪        | 头灯白色变换                                          |
| 14       | 心跳          | 心灯红色闪烁后，身体转动                              |
| 15       | 挥翅          | 翅膀不停挥动                                          |
| 16       | 身体转动      | 身体转动                                              |
| 17       | 无效果        | 无任何效果                                            |
| 18       | 在线          | 心灯一直闪动，不会停止，除非转为其他效果              |
| 19       | 忙碌          | 心灯一直快速闪动，不会停止，除非转为其他效果          |
| 20       | 发呆          | 心灯一直慢速闪动，不会停止，除非转为其他效果          |
| 21       | 马上回来      | 心灯三短闪烁后停止一会，不会停止，除非转为其他效果    |
| 22       | 离开          | 心灯三短闪烁后停止一会，不会停止，除非转为其他效果    |
| 23       | 离开          | 心灯持续跳动，不会停止，除非转为其他效果              |
| 24       | 离开          | 心灯两短后持续跳动，不会停止，除非转为其他效果        |
| 25       | 离开          | 心灯四短后，永久沉默                                  |

### e-buddy本地服务器
有人已经实现了e-buddy的python库，直接拷贝到本地并运行:    

```
$ git clone git@github.com:purplepalmdash/pybuddy-dx.git
$ virtualenv2 venv2 --python=python2.7
 ✗ . ~/venv2/bin/activate
(venv2) ➜  _posts git:(master) ✗ python
Python 2.7.11 (default, Dec  6 2015, 15:43:46) 
[GCC 5.2.0] on linux2
$ pip install pyusb
$ python pybuddyDX1.py
2016-02-23 15:51:39,242 INFO     Searching e-buddy...
2016-02-23 15:51:39,399 INFO     DX e-buddy found!
2016-02-23 15:51:39,962 INFO     Starting daemon...
```
py文件运行后将监听127.0.0.1的8888端口，通过往该端口输入状态码，e-buddy将呈现不同的状态
。     

### 操纵e-buddy
用python操控e-buddy的命令如下:    

```
python
Python 2.7.11 (default, Dec  6 2015, 15:43:46) 
[GCC 5.2.0] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> import socket
>>> UDP_IP = "127.0.0.1"
>>> UDP_PORT = 8888
>>> sock = socket.socket(socket.AF_INET,  socket.SOCK_DGRAM)
>>> sock.sendto("07",(UDP_IP, UDP_PORT))
2
```

或者，直接用bash来操作udp socket:    

```
#!/bin/bash
while true
do
echo 07 > /dev/udp/127.0.0.1/8888
sleep 3
done
```
以上的脚本就可以直接将e-buddy的头像置为红色，且一直闪烁。    
