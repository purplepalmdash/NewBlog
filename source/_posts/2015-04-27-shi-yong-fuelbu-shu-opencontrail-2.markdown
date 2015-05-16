---
layout: post
title: "使用Fuel部署OpenContrail(2)"
date: 2015-04-27 17:04
comments: true
categories: Virtualization
---
本节在前面部署完Fuel 控制节点的基础上，接着部署一个OpenStack HA环境，并准备好OpenContrail的三个部署节点。     
### 节点初始化准备
所有加入到Fuel控制节点里的机器，在加入前都需要进行初始化配置，而后才可以被Fuel所识别.    
在所有配置好的机器里，点击Details-> Boot Options, 设置如下：    
![/images/2015_04_27_17_14_26_532x372.jpg](/images/2015_04_27_17_14_26_532x372.jpg)    
因为第一次启动的时候，磁盘里是没有内容的，机器会自动从第二选项启动(PXE). 机器将自动侦测5个网段上的PXE Server， 因为Fuel Controller接管了10.20.0.0/24 网段上的PXE请求，它将会把机器从PXE变成可部署的状态。        

### OpenStack HA环境创建
创建一个OpenStack HA环境，如下步骤，因为是HA，所以需要至少三个OpenStack Controller节点和一个OpenStack Compute节点。    
点击界面里的New OpenStack Environment, 在弹出的窗口中，命名需要部署的HA环境名，并选择部署所需要的镜像，这里我们选择Ubuntu作为部署OpenStack的基础镜像。    
![/images/2015_04_27_17_18_22_680x435.jpg](/images/2015_04_27_17_18_22_680x435.jpg)    
点击下一步，选择HA模式：    
![/images/2015_04_27_17_20_13_681x427.jpg](/images/2015_04_27_17_20_13_681x427.jpg)   
点击下一步，选择计算节点模式，这里选择qemu或者kvm问题都不大，不要选vcenter就是了:     
![/images/2015_04_27_17_21_48_683x435.jpg](/images/2015_04_27_17_21_48_683x435.jpg)     
点击下一步，进入到网络模式选择，选择Legacy Network(nova-network), 先部署成这种形式，接下来我们会使用neutron和contrail的组合重新规划网络:     
![/images/2015_04_27_17_23_03_682x428.jpg](/images/2015_04_27_17_23_03_682x428.jpg)   
点击下一步，Storage Backend，因为我们不打算引入任何存储节点，这里选择Default，直接进入下一步， Additional Service里我们也不打算启任何额外的服务，一路Next直到最后Create出整个OpenStack环境。    
 
依次创建另一个OpenStack HA环境，用来部署三台Contrail Controller的节点机.    
### OpenStack环境网络
Fuel默认的网络配置会激活三个物理端口，第一个端口接入PXE网络，第二个接入Public网络，第三个上启三个VLAN，分别接入到Management/Storage/Private网络。我认为VLAN的配置增加了配置和部署的复杂度，更改为五个物理网络，分别使用我们在Virt-Manager中创建出的五个物理网卡接入。更改方法如下:     
点击Network, 更改Management下的CIDR，手动填入10.55.55.0/24，然后去掉前面的Use VLAN Tag:        
![/images/2015_04_27_17_32_09_465x466.jpg](/images/2015_04_27_17_32_09_465x466.jpg) 

依次修改Storage网络和Private网络，更改完毕后，你的配置应该看起来是这样的:      
![/images/2015_04_27_17_34_33_387x388.jpg](/images/2015_04_27_17_34_33_387x388.jpg)    

对于Public网络我们不需要有任何修改，保持172.16网段的配置即可。   

确认Network的配置为FlatDHCP Manager:     
![/images/2015_04_27_17_35_37_391x149.jpg](/images/2015_04_27_17_35_37_391x149.jpg)    

