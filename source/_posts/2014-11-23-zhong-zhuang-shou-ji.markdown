---
layout: post
title: "重装手记"
date: 2014-11-23 10:07
comments: true
categories: tips
---
昨晚的安装还是没能解决问题，所以今天重新来一次。      

### 安装步骤
1\.  插入Yosemite USB安装盘，选择"Ignore caches and inject kext"后按回车，进入到Yosemite安装界面。这时候的语言界面是意大利语的。分区选择Utility-> Utility Disco, 点击磁盘，按Inizilalizza， 输入Name后按Inizializza. 再一次确认也是Inizilalizza. 分区完毕后点x返回到安装界面，点击Continua-> Continua-> Accetta后选择Hard磁盘, Continua. 这时弹出拷贝窗口，需要等待大概15分钟时间用于拷贝/安装到磁盘。安装完毕后会自动重启。        

2\. 重启后需要选择"Boot Mac OS X from Hard", 空格后选择"Ignore caches and inject kext" 后回车，这时会进入到一个配置界面。首选选择时区，点击Mostra tuite后选择你要的时区后, Continua, 然后选择键盘布局，USA, Continua, 网络配置选择"II mio computer non si connette a Internet", Continua, Continua, 而后选择Non trasferrie informazioni adesso, Continua, Accetto, Accetta, 接着输入用户名/密码， Continua, 再一次Continua后进入Configuro iL Mac界面后，登录成功。    

3\. 在登录后的界面里，首先安装Clover到系统硬盘Hard,这样下一次我们就可以不用插入优盘以进行引导了。Clover安装时选择Install in UEFI和Drivers64UEFI。而后用UEFI Mount加载上系统真正的UEFI分区后，把根目录下的EFI目录全盘拷贝到系统UEFI分区下。同时使用KextDrop.dmg drop同用的Kext到系统。重启。       

4\. Drop Yosemite自己的驱动后，重启。这时候的声卡，USB, 蓝牙等应该都已经驱动上了。由于我们使用了修改过的Display驱动，DP口现在也应该是好的。开始安装有线/无线驱动。安装完毕后系统自动要求重启。    

5\. 重启完毕后可以直接链入网络，为了可以访问App Store， 删除掉系统里所有网络配置，删除掉/Library/Preferences/SystemConfiguration/NetworkInterfaces.plist, 重启。这将使得我们手动配置网卡的build-in模式。                   

6\. 手动添加网络，打开App Store，尝试安装一个软件，看是否如愿，如果OK，那么恭喜你。如果不OK，接着走下一步。我这里出现的错误是"Your device or computer could not be verified, Contact support for assistance."   下载NullEthernet包，drop之。并使用MaciASL, Apply patch.txt. 完成这些后重启。    

7\. 重启后依然无法访问，吃欧冠内心删除所有的网卡驱动，重新删除/L/P/S/NetworkInterfaces.plist, 重启。重新添加USB网卡，访问App Store. 好了，现在你可以访问，享受之。    

### 可能存在的问题
插入USB无线网卡可能会造成系统不稳定。譬如蓝牙丢失之类。这和驱动的稳定性有关系。所以在我的SurfacePro上我打算采用不稳定的驱动，我会采用一个便携式路由器把无线转成有线的功能。     
