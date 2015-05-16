---
layout: post
title: "自动获取本机公网地址的方法"
date: 2013-09-10 19:59
comments: true
categories: Linux
---
此方法适用于主机位于防火墙/路由器后，只有局域网地址的情况。如果在路由器上开启DMZ映射到该主机，则直接可以从公网其他位置访问该主机。

功能:  

*   主机开机时会将路由器的公网地址发送到指定邮箱。
*   路由器IP地址发生变化时会将更新后的IP地址发送到指定邮箱。

1\. 首先，配置好mutt, 关于mutt的配置，详见：  
[https://wiki.archlinux.org/index.php/Mutt](https://wiki.archlinux.org/index.php/Mutt/ "ArchLinux Mutt")


2\. 保存下面代码到某个文件中，比如/bin/autoip, 而后chmod a+x /bin/autoip:  
{% codeblock autoip.sh - autoip.sh %}
#!/bin/sh
origip=`curl "http://checkip.dyndns.org/" 2>/dev/null | awk '{print $6}'|cut -d '<' -f1`
echo $origip | mutt -s "ip is" -- kkkttt@gmail.com
while :
do
	publicip=`curl "http://checkip.dyndns.org/" 2>/dev/null | awk '{print $6}'|cut -d '<' -f1`
	sleep 600
	judgeip=`curl "http://checkip.dyndns.org/" 2>/dev/null | awk '{print $6}'|cut -d '<' -f1`
	if [ "$publicip" != "$judgeip" ]
	then
		echo $judgeip | mutt -s "ip changed" -- kkkttt@gmail.com
	else
		:
	fi
done
{% endcodeblock %}

3\. 在/etc/init.d/rc.local中添加一行：  

```
/bin/autoip &
```

tips:  
codeblocks后接lang:bash照样可以激活高亮
