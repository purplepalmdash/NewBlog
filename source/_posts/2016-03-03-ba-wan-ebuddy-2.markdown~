---
layout: post
title: "把玩ebuddy(2)"
date: 2016-03-03 10:15:43 +0800
comments: true
categories: embedded
---
### ArchLinux配置过程
因为ArchLinux默认python版本为python3, 使用python2激活e-buddy人偶:    

```
$ sudo pacman -S python2-pip
$ sudo pip2 install pyusb
$ sudo python2 ~/Code/ebuddy/pybuddy-dx/pybuddyDX.py
$ sudo netstat -anp | grep 8888
udp        0      0 127.0.0.1:8888          0.0.0.0:*                           14635/python2 
```

接下来就是往`127.0.0.1:8888`发送指令控制人偶的干活了。具体的指令可以见上一篇文章。        

### 定期检查邮件控制人偶
先安装用于检查imap服务端状态的python模块:    

```
$ sudo pip2 install imapclient
```
检查邮件的脚本如下, 该脚本检查163邮箱的IMAP服务器，如果有新邮件，人偶的头就会出现颜色渐
变，否则，则显示绿灯闪烁:    

```
#!/usr/bin/env python
import imaplib 
from imapclient import IMAPClient
import time
import subprocess
import thread

DEBUG = True
 
HOSTNAME = 'imap.163.com'
USERNAME = 'XXXXXXXX'
PASSWORD = 'XXXXXXXX'
MAILBOX = 'Inbox'
newmails = 0
 
NEWMAIL_OFFSET = 0   # my unread messages never goes to zero, yours might
MAIL_CHECK_FREQ = 60 # check mail every 60 seconds

# Define a function for checking email
def check_mail( threadName):
    while True:
        # Login into the imap server and check the numbers for the new mail.
        server = IMAPClient(HOSTNAME, use_uid=True, ssl=True)
        server.login(USERNAME, PASSWORD)
        if DEBUG:
            print('Logging in as ' + USERNAME)
            select_info = server.select_folder(MAILBOX)
            print('%d messages in INBOX' % select_info['EXISTS'])

        folder_status = server.folder_status(MAILBOX, 'UNSEEN')
        global newmails
        newmails = int(folder_status['UNSEEN'])

        if DEBUG:
            print "You have", newmails, "new emails!"
        time.sleep(MAIL_CHECK_FREQ)

def loop():
 
    if newmails > NEWMAIL_OFFSET:
        bashCommand = 'echo 12 > /dev/udp/127.0.0.1/8888'
        output = subprocess.check_output(['bash','-c', bashCommand])
        time.sleep(8)
    else:
        bashCommand = 'echo 08 > /dev/udp/127.0.0.1/8888'
        output = subprocess.check_output(['bash','-c', bashCommand])
        time.sleep(5)
 
if __name__ == '__main__':
    try:
        print 'Press Ctrl-C to quit.'
        thread.start_new_thread( check_mail, ("Thread-1", ) )
        while True:
            loop()
    finally:
        print "finally comes here!"
```

