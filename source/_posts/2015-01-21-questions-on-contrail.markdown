---
layout: post
title: "Questions On Contrail"
date: 2015-01-21 21:43
comments: true
categories: SDN
---
Following records my questions on Contrail.    
### What is L3 OverLay?
对于大二层的互通，还有一种简单有效的方法就是vpn，vpn可以工作在二层（如openvpn中的tap模式，左右两边的子网可以相同，但IP肯定不能同，相当于bridge模式），也可以工作在三层（如openvpn中的tun模式, 要求左右两边子网不同）。IPSec只是一种加密模式，L2TP才是二层的vpn接入层，所以L2TP+IPSec肯定可以实现openvpn的tap模式，但是strongswan因为是三层的vpn应该不行。        


More detailed info could be found at:    
[http://blog.csdn.net/quqi99/article/details/11778413](http://blog.csdn.net/quqi99/article/details/11778413)    

### MPLS? 
MPLS(Multiprotocol Label Switching, 多协议标记交换)使用标签(Label)进行转发，一个标签是一个短的、长度固定的数值，由报文的头部携带，不含拓扑信息，只有局部意义。MPLS包头包含20比特的标签，3比特的EXP(通常用作Cos)，1比特的S，用于标识此标签是否为最底层标签，8比特的TTL。    
More detailed infos here:    
[http://www.net130.com/netbass/VPN/v111301.htm](http://www.net130.com/netbass/VPN/v111301.htm)    

### GRE?
（GRE: Generic Routing Encapsulation）    
通用路由封装 （GRE）定义了在任意一种网络层协议上封装任意一个其它网络层协议的协议。      
More detailed info could be found here:    
[http://baike.baidu.com/view/3871502.htm](http://baike.baidu.com/view/3871502.htm)    
#### MPLS Over GRE? 
 MPLS是多协议标签交换的简称，它用短而定长的标签来封装网络层分组。MPLS最初是为提高路由器的转发速度而提出一个协议。    
GRE协议是对某些网络层协议的数据报进行封装，使这些被封装的数据报能够在另一个网络层协议中传输。GRE是VPN的第三层隧道协议，在协议层之间采用了一种被称之为Tunnel的技术。    
MPLS在VPN中的应用，用MPLS为转发通道运行私网流量，使一个运营商的网络可以同时支撑多个不同客户的IP VPN，这样就要求运营商的网络全程支持MPLS转发。但是在实际运用中，有时由于网络规划的原因，运营商网络的中间设备并不支持MPLS功能，而基本的BGP/MPLS VPN是要求所用到的运营商设备全程支持MPLS功能才可以，这样采用基本的BGP/MPLS VPN方法就行不通了，此时GRE的应用很好的解决了这个问题，只需要运营商边缘设备支持MPLS转发就能实现功能。而且GRE只需要保证两端网络类型相同，中间可以穿越其他类型的网络，也降低了对运营商网络的要求。     

More detailed info could be found here:    
[http://blog.sina.com.cn/s/blog_6dc951ef01015bpm.html](http://blog.sina.com.cn/s/blog_6dc951ef01015bpm.html)    

### L3 VPN?
Layer 3, or VPRN (virtual private routed network), utilizes layer 3 VRF (VPN/virtual routing and forwarding) to segment routing tables for each “customer” utilizing the service. The customer peers with the service provider router and the two exchange routes, which are placed into a routing table specific to the customer. Multiprotocol BGP (MP-BGP) is required in the cloud to utilize the service, which increases complexity of design and implementation. L3 VPNs are typically not deployed on utility networks due to their complexity; however, a L3 VPN could be used to route traffic between corporate or datacenter locations.    

[http://en.wikipedia.org/wiki/MPLS_VPN#Layer_3_VPN_.28VPRN.29](http://en.wikipedia.org/wiki/MPLS_VPN#Layer_3_VPN_.28VPRN.29)        

[http://www.doc88.com/p-0903761953194.html](http://www.doc88.com/p-0903761953194.html)     

### EVPN?

Fuck, 
### VXLAN? 
vxlan(virtual Extensible LAN)虚拟可扩展局域网，是一种overlay的网络技术，使用MAC in UDP的方法进 行封装，共50字节的封装报文头。具体的报文格式如下：     
![/images/vxlan.png](/images/vxlan.png)    
More detailed info could be found here:    
[http://www.huawei.com/ecommunity/bbs/10239835.html](http://www.huawei.com/ecommunity/bbs/10239835.html)    
### MPLS Over UDP? 

### MPLS Over UDP(L2/L3 OverLay)?

### L3 Unicast?

### L2 Unicast?

### L2 Multicaset? 

### Multicast Tree?

### BUM Traffic?

### Overlay vs UnderLay? 
Answer comes here:    
SDN究竟要不要管物理交换机？    
[http://www.jianshu.com/p/4c2448e201a2](http://www.jianshu.com/p/4c2448e201a2)    
