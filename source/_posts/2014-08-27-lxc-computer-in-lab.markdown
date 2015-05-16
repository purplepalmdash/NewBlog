---
layout: post
title: "LXC Computer"
date: 2014-08-27 13:32
comments: true
categories: lxc
---
### Network Configuration
Add the rules in udevd:    

```
linux-:~ # cd /etc/udev/rules.d/
linux-:/etc/udev/rules.d # cat 10-network.rules
SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:22:22:22:22", NAME="eth1"
SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:22:22:22:22", NAME="eth0"
SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:22:22:22:22", NAME="eth2"
SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:22:22:22:22", NAME="eth3"

```
Add following network configuration:    

```
linux-:/etc/sysconfig # cd network/
linux-:/etc/sysconfig/network # cat ifcfg-eth0
# Loopback (lo) configuration
IPADDR=1xx.xx.xx.xxx
NETMASK=255.255.255.0
BROADCAST=1xx.xx.xx.xxx
STARTMODE=auto
USERCONTROL=yes
FIREWALL=no

```
Default Gateway Setup:    

```
linux-:~ # cat /etc/sysconfig/network/ifroute-br0
# Destination     Dummy/Gateway     Netmask            Device
#
default		xxx.xxx.xx.1	    255.255.255.255	br0

```
Restart computer then you got the fixed ip address in eth0.    
Add the default route so we could get outside.    

```
vim routes
xxx.xxx.xx.1 -eth0 
or manually: 
route add default gw xxx.xxx.xx.1 eth0

```

Bridge Networking Configuration:    

```
linux-:/etc/sysconfig/network # cat ifcfg-br0
STARTMODE='auto'
BOOTPROTO='static'
DNS1=xxx.xxx.xx.1
GATEWAY=xxx.xxx.xx.1
IPADDR=xxx.xxx.xx.59
NETMASK=255.255.255.0
ONBOOT=yes
USERCONTROL='no'
BRIDGE='yes'
BRIDGE_PORTS='eth0'
BRIDGE_AGEINGTIME='20'
BRIDGE_FORWARDDELAY='0'
BRIDGE_HELLOTIME='2'
BRIDGE_MAXAGE='20'
BRIDGE_PATHCOSTS='3'
BRIDGE_STP='on'
linux-:/etc/sysconfig/network # cat ifcfg-eth0
BOOTPROTO='static'
STARTMODE='ifplugd'
IFPLUGD_PRIORITY='1'
NAME = '1000 mBIT ETHERNET'
USERCTL=no


```
The route should changed to:     

```
route add default gw xxx.xxx.xx.1 br0

```

### LXC Install
Enable the free ways:    

```
ssh -C -L 127.0.0.1:9001:1xx.xxx.2xx:2xxxx root@1xx.xx.1xx.xxx

```
Use zypper to install the container.    

```
zypper search lxc
# zypper install lxc lxc-devel yast2-lxc libvirt-daemon-lxc libvirt-daemon-driver-lxc
# lxc-checkconfig 
# ls /usr/share/lxc/templates/

```
Yes we have the opensuse specified configuraton.    

Create The first Container:     

```
lxc-create -n ixxxxxSimulator1 -t /usr/share/lxc/templates/lxc-opensuse

```
List the installed Container:    

```
linux-:~ # lxc-ls
xxxxhxxSimulator1

```
Username and password are `root`.    

Start the lxc machine via:    

```
lxc-start -n xxxxxSimulator1

```

### LXC Configuration
No Network, Add it!    
First we remove the desktop kernel. and use the default kernel    

```
# uname -a
Linux XXXXSimulator1 3.11.6-4-desktop 
# zypper in kernel-default
# zypper rm kernel-desktop
# uname -a
Linux linux- 3.11.10-21-default

```

Enable the xfce4 for the default vnc server desktop:    

```
zypper in -t pattern xfce

```

Change the default lxc configuraiton of network:     

```
$ vim /var/lib/lxc/XXXXSimulator1/config
lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = br0
lxc.network.name = eth0

```
Now if you start the lxc container, the network eth0 will be automatically started.    

### LXC Expand 
Duplicate LXC Machine.     
This is strange when we directly call lxc-clone will cause failed silently:    

```
 # lxc-clone -o XXXXSimulator1 -n XXXXSimulator2
linux-:~ # echo $?
1

```
Then we use this:     

```
# bash /usr/bin/lxc-clone -o XXXXSimulator1 -n XXXXSimulator2
Tweaking configuration
Copying rootfs...
Updating rootfs...
'XXXXSimulator2' created
linux-:~ # lxc-ls
XXXXSimulator1  XXXXSimulator2

```
Change the XXXXSimulator2's configuration:    

```
$ vim /var/lib/lxc/XXXXSimulator2/config
lxc.network.ipv4 = xxx.xxx.xx.67

```
Now start the two LXC via:    

```
# lxc-start  -n XXXXSimulator2
# lxc-start  -n XXXXSimulator1
[Trusty@Linux01 ~]$ ping -c 1 xxx.xxx.xx.66
PING xxx.xxx.xx.66 (xxx.xxx.xx.66) 56(84) bytes of data.
64 bytes from xxx.xxx.xx.66: icmp_seq=1 ttl=64 time=1.50 ms

--- xxx.xxx.xx.66 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 1ms
rtt min/avg/max/mdev = 1.506/1.506/1.506/0.000 ms
[Trusty@Linux01 ~]$ ping -c 1 xxx.xxx.xx.67
PING xxx.xxx.xx.67 (xxx.xxx.xx.67) 56(84) bytes of data.
64 bytes from xxx.xxx.xx.67: icmp_seq=1 ttl=64 time=1.56 ms

--- xxx.xxx.xx.67 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 1ms
rtt min/avg/max/mdev = 1.567/1.567/1.567/0.000 ms

```

Later we could configure the LXC, to let the container start at bootup, Or control its behavior.    

### LXC Computer Configuration
The IP address and Default Gateway Configuration:    

```
lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = br0
lxc.network.name = eth0
lxc.network.ipv4 = xxx.xxx.xx.59/24
lxc.network.ipv4.gateway = xxx.xxx.xx.1

```
Then start the LXC Container, you will see the ip address/netmask already configured.    

### LXC Destroy
Destroyed the unused Container2:    

```
linux-:~ # lxc-ls
XXXXSimulator1  XXXXSimulator2
linux-:~ # lxc-destroy -n XXXXSimulator2
linux-:~ # lxc-ls
XXXXSimulator1

```

