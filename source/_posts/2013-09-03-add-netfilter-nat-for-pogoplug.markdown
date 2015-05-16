---
layout: post
title: "Add Netfilter NAT for pogoplug"
date: 2013-09-03 16:06
comments: true
categories: Linux Embedded
---
Pogoplug上了debian wheezy后，想配置成VPN服务器，在最后一步配置iptables时发现无法激活NAT表。 

显示结果为：
{% codeblock %}
$ iptables -t nat -A POSTROUTING -s 10.10.10.0/24 -o eth0 -j MASQUERADE
can't initialize iptables table 'NAT': Table does not exist (do you need to insmod?)
{% endcodeblock %}

解决方法:重新编译NetFilter模块。

下载Linux3.1.10内核并解压到/usr/src

$ make menuconfig

{% img  img /images/2013_09_03_12_53_06_868x411.jpg %}

而后：

{% img  img /images/2013_09_03_12_54_08_749x362.jpg %}

确保以下选项被激活：

```
	CONFIG_NF_CONNTRACK
	CONFIG_NF_CONNTRACK_IPV4
	CONFIG_NF_NAT
	CONFIG_IP_NF_IPTABLES
```

而后编译，由于在嵌入式系统上编译速度较慢，所以只是编译目录下对应的模块，其他的则不编：

{% codeblock %}
$ make M=net/netfilter modules  # Make all modules in specified dir
$ make M=net/netfilter          # Same as 'make M=dir modules'
$ make M=net/netfilter  modules_install # Install modules
{% endcodeblock %}

这样就应该可以了，具体的验证等回家再看。


