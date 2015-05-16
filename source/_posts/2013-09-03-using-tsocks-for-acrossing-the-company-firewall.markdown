---
layout: post
title: "Using tsocks for acrossing the company firewall"
date: 2013-09-03 09:57
comments: true
categories: Linux
---
1\. 在家庭主机上配置DDNS服务，可以从no-ip.com申请一个免费的动态域名。no-ip同时提供了适用于不同平台的客户端，可以在其主页下载，并在家庭主机上安装之。家里的路由器上也可以配置DDNS，国内的可以用花生壳服务，而后开放DMZ主机给内网的主机即可。家庭主机需要开启sshd服务，这方面可以参考网上的有关ssh服务器的配置攻略

2\. 在公司主机上，使用下列命令即可建立ssh代理
{% codeblock %}
ssh -qTfnN -D 1394 xxx@xxx.no-ip.biz
{% endcodeblock %}

命令详解:
{% codeblock %}
-q Quite模式
-T 不分配伪终端
-f ssh后台运行
-n 将标准输入重定向到/dev/null
-N 不执行远程命令
-D 绑定本地端口1394
{% endcodeblock %}

接下来我们就可以使用本地的端口127.0.0.1:1394作为socket代理服务器了。

3\. 安装tsocks, 并配置.
{% codeblock %}
$ pacman -S tsocks
$ vim /etc/tsocks.conf
server = 127.0.0.1
server_type = 5
server_port = 1394
{% endcodeblock %}

4\. 使用tsocks运行出一个完全自由的终端：
{% codeblock %}
$ tsocks gnome-terminal
{% endcodeblock %}

在新弹出的终端内，无需设置任何代理即可自由访问各处资源，衍生于该终端的应用程序也可以直接享用家庭网络的自由权限。enjoy it!

