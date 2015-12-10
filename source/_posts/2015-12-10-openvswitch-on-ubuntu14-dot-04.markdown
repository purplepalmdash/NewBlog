---
layout: post
title: "OpenVswitch On Ubuntu14.04"
date: 2015-12-10 15:33:24 +0800
comments: true
categories: Virtualization
---
### Installation
Install openvswitch via:    

```
# apt-get update
# apt-get install -y openvswitch-common openvswitch-switch
```

List the installed module via:     

```
# lsmod | grep open
openvswitch            66901  0 
gre                    13808  1 openvswitch
vxlan                  37619  1 openvswitch
libcrc32c              12644  1 openvswitch
# ovs-vsctl --version
ovs-vsctl (Open vSwitch) 2.0.2
Compiled May 13 2015 18:49:53
```

### Configuration
Edit the configuration of the networking:    

```
$ sudo vim /etc/network/interfaces
###########################################
## By using openVswitch, we enabled the following
###########################################
auto ovsbr0
iface ovsbr0 inet static
address 192.168.1.xx
netmask 255.255.0.0
gateway 192.168.1.xx
dns-nameservers 223.5.5.5 180.76.76.76
```

Now configure the ovs-switched bridge:    

```
# ovs-vsctl add-br ovsbr0
# ovs-vsctl list-br
ovsbr0
# ovs-vsctl add-port ovsbr0 eth0 && reboot
```
Now restart the computer you will get the ovs-bridged network running.    

### Bridged With VLAN
ToBeAdded
