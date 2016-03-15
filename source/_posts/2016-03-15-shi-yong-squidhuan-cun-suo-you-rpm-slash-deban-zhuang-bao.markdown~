---
layout: post
title: "使用squid缓存所有rpm/deb安装包"
date: 2016-03-15 10:23:34 +0800
comments: true
categories: Linux
---
在进行自动化部署的时候，需要频繁安装系统，鉴于工作环境的带宽有限，我需要设置一个代理服
务器，用于缓存所有的RPM/DEB安装包，以便自动化部署可以在瞬间完成。    

以下示例运行在ArchLinux上。   

### Squid搭建
Squid介绍:    

Squid 是一个 Web 缓存代理，支持 HTTP, HTTPS, FTP, 以及更多。它通过缓存与重用经常请求的
web页面，减少带宽使用同时提升了响应时间。Squid 具有可扩展的访问控制功能，同时可以使服务
器加速。它运行在 Unix 和 Windows 中，采用 GNU GPL 协议发布。    

安装squid:    

```
$ sudo pacman -S squid
```
我们需要配置squid以便它能适配我们的环境，我的环境里主要需要做以下几个事情：   
1. 更改squid缓存目录到/home分区。    
2. 更改squid缓存目录大小为30G以上。    
3. 更改缓存文件大小，以便它支持大的RPM/DEB包。   

更改缓存目录， 找到以下的行，在其下添加我们自定义的缓存目录:    

```
$ sudo vim /etc/squid/squid.conf
# Uncomment and adjust the following to add a disk cache directory.
#cache_dir ufs /var/cache/squid 100 16 256
cache_dir ufs /home/dash/squid 30000 16 256
``` 
我们将在指定目录下创建目录， 第一层数为16, 每个文件夹下最多包含256个子文件夹。   

在配置文件的最后加入以下行，以支持更大的缓存文件:    

```
$ sudo vim /etc/squid/squid.conf
maximum_object_size 200 MB
``` 

现在开始创建缓存目录:    

```
$ squid -z
```
启动服务后，运行检查

```
$ sudo systemctl restart squid
$ sudo systemctl enable squidz
$ sudo systemctl -k check
```
验证可以通过`netstat -anp | grep 3128`来检查squid进程是否运行。     

### 使用squid代理



### apt-cacher
以上设置的代理仅能支持RPM包的工作，对于DEB包我们需要使用apt-cacher, 在ArchLinux上安装和配置apt-cacher:    

```
$ yaourt apt-cacher
$ sudo vim /etc/apt-cacher-ng/acng.conf
CacheDir: /home/nomodify/apt-cacher
Port: 3142

```
