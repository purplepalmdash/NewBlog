---
layout: post
title: "把玩ebuddy(3)"
date: 2016-03-05 21:39:41 +0800
comments: true
categories: linux
---
早上起来刷微信, 觉得网页版微信的提示信息大可用ebuddy来响应. 说干就干,以下是解
决方案.     

### gnotifier
写作时,我的firefox版本是44.0.2, 需要安装gnotifier这个插件,从而把firefox的提示
消息转为系统提示信息, 下载地址在:     

[https://addons.mozilla.org/en-US/firefox/addon/gnotifier/](https://addons.mozilla.org/en-US/firefox/addon/gnotifier/)   

点击`Add to Firefox`即完成安装:    

![/images/2016_03_05_21_50_12_766x490.jpg](/images/2016_03_05_21_50_12_766x490.jpg)    

### 查看dbus消息
gnotifier将网页版微信的提示消息转为了系统提示消息, 那么只需要获取到系统消息总
线里的提示信息, 筛选出我们要的类型后, 给ebuddy发送相应的指令即可.     

`dbus-monitor`工具可用于侦听dbus总线里的消息, 我们来运行一下,如下:    

```
$  dbus-monitor --session
interface='org.freedesktop.Notifications',member='Notify'

signal time=1457186062.137082 sender=org.freedesktop.DBus ->
destination=:1.163 serial=2 path=/org/freedesktop/DBus;
interface=org.freedesktop.DBus; member=NameAcquired
   string ":1.163"
signal time=1457186062.137154 sender=org.freedesktop.DBus ->
destination=:1.163 serial=4 path=/org/freedesktop/DBus;
interface=org.freedesktop.DBus; member=NameLost
   string ":1.163"
method call time=1457186083.405690 sender=:1.39 -> destination=:1.14
serial=220 path=/org/freedesktop/Notifications;
interface=org.freedesktop.Notifications; member=Notify
   string "Firefox"
   uint32 0
   string "/tmp/gnotifier-3Fh5Sa"
   string "yfp"
   string "[Sticker][Sticker][Sticker]"
   array [
   ]
   array [
   ]
   int32 -1
method call time=1457186086.866000 sender=:1.39 -> destination=:1.14
serial=221 path=/org/freedesktop/Notifications;
interface=org.freedesktop.Notifications; member=Notify
   string "Firefox"
   uint32 0
   string "/tmp/gnotifier-9kaLsI"
   string "yfp"
   string "test"
   array [
   ]
   array [
   ]
   int32 -1
```

以上是两条从微信号为`yfp`的用户发送给网页端微信的dbus总线消息, 我们要注意的是,
需要从dbus session总线取得此信息(system bus和session bus的差别可以自行Google).    

### python2-dbus
ArchLinux下有`python-dbus`和`python2-dbus`两个关于dbus的python绑定库, 个人比较
习惯python2的缘故,安装`python2-dbus`

```
$ sudo pacman -Ss python2-dbus
extra/python2-dbus 1.2.0-5 [installed]
    Python 2.7 bindings for DBUS
```

用于过滤/提取dbus总线消息的python代码如下, 另存为`DbusEbuddy.py`:     

```python
import glib
import dbus
import subprocess
from dbus.mainloop.glib import DBusGMainLoop

def notifications(bus, message):
    if (len(message.get_args_list()) > 0):
        if ('Firefox' == message.get_args_list()[0]):
                if ('yfp' == message.get_args_list()[3]):
                    bashCommand = 'echo 01 > /dev/udp/127.0.0.1/8888'
                    output = subprocess.check_output(['bash','-c',bashCommand])

DBusGMainLoop(set_as_default=True)

bus = dbus.SessionBus()
bus.add_match_string_non_blocking("eavesdrop=true,\
    interface='org.freedesktop.Notifications', member='Notify'")
bus.add_message_filter(notifications)

mainloop = glib.MainLoop()
mainloop.run()
```
简单解释一下, 这几行代码首先attach到dbus的sessionbus总线,
`org.freedesktop.Notification`端口上所有`Notify`的成员, 如果匹配到这种消息, 则
通过`add_message_filter()`调用回调函数.    

`notifications`是我们定义的回调函数,这个回调函数同样很简单, 如果消息长度大于
0(消息非空), 则检查消息的来源(`message.get_args_list()[0]`), 选取来自Firefox的
, 由yfp(`messages.get_args_list()[3]`)用户发来的消息, 作出对应的动作
(`echo 01 > /dev/udp/127.0.0.1/8888`). 

### 使用
首先开启pybuddyDX库(注意要先安装python2版本的pyusb, 上一篇文章有讲):    

```
$ git clone git@github.com:purplepalmdash/pybuddy-dx.git
$ sudo python2 ~/Code/python/pybuddy-dx/pybuddyDX.py
```
此时系统在8888端口监听ebuddy动作, 直接运行`DbusEbuddy.py`    

```
$ sudo python2 ~/Code/python/DbusEbuddy.py
```

以后每条由用户yfp发来的消息,都将引发ebuddy人偶执行01指令对应的动作.     

### 延伸
可以匹配不同的人名, 执行不同的动作. 例如:    

```
李四	执行02指令
王五	执行12指令
某某群	执行08指令
```

当然,根据需要,也可以制定一些规则,譬如某VIP用户, 就是微信里你特别看重的那个人
,TA发消息来以后, 人偶心跳不止(指令19即是). 但这样一来,就引入了清零问题, 即重置
人偶状态, 很简单,我们用`notify-send`这条命令, 发送出指令17给人偶让它重置状态
即可.     

代码的修改:    

```python
def notifications(bus, message):
    if (len(message.get_args_list()) > 0):
        if ('Firefox' == message.get_args_list()[0]):
                if ('yfp' == message.get_args_list()[3]):
                    bashCommand = 'echo 19 > /dev/udp/127.0.0.1/8888'
                    output = subprocess.check_output(['bash','-c', bashCommand])
        if ('notify-send' == message.get_args_list()[0]):
                if ('Clear' == message.get_args_list()[3]):
                    bashCommand = 'echo 17 > /dev/udp/127.0.0.1/8888'
                    output = subprocess.check_output(['bash','-c', bashCommand])
``` 

而对应的清空命令则可以写成alias形式(我用的是zsh, bash类似):    

```
$ vim ~/.zshrc
alias clearnotify="notify-send 'Clear' 'This is a clear ebuddy notification.' --icon=dialog-information"
$ source ~/.zshrc
$ clearnotify
```

### 测试
现在开始测试, 首先让yfp发微信给浏览器里登录的微信用户, 可以看到, 当浏览器收到
消息后, 系统桌面出现提示, 人偶心脏处的红灯开始狂闪, 不会停止.    

![/images/1039489558.jpg](/images/1039489558.jpg)    

输入`clearnotify`命令后, 人偶恢复正常.   

### 下一步需要做的
1. Windows响应?     
2. 如何通过微信的API获取到好友列表,从而动态指定需要监听的人和事件?    
3. 图形界面的配置?     
