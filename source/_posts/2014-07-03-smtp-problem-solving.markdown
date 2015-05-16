---
layout: post
title: "SMTP Problem Solving"
date: 2014-07-03 10:30
comments: true
categories: smtp
---
Recently I've set up a ticket system, OTRS, which uses smtp for sending out email. It works well in my virtual machine, and in my own server. But when deploying it onto the lab PC, it cannot send out email via smtp. Following is the solving procedure for this problem.    
### SMTP Server
When Login into the server, following is how to using smtp for sending out email.    

```
$ telnet localhost 25
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
220 nxxxxx.xxx.fukcfuck-fugkock.com ESMTP Sendmail 8.14.5+Sun/8.13.3; Thu, 26 Jun 2014 06:43:37 -0500 (CDT)
ehlo localhost
250-nxxxxx.xxx.fukcfuck-fugkock.com Hello localhost [127.0.0.1], pleased to meet you
250-ENHANCEDSTATUSCODES
250-PIPELINING
250-EXPN
250-VERB
250-8BITMIME
250-SIZE
250-DSN
250-ETRN
250-DELIVERBY
250 HELP
mail from: kkkkk@xxxxxx.xx.fugkock.com
250 2.1.0 kkkkk@xxxxxx.xx.fugkock.com... Sender ok
rcpt to:xxx_xxx.mao@fukcfuck-fugkock.com
250 2.1.5 xxx_xxx.mao@fukcfuck-fugkock.com... Recipient ok
data
Subjet:354 Enter mail, end with "." on a line by itself
Hi,
Are you there?
regards,
Admin
.
250 2.0.0 s5QBhbEu014970 Message accepted for delivery
quit
221 2.0.0 xxxxxx.xxx.fukcfuck-fugkock.com closing connection
Connection to localhost closed by foreign host.

```

### Error message
When sending out the /var/log/messages will record the failure message, like: 

```
Jul  1 00:57:10 Linux01 OTRS-CGI-37[2757]: [Info][Kernel::System::CustomerUser::DB::CustomerUserAdd] CustomerUser: '9988@qq.com' created successfully (1)!
Jul  1 00:57:10 Linux01 OTRS-CGI-37[2757]: [Notice][Kernel::System::CustomerUser::DB::SetPassword] CustomerUser: '9988@qq.com' changed password successfully!
Jul  1 00:57:12 Linux01 OTRS-CGI-37[2757]: [Error][Kernel::System::Email::SMTP::Send][Line:139]: Can't send to '9988@qq.com': 5505.7.1 <9988@qq.com>... Relaying denied. IP name lookup failed [104.xxx.xxx.53]#012! Enable Net::SMTP debug for more info!
Jul  1 00:57:12 Linux01 OTRS-CGI-37[2757]: [Info][Kernel::System::Email::Send] Error sending message

```

It says the IP name lookup failed.     
### Bug Shooting
Use tcpdump for capturing the package, comparing to the normal package.    
It indicates the message "IP name lookup failed [104.xxx.xxx.53]", so I guess this may caused by reverse refer of smtp server.   

Use dnslookup for the correct record:    

```
[Trusty@Linux01 ~]$ nslookup 104.xxx.xxx.53
Server:        104.xxx.xxx.xxx
Address:    104.xxx.xxx.xxx#53

** server can't find 53.xxx.xxx.104.in-addr.arpa.: NXDOMAIN

=============================================================


[Trusty@Linux01 ~]$ nslookup 104.xxx.xxx.240
Server:        104.xxx.xxx.xxx
Address:    104.xxx.xxx.xxx#53

Non-authoritative answer:
240.xxx.xxx.104.in-addr.arpa    name = xxxxxxxx.xx.fukcfuck-fugkock.com.

```

So the solution is quite clear: If we give 104.xxx.xxx.140 a name, we could easily reached this machine from smtp server, thus the problem may be solved.    