### 建立OpenStack HA环境 
经PXE启动的虚拟机会把自己加入到"Unallocated Nodes"的队列里，在创建好的环境里，点击Node后，可以看到Fuel对角色的分配，添加一个OpenStack Controller的步骤如下：    
在Assign Roles里选择"Controller", 下面的备选节点里选择一台机器后，Apply Changes按钮会变绿，点击进入下一步.     
![/images/2015_04_27_17_42_34_800x530.jpg](/images/2015_04_27_17_42_34_800x530.jpg)    
在切换到的页面中，点击节点最右边的齿轮，配置该节点机器的网络、存储等，这里只配置网络：    
![/images/2015_04_27_17_44_05_797x203.jpg](/images/2015_04_27_17_44_05_797x203.jpg)    
点击Configure Network配置网络:     
![/images/2015_04_27_17_45_19_448x349.jpg](/images/2015_04_27_17_45_19_448x349.jpg)    
可以看到前4个节点已经配置好了，我们只需要把VM(Fix)这个框从eth0拖动到eth4即可:      
![/images/2015_04_27_17_46_34_524x342.jpg](/images/2015_04_27_17_46_34_524x342.jpg)    
添加完毕后，网络配置应该如下图:    
![/images/2015_04_27_17_48_22_489x436.jpg](/images/2015_04_27_17_48_22_489x436.jpg)   
点击Apply后，保存当前配置，然后点击Back to node list可以顺次添加其他节点。    

下面是一个添加好的OpenStack HA环境示例(3 Controller + 2 Compute):     
![/images/2015_04_27_17_57_01_948x432.jpg](/images/2015_04_27_17_57_01_948x432.jpg)    

这里要注意，因为我们要启用嵌套虚拟化，所以确保Compute节点是把Host CPU Configuration下发了的那台。   
添加完三个OpenStack Controller节点和一个OpenStack Compute节点后，就可以点击Deploy Changes开始部署了。整个部署的过程至少需要1个小时，取决于机器配置和磁盘读写快慢。      

部署完毕后，Fuel会弹出提示信息，并给出可访问OpenStack HA Horizon界面的URL。    

### 准备Contrail部署节点
在OpenStack HA节点部署的同时，我们可以准备好Contrail部署节点。    
同样创建出一个新的OpenStack HA部署环境，记住我们不能在已有的OpenStack HA环境里添加节点机，因为那样部署出来的节点机都会带上OpenStack的一些包，我们需要一个纯净的Ubuntu环境进行Contrail组件的配置。   
同样添加3个Compute节点，进行同样的网络配置，添加完节点后，Deploy Changes按钮是不能被点下的，因为我们的环境里没有OpenStack Controller. 一个环境示例如下:    
![/images/2015_04_27_17_59_13_837x489.jpg](/images/2015_04_27_17_59_13_837x489.jpg)    

我们需要登录到Fuel Controller的终端，就是10.20.0.2那台机器(用户名root,密码r00tme)，手动对添加的三个Contrail节点进行provision:     

```
# fuel --env <ENVIRONMENT_ID> node --list
# fuel node --node-id <NODE1_ID>,<NODE2_ID>,<NODE3_ID> --env-id <ENVIRONMENT_ID> --provision

```
如何得到当前的ENVIRONMENT_ID, 下面提供了一个例子:     

```
[root@fuel ~]# fuel --env environment
id | status      | name                              | mode       | release_id | changes                                                                                                                                                               | pending_release_id
---|-------------|-----------------------------------|------------|------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------
36 | operational | JunoOpenStack                     | multinode  | 2          | []                                       
[root@fuel ~]# fuel --env 36 node --list
id | status | name             | cluster | ip        | mac               | roles      | pending_roles | online | group_id
---|--------|------------------|---------|-----------|-------------------|------------|---------------|--------|---------
3  | ready  | Untitled (e5:f2) | 36      | 10.20.0.3 | da:98:96:c5:c3:4b | compute    |               | False  | 36      
4  | ready  | Untitled (71:15) | 36      | 10.20.0.4 | 1a:ff:37:1f:26:44 | controller |               | False  | 36  
[root@fuel ~]# fuel node --node-id 3 --env-id 36 --provision2

```
同样需要大约30分钟时间用来在三台Contrail Controller的节点机上部署完可用的Ubuntu系统，部署完毕后，node界面上可以看到绿色的小字"ubuntu installed".   

这一节我们通过Fuel部署完毕OpenStack HA, 并准备了用于后续部署OpenContrail的三台Contrail Controller节点。接下来我们可以进入到OpenStack和OpenContrail的集成了。     
