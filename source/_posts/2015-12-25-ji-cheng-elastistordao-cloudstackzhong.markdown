---
layout: post
title: "集成elastistor到CloudStack中"
date: 2015-12-25 15:43:34 +0800
comments: true
categories: virtualization
---
### 先决条件
Cloudstack版本， 4.5.2:    

![/images/2015_12_25_15_44_05_330x190.jpg](/images/2015_12_25_15_44_05_330x190.jpg)   

CloudByte Elastistor已经搭建好。    

下载Elastistor插件包:     

```
# wget www.cloudbyte.com/cbftp/cloudStack.zip
# unzip cloudStack.zip 
# ls
system.js	docs.js		install.sh
```

### 移动javascript文件
在安装插件前，移动下列文件:    

```
# mv /usr/share/cloudstack-management/webapps/client/scripts/system.js.gz \ 
/usr/share/cloudstack-management/webapps/client/
# mv /usr/share/cloudstack-management/webapps/client/scripts/docs.js.gz  \
/usr/share/cloudstack-management/webapps/client/
```

### 安装插件
安装步骤如下:    

```
[root@csmgmt ~]# chmod 777 install.sh 
[root@csmgmt ~]# ./install.sh 
creating a backup dir @ /usr/share/cloudstack-management/backup
taking backup of old js files : system.js and docs.js
copying cloudbyte given system.js and docs.js
restart cloudstack management server
Starting to configure CloudStack Management Server:
Configure sudoers ...         [OK]
Configure Firewall ...        [OK]
Configure CloudStack Management Server ...[OK]
CloudStack Management Server setup is Done!
```

### 编辑属性文件
添加下列定义到文件结尾:    

```
[root@csmgmt ~]# vim /usr/share/cloudstack-management/webapps/client/WEB-INF/classes/commands.properties 
        changeVolumeProperties=15
        listElastistorPool=15
        listElastistorVolume=15
        listElastistorInterface=15
```

### 添加API KEY
生成API KEY：   

![/images/2015_12_25_15_57_27_885x323.jpg](/images/2015_12_25_15_57_27_885x323.jpg)  

填入API KEY, 在Global Settings选项下搜索cloudbyte即可得到:    

![/images/2015_12_25_15_59_00_744x233.jpg](/images/2015_12_25_15_59_00_744x233.jpg)    

添加一个Domain:    

![/images/2015_12_25_16_02_54_388x251.jpg](/images/2015_12_25_16_02_54_388x251.jpg)    

![/images/2015_12_25_16_04_03_425x266.jpg](/images/2015_12_25_16_04_03_425x266.jpg)   

添加主存储，会出现问题，VSM可以创建成功，但是无法mount到NFS。登录到elastistor上，看不到
volume的创建。     
