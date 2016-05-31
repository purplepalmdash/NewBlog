---
layout: post
title: "不同桌面环境占用内存/CPU对比"
date: 2016-05-31 09:25:38 +0800
comments: true
categories: Linux
---
对比xfce4, lxde, gnome, mate等桌面环境占用内存/CPU对比

### 先决条件 
使用vagrant的镜像(ubuntu14.04):    

```
$ vagrant box list
ubuntu1404                                   (virtualbox, 0)
```
每一个桌面环境的验证如下:    

```
$ vagrant init ubuntu1404
$ vim Vagrantfile
  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
  #  vb.gui = true
  
    # Customize the amount of memory on the VM:
    vb.memory = "1024"
  end
$ vagrant up
```

### 基础镜像占用内存
用`free -m`来查看系统运行时所占用内存：    

![/images/2016_05_31_09_42_54_688x111.jpg](/images/2016_05_31_09_42_54_688x111.jpg)     


### xfce4(xubuntu)
安装:    

```
$ sudo apt-get update
$ sudo apt-get install xubuntu-desktop
```
启动xfce4桌面后，内存占用结果为：    

![/images/2016_05_31_09_57_44_483x164.jpg](/images/2016_05_31_09_57_44_483x164.jpg)     

### lxde(lubuntu)
安装:    

```
$ sudo apt-get update
$ sudo apt-get install -y lubuntu-desktop
```

启动lxde后，内存占用为:     

![/images/2016_05_31_10_07_46_458x84.jpg](/images/2016_05_31_10_07_46_458x84.jpg)     

### gnome(gnome-session-fallback)
安装:     

```
$ sudo apt-get update; sudo apt-get install gnome-session-fallback
$ sudo apt-get install -y gdm xterm
```

启动gnome-session-fallback后，内存占用为:      

![/images/2016_05_31_10_22_08_490x185.jpg](/images/2016_05_31_10_22_08_490x185.jpg)    

### unity
安装:     

```
$ sudo apt-get update && sudo apt-get install -y ubuntu-desktop
```

启动unity后，内存占用为:      

![/images/2016_05_31_10_26_22_553x168.jpg](/images/2016_05_31_10_26_22_553x168.jpg)      

### mate
安装:     

```
$ sudo apt-add-repository ppa:ubuntu-mate-dev/ppa
$ sudo apt-add-repository ppa:ubuntu-mate-dev/trusty-mate
$ sudo apt-get update && sudo apt-get upgrade
$ sudo apt-get install --no-install-recommends ubuntu-mate-core ubuntu-mate-desktop
```

启动mate后，内存占用为:    

![/images/2016_05_31_10_50_58_486x148.jpg](/images/2016_05_31_10_50_58_486x148.jpg)    

### KDE
安装:     

```
$ sudo apt-get update && sudo apt-get install -y kubuntu-desktop
```

内存占用:    

![/images/2016_05_31_11_06_50_487x108.jpg](/images/2016_05_31_11_06_50_487x108.jpg)    

### 对比
统计结果:     

![/images/2016_05_31_11_08_35_342x269.jpg](/images/2016_05_31_11_08_35_342x269.jpg)     

图例:   

![/images/2016_05_31_11_10_32_896x593.jpg](/images/2016_05_31_11_10_32_896x593.jpg)      
