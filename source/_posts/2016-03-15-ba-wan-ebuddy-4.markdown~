---
layout: post
title: "把玩ebuddy(4)"
date: 2016-03-15 14:25:48 +0800
comments: true
categories: Linux
---
总结了一下ebuddy的玩法，最近加了点玩法，就是用ebuddy作为Bash运行脚本后的提示部件。譬如
，当完成了某个编译任务后，用ebuddy来告知任务的运行成功。     

```
$ Task A ; NOTIFY EBUDDY
```

### /bin/ebuddy
创建一个`/bin/ebuddy`的文件，内容如下:     

```
#!/bin/bash
FILE=/tmp/ebuddy
while true
do
	# if exists the file, then blinking the ebuddy.
  if [ -f $FILE ];
  then
	  # Exists the file, shining the ebuddy
     echo 07 > /dev/udp/127.0.0.1/8888
  else
	  # Now clear the status of the ebuddy
     echo 17 > /dev/udp/127.0.0.1/8888
  fi
#echo 07 > /dev/udp/127.0.0.1/8888
sleep 3
done
```
这个文件的意思是，如果存在`/tmp/ebuddy`文件，ebuddy的头会亮起，否则，清除ebuddy的状态。

### notifyebuddy && clearebuddy
这两个命令是做在.zshrc里的两个alias:     

```
$ vim ~/.zshrc
# For Using ebuddy
alias notifyebuddy='touch /tmp/ebuddy'
alias clearebuddy='rm -f /tmp/ebuddy'
```

这样我们可以在运行完某个命令后，告知ebuddy完成事件。

### 局限
不能同时标识两个以上的命令完成情况。     
