---
layout: post
title: "Remote SSH and VNC Forwarding"
date: 2014-03-30 15:05
comments: true
categories: SSH
---
因为有中转服务器的存在，我们需要建立ssh端口转发，以便一步到位通过中转服务器登录到远程主机。<br />

###ssh转发
建立ssh转发：<br />

```
	ssh -L 2121:192.168.1xx.xxx.xxx 1xx.xxx.xxx.xxx -l Tomcat

```
建立以后则可以：<br />

```
	ssh root@localhost -p 2121

```
Autossh without entering password:<br />

```
	cat id_rsa.pub | ssh Tomcat@1xx.xxx.xx.xxx 'cat >>.ssh/authorized_keys'
	# After login on to 170, run:
	chmod 600 ~/.ssh/authorized_keys

```
###VNC设置
配置VNC自动启动:<br />

```
	vim /etc/init.d/vncserver
	# 添加：
	VNCSERVERS="1:rohc"
	VNCSERVERARGS[1]="-geometry 1280x1024"
	$ chkconfig vncserver on

```
设置VNC转发：<br />

```
	ssh -L 2333:192.168.1xx.xxx:5901 1xx.xxx.xxx.xxx -l Tomcat

```
之后就可以通过:<br />

```
	vncviewer localhost:5901来访问VNC了。	

```
