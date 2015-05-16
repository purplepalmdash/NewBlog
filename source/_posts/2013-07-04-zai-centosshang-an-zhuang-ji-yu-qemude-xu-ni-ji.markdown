---
layout: post
title: "在CentOS上安装基于qemu的虚拟机"
date: 2013-07-04 17:11
comments: true
categories: Linux
---
1\. 从源码安装qemu和vde(Virtual Distributed Ethernet)
Qemu的安装过程比较标准，编译vde时则需要有些小改动:
{% codeblock %}
$ svn co https://vde.svn.sourceforge.net/svnroot/vde/trunk/vde-2 vde_svn
$ cd vde_svn
$ autoreconf -fi
$ ./configure --enable-experimental --prefix=./Your_Destination
$ make
$ sudo make install
{% endcodeblock %}
在编译vde时，需要安装python-devel包并创建一个空的"stropts.h"文件才能通过编译:
{% codeblock %}
$ yum install python-devel
$ touch /usr/include/stropts.h
{% endcodeblock %}

2\. 创建虚拟网络, 并使用slirpvde建立默认的dhcpd服务器:
{% codeblock %}
$ vde_switch -s /tmp/switch
$ slirpvde -s /tmp/switch --dhcp
Starting slirpvde: virtual_host=10.0.2.2/24
                   DNS         =10.0.2.3
                   dhcp_start  =10.0.2.15
                   vde switch  =/tmp/switch
{% endcodeblock %}

3\. 创建qemu镜像并开始使用cdrom镜像安装系统:
{% codeblock %}
$ qemu-img create -f qcow2 Windows.qcow2 16G
Formatting 'Windows.qcow2', fmt=qcow2 size=17179869184 encryption=off cluster_size=65536 lazy_refcounts=off 

# 使用创建的镜像安装系统 
$ qemu-system-i386 -net nic,macaddr=52:54:00:00:EE:17 -net \
vde,vlan=0,sock=/tmp/switch -m 765 -enable-kvm  -cdrom \
/path_to_your_iso.iso  -boot d \
/path_to_your_image/Windows.qcow2 -vga std -vnc :7
{% endcodeblock %}

4\. 在本机上，可以使用vncviewer来查看安装情况：
{% codeblock %}
$ vncviewer Your_server_ip:7
{% endcodeblock %}

5\. 安装完毕后，启动创建好的虚拟机：
{% codeblock %}
$ qemu-system-i386 -net nic,macaddr=52:54:00:00:EE:17 -net \
vde,vlan=0,sock=/tmp/switch -m 765 -enable-kvm  \
-hda /path_to_your_image/Windows.qcow2 -vga std -vnc :7
{% endcodeblock %}

6\. 指定物理网卡:
{% codeblock %}
model=? ,rtl8139可以被Windows自动驱动
qemu-system-i386 -net nic,model=rtl8139,macaddr=52:54:00:00:EE:17 -net vde,sock=/tmp/switch -m 765 -enable-kvm -hda ./virt/Windows/Windows.qcow2 -vga std -vnc :7
{% endcodeblock %}
