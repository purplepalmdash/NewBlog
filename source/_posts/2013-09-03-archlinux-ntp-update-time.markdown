---
layout: post
title: "ArchLinux Ntp update time"
date: 2013-09-03 07:47
comments: true
categories: Linux
---
1\. 安装ntpd
{% codeblock %}
$ pacman -S ntpd
{% endcodeblock %}

2\. 配置ntp服务器
{% codeblock %}
$ vim /etc/ntp.conf
server 0.pool.ntp.org iburst
server 1.pool.ntp.org iburst
server 2.pool.ntp.org iburst
server 3.pool.ntp.org iburst
{% endcodeblock %}

3\. 同步时间
{% codeblock %}
$ sudo ntpd -gq
{% endcodeblock %}

4\. 加入守护进程运行
{% codeblock %}
$ sudo systemctl enable ntpd
{% endcodeblock %}
