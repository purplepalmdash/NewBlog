---
layout: post
title: "Using Fuel For Deploying OpenStack"
date: 2015-04-15 18:47
comments: true
categories: virtualization
---
### Network Configuration
Fuel network configuration is listed as following pictures:     
PXE network, for using fuel controller to control all of the nodes, 10.20.0.0/24:    
![/images/2015_04_15_18_48_35_529x382.jpg](/images/2015_04_15_18_48_35_529x382.jpg)     
Public network, or floating ip network 172.16.0.0/24
![/images/2015_04_15_18_50_48_527x361.jpg](/images/2015_04_15_18_50_48_527x361.jpg)    
Admin network, 192.168.0.0/24:    
![/images/2015_04_15_18_51_47_533x329.jpg](/images/2015_04_15_18_51_47_533x329.jpg)    
### Fuel Controller Installation
Create a virtual machine, which have 2-Core, 3072MB Memory, and 100G Hard-disk, 3 ethernet port available for using, startup using the iso file, and then beging installing.     

