---
layout: post
title: "XenServer6.2切换管理端口"
date: 2016-03-24 17:28:55 +0800
comments: true
categories: Virtualization
---
默认安装完的XenServer，不能找到eth1, 用以下命令找到eth1:     

```
[root@csagentv1 ~]# xe pif-list
uuid ( RO)                  : cd4409d4-b2b8-543c-ea9c-35170673e924
                device ( RO): eth0
    currently-attached ( RO): true
                  VLAN ( RO): -1
          network-uuid ( RO): 597114f0-e71a-34fe-d6a2-230cc75e085a


[root@csagentv1 ~]#  xe host-list
uuid ( RO)                : 367ebe92-0634-41a8-825a-cd23184824ea
          name-label ( RW): csagentv1
    name-description ( RW): Default install of XenServer


[root@csagentv1 ~]# xe pif-scan host-uuid=367ebe92-0634-41a8-825a-cd23184824ea
[root@csagentv1 ~]# xe pif-list
uuid ( RO)                  : 3f6e551b-993e-0a3d-96b6-0f0d172f867f
                device ( RO): eth1
    currently-attached ( RO): false
                  VLAN ( RO): -1
          network-uuid ( RO): 1ff03ece-8b93-b231-ac2d-679d035422da


uuid ( RO)                  : cd4409d4-b2b8-543c-ea9c-35170673e924
                device ( RO): eth0
    currently-attached ( RO): true
                  VLAN ( RO): -1
          network-uuid ( RO): 597114f0-e71a-34fe-d6a2-230cc75e085a
```

在Console上可以看到管理端口:     

![/images/2016_03_24_17_33_06_659x355.jpg](/images/2016_03_24_17_33_06_659x355.jpg)     

命令:    

```
[root@csagentv1 ~]# xe host-management-disable
[root@csagentv1 ~]# xe pif-reconfigure-ip uuid=3f6e551b-993e-0a3d-96b6-0f0d172f867f mode=static IP=192.168.56.3 netmask=255.255.255.0 gateway=192.168.56.1 DNS=180.76.76.76
[root@csagentv1 ~]# xe pif-list params=uuid,device,MAC
uuid ( RO)      : 3f6e551b-993e-0a3d-96b6-0f0d172f867f
    device ( RO): eth1
       MAC ( RO): 08:00:27:b2:9d:5c


uuid ( RO)      : cd4409d4-b2b8-543c-ea9c-35170673e924
    device ( RO): eth0
       MAC ( RO): 08:00:27:f7:38:0b
[root@csagentv1 ~]# xe host-management-reconfigure pif-uuid=3f6e551b-993e-0a3d-96b6-0f0d172f867f
```

更改成功后，可以看到现在管理端口已经配置为eth1了:    
![/images/2016_03_24_17_39_08_653x397.jpg](/images/2016_03_24_17_39_08_653x397.jpg)    

Tips:   

View eth1 pif:   

```
$ xe pif-list device=eth1 params=uuid --minimal
```
