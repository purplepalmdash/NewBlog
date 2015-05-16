---
layout: post
title: "Libvirt Network Configuration"
date: 2015-02-15 22:52
comments: true
categories: virtualization
---
Since I want to use bridge network in libvirt, while the standard bridge networking is not available for me to use, so following tips is for creating and managing the networking.    
### Enable Bridge
In host machine(OpenSuse), create bridge via:    

```
$ sudo brctl addbr br0
$ sudo brctl addif br0 eth0 

```
This will add eth0 to bridge 0, while in startup file of OpenSuse we will do following:    

```
# pwd
/etc/sysconfig/network
# cat ifcfg-eth0 
BOOTPROTO='static'
STARTMODE='ifplugd'
IFPLUGD_PRIORITY='1'
NAME='RTL8111/8168B PCI Express Gigabit Ethernet controller'
USERCONTROL='no' 
# cat ifcfg-br0 
BOOTPROTO='static'
STARTMODE='auto'
IPADDR='192.168.0.xxx/24'
NAME='Bridge For Virtualization'
BRIDGE='yes'
BRIDGE_PORTS='eth0'
BRIDGE_FORWARDDELAY='0'

```
So next time reboot you will see br0 hold the address of `192.168.0.xxx`, this is the bridge port we have.    
### Virtual Machine Configuration
First list all of the virtual machine we have

```
$ sudo virsh list --all
 Id    Name                           State
----------------------------------------------------
 2     Ubuntu12043                    running
 -     OpenContrail                   shut off

```
Edit the one we want to edit via:    

```
$ sudo virsh edit Ubuntu12043
    <interface type='bridge'>
      <mac address='24:42:53:21:52:49'/>
      <source bridge='br0'/>
      <model type='virtio'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
    </interface>

```
So next time when you boot-up the machine, it will have the physical network which connecting to br0.    
### Configure route
In virtual machine, give the fixed ip address via:    

```
$ sudo ifconfig eth0 192.168.188.188
$ sudo ip route add 192.168.0.0/24 dev eth0
$ sudo route add default gw 192.168.0.xxx
$ sudo route -n
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface                                                                 
0.0.0.0         192.168.0.119   0.0.0.0         UG    0      0        0 eth0                                                                  
192.168.0.0     0.0.0.0         255.255.255.0   U     0      0        0 eth0                                                                  
192.168.188.0   0.0.0.0         255.255.255.0   U     0      0        0 eth0   

```
We want make it permanent via:    
First make the permanent ip address:    

```
# cat /etc/network/interfaces 
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet static
        address 192.168.188.188
        netmask 255.255.255.0

```
Second we want to configure the route:    

```
$ tail  /etc/rc.local
ip route add 192.168.0.0/24 dev eth0
route add default gw 192.168.0.xxx
echo "nameserver 114.114.114.114">>/etc/resolv.conf

```
This will set the route and the default gateway of your device, also the nameserver will be set.     
But while in the host machine, you will add following iptables rules:    

```
# ip route add 192.168.188.0/24 dev br0
# iptables -t nat -A POSTROUTING -s 192.168.188.0/24 -j SNAT --to 192.168.0.xxx
# iptables -A FORWARD -s 192.168.188.188 -j ACCEPT

```
The iptables rules should be saved via `iptables-save`, while the route rules should be added into following file:    

```
$  cat /etc/rc.d/after.local 
ip route add 192.168.188.0/24 dev br0                

```
Now reboot the host machine, you route configuration will be saved.    

