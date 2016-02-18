---
layout: post
title: "Mutt Configuration On DO"
date: 2016-02-19 07:11:24 +0800
comments: true
categories: linux
---
For sending back the daily fetched items into China Great LAN, I have to setup
the smtp configuration for mutt on DO's ubuntu machine. Following are the
steps.    

Install the mutt and msmtp:    

```
$ sudo apt-get install -y mutt msmtp 
```

Edit following files:    

```
$ cat ~/.muttrc
set mbox_type=Maildir
set folder=$HOME/.mail
set spoolfile=~/.mail
set header_cache=~/.mail/.hcache
set sendmail="/usr/bin/msmtp"
set use_from=yes
set realname="YourRealName"
set from=YourUserNameHere@163.com
set envelope_from=yes 
```
msmtp rc config file:    

```
$ cat ~/.msmtprc
account default
host smtp.163.com
port 25
protocol smtp
auth plain
from YourUserNameHere@163.com
user YourUserNameHere
password YourPasswordHere
$ chmod 600 ~/.msmtprc
```
And muttrc under .muttrc and edit it with:   

```
$ mkdir -p  ~/.mutt
$ touch ~/.mutt/muttrc
$ cat ~/.mutt/muttrc
set realname='YourRealName'
set sendmail="/usr/bin/msmtp"
set edit_headers=yes
set folder=~/mail
set mbox=+mbox
set spoolfile=+inbox
set record=+sent
set postponed=+drafts
set mbox_type=Maildir

mailboxes +inbox +lovey-dovey +happy-kangaroos
```

Now send mail via:    

```
$ echo "cba" | mutt -s "Today download" YourFriendMail@qq.com
$ echo "cba" | mutt -s "Today download" YourFriendMail@qq.com  -a /var/www/cl.tar.xz
```
I tried to configure the qq.com mailbox, but failed, the above solution only
suitable for 163.com.    
