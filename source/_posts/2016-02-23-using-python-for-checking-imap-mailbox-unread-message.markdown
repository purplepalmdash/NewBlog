---
layout: post
title: "Using python for checking imap mailbox unread message"
date: 2016-02-23 19:52:57 +0800
comments: true
categories: Linux
---
Just paste some python scripts:    

```
>>> import imaplib
>>> obj=imaplib.IMAP4_SSL('imap.163.com','993')
>>> obj.login('XXXXX','XXXXXXXX')
('OK', [b'LOGIN completed'])
>>> obj.select()
('OK', [b'49'])
>>> obj.search(None,'Unseen')
('OK', [b''])
>>> len(obj.search(None, 'UnSeen')[1][0].split()) 
0
>>> len(obj.search(None, 'UnSeen')[1][0].split()) 
1
>>> len(obj.search(None, 'UnSeen')[1][0].split()) 
2
>>> len(obj.search(None, 'UnSeen')[1][0].split()) 
2
>>> len(obj.search(None, 'UnSeen')[1][0].split()) 
1
>>> 
```

Using the unread counts, you could easily interact with some other programs,
for example shining LEDs.    
