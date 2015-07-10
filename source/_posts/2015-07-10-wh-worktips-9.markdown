---
layout: post
title: "WH Worktips(9)"
date: 2015-07-10 20:21:13 +0800
comments: true
categories: Virtualization
---
### Cobbler In Non-DHCP Server Networking
Sometimes you want to deploy system with cobbler server,  in some restricted network which dhcp service is not allowed(considering broadcasting storm, security, etc.) Following are the steps of how-to:    
Change Cobbler server setting:    

```
$ sudo vim /etc/cobbler/settings
manage_dhcp: 0
$ sudo cobbler sync
$ sudo service dhcpd stop
```

Add the node definition in cobbler(useless):     

```
# cobbler system add --name=node2 --profile=CentOS6.5-x86_64 --mac=52:54:00:71:59:64 --interface=eth0 --static=1 --ip-address=10.47.58.3 --dns-name=node2 --gateway=10.47.58.1
```
Now bootup your newly added computer with PXE, hit `ctrl+B` once you see the bios hint.     

```
iPXE> config net0
```
hit `ctrl+B` should be like in following image:    
![/images/2015_07_10_20_31_15_761x354.jpg](/images/2015_07_10_20_31_15_761x354.jpg)    

![/images/2015_07_10_20_26_29_656x381.jpg](/images/2015_07_10_20_26_29_656x381.jpg)    
Setting like following:    
![/images/2015_07_10_20_33_15_676x453.jpg](/images/2015_07_10_20_33_15_676x453.jpg)    
Hit `Ctrl+x` for saving the settings and continue to set:    

```
iPXE> imgfetch -n img tftp://10.47.58.2/pxelinux.0
iPXE> imgload img
iPXE> boot
```

Now begin to install, you will met nework configuration fail issue:    
![/images/2015_07_10_20_39_30_580x240.jpg](/images/2015_07_10_20_39_30_580x240.jpg)    

Hit Cancel, manually set up the network, first select installation method:   
![/images/2015_07_10_20_41_12_323x273.jpg](/images/2015_07_10_20_41_12_323x273.jpg)    

Configure TCP/IP:    
![/images/2015_07_10_20_42_14_430x286.jpg](/images/2015_07_10_20_42_14_430x286.jpg)    
Configure IP address/gateway/dns/netmask:    
![/images/2015_07_10_20_43_08_600x280.jpg](/images/2015_07_10_20_43_08_600x280.jpg)    
Now configure the installation setting, you could find it in your own ks configuration file:    
![/images/2015_07_10_20_44_22_585x334.jpg](/images/2015_07_10_20_44_22_585x334.jpg)    

Continue to install, they are the same as you did before.    

### Cobbler in the existing DHCP enabled Network
Since the dhcp server is available in the network, simply press `ctrl+B` to enter the pxe boot menu and set the `next_server` to `10.47.58.2`, then:    


```
iPXE> imgfetch -n img tftp://10.47.58.2/pxelinux.0
iPXE> imgload img
iPXE> boot
```
Now select whichever you want to deploy, your configuration will be deployed ASAP.   
