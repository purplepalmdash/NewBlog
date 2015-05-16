---
layout: post
title: "ShadowSocks on DigitalOcean"
date: 2014-10-27 13:15
comments: true
categories: linux
---
Mainly recorded the steps for installation:    

```
# apt-get install python-pip
# pip install shadowsocks
# vim /etc/shadowsocks.json
{
    "server":"1xx.xxx.xxx.xxx",
    "server_port":xxxx,
    "local_address": "127.0.0.1",
    "local_port":1080,
    "password":"Pass!Pass!Pass",
    "timeout":300,
    "method":"aes-256-cfb",
    "fast_open": false,
    "workers": 1
}
# apt-get install supervisor
# vim /etc/supervisor/conf.d/shadowsocks.conf
[program:shadowsocks]
command=ssserver -c /etc/shadowsocks.json
autorestart=true
user=nobody
# vim /etc/default/supervisor
ulimit -n 51200
# service supervisor start

```
Then in client you could use a shadownsocks client for connecting to remote servers and enjoy the free internet.    

