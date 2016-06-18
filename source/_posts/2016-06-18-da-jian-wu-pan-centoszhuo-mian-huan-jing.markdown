---
layout: post
title: "搭建无盘CentOS桌面环境"
date: 2016-06-18 13:43:48 +0800
comments: true
categories: linux
---
### 网络准备
创建一个无DHCP的网络:    

![/images/2016_06_18_13_53_06_399x429.jpg](/images/2016_06_18_13_53_06_399x429.jpg)    

DHCP服务器我们将配置在PXE服务器节点上。    

### PXE节点配置
#### 初始化配置
最小化安装CentOS 7 Server。并配置其IP地址为`10.19.20.2`.    
关闭selinux和firewalld服务:    

```
# vi /etc/selinux/config 
SELINUX=disabled

# systemctl disable firewalld.service
```
#### 使用DVD作为源
创建挂载目录并挂在DVD：    

```
# mkdir /cdrom
# mount -t iso9660 -o loop ./CentOS-7-x86_64-Everything-1511.iso /cdrom/
```
创建新的repo文件:    

```
# vi /etc/yum.repos.d/local.repo

[LocalRepo]
name=Local Repository
baseurl=file:///cdrom
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
```
生成新的缓存：    

```
# mkdir back
# mv CentOS-* back
# yum makecache
```
安装一些必要的包:    

```
# yum install -y vim wget
```

#### TFTP Server
安装必要的包:    

```
# yum -y install syslinux xinetd tftp-server
# mkdir /var/lib/tftpboot/pxelinux.cfg 
# cp /usr/share/syslinux/pxelinux.0 /var/lib/tftpboot/ 
```
配置PXE：    

```
# vim /etc/xinetd.d/tftp 
disable = no
# systemctl start xinetd
# systemctl enable xinetd
```
#### DHCP服务器
安装:    

```
# yum install -y dhcp
```
配置:    

```
# vim /etc/dhcp/dhcpd.conf
    #
    # DHCP Server Configuration file.
    #   see /usr/share/doc/dhcp*/dhcpd.conf.example
    #   see dhcpd.conf(5) man page
    #
    # create new
    
    # specify domain name
    option domain-name "srv.world";
    # specify name server's hostname or IP address
    option domain-name-servers dlp.srv.world;
    # default lease time
    default-lease-time 600;
    # max lease time
    max-lease-time 7200;
    # this DHCP server to be declared valid
    authoritative;
    # specify network address and subnet mask
    subnet 10.19.20.0 netmask 255.255.255.0 {
        # specify the range of lease IP address
        range dynamic-bootp 10.19.20.200 10.19.20.254;
        # specify broadcast address
        option broadcast-address 10.19.20.255;
        # specify default gateway
        option routers 10.19.20.1;
        option domain-name-servers   10.19.20.2;
        filename        "pxelinux.0";
        next-server     10.19.20.2;
    }
```
启动并使能服务:    

```
# systemctl start dhcpd 
# systemctl enable dhcpd 
```
#### PXE服务器
安装一些必要的包:    

```
# yum -y install dracut-network nfs-utils
```
在PXE服务器上构建一个无盘系统用的文件系统

```
# mkdir -p /var/lib/tftpboot/centos7/root 
# yum groups -y install "Server with GUI" --releasever=7 --installroot=/var/lib/tftpboot/centos7/root/
```
给出root用户的默认密码:    

```
# python -c 'import crypt,getpass; \ 
print(crypt.crypt(getpass.getpass(), \
crypt.mksalt(crypt.METHOD_SHA512)))' 
Password:
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```
填入root密码到/etc/shadown中:    

```
# vim /var/lib/tftpboot/centos7/root/etc/shadow
root:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx:16372:0:99999:7:::
```
构建`/etc/fstab`文件:    

```
# vi /var/lib/tftpboot/centos7/root/etc/fstab
 none    /tmp        tmpfs   defaults   0 0
tmpfs   /dev/shm    tmpfs   defaults   0 0
sysfs   /sys        sysfs   defaults   0 0
proc    /proc       proc    defaults   0 0
```
下载pxe所需要的vmlinuz和initrd.img文件:    

```
# wget -P /var/lib/tftpboot/centos7/ \
http://mirrors.aliyun.com/centos/7/os/x86_64/images/pxeboot/vmlinuz \
http://mirrors.aliyun.com/centos/7/os/x86_64/images/pxeboot/initrd.img
```

创建默认的pxe启动项目:    

```
# vi /var/lib/tftpboot/pxelinux.cfg/default
# create new
 default centos7

label centos7
    kernel centos7/vmlinuz
    append initrd=centos7/initrd.img root=nfs:10.19.20.2:/var/lib/tftpboot/centos7/root rw selinux=0 
```

映射NFS服务器:    

```
# vi /etc/exports
/var/lib/tftpboot/centos7/root 10.19.20.0/24(rw,no_root_squash)
# systemctl start rpcbind nfs-server 
# systemctl enable rpcbind nfs-server 
```

现在在网络中加入新的机器，从PXE启动后，将直接进入到CentOS7的桌面。    
