---
layout: post
title: "XenServer Tips"
date: 2015-06-16 14:52:20 +0800
comments: true
categories: Virtualization
---
Recently I want to research desktop virtualization on Xen, so this blog records all of the tips for Xen Hypervisor related info.     
### Nested Virtualization
I place 4 core(Copy Host Configuration on CPU parameter), but the XenServer refuse to start, by using a none-hosted-configuration CPU configuration, it will fail on starting the machine, So I choose to install xen hypervisor on Ubuntu14.04.     

### Ubuntu and Xen
Install via:    

```
$ sudo apt-get install xen-hypervisor-amd64
$ sudo reboot
```
The Ubuntu will automatically choose xen for startup, so verify it via:    

```
$ sudo xl list
Name                                        ID   Mem VCPUs      State   Time(s)
Domain-0                                     0  7832     4     r-----      72.8
```

### Networking
Since the network is pretty complicated on my own machine, I decide to use openVSwitch for managing my own networking.   

```
$ sudo apt-get install -y openvswitch-switch
```
Configuration of the networking:    

```
$ cat /etc/network/interfaces
###########################################
## By using openVswitch, we enabled the following
###########################################
allow-hotplug ovsbr0
iface ovsbr0 inet static
address 192.168.0.119
netmask 255.255.0.0
gateway 192.168.0.176
dns-nameservers 114.114.114.114
dns-nameservers 180.76.76.76

$ sudo ovs-vsctl add-br ovsbr0
$ sudo ovs-vsctl set Bridge ovsbr0 stp_enable=false other_config:stp-max-age=6 other_config:stp-forward-delay=4
$ sudo ovs-vsctl list Bridge
$ sudo ovs-vsctl add-port ovsbr0 eth0
```

Disable the netfilter on all bridges:     

```
$ sudo vi /etc/sysctl.conf

net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0

$ sudo sysctl -p /etc/sysctl.conf
# Note: These settings are created in /proc/sys/net. The bridge folder only appears to be created after first creating a bridge with the ''brctl' command.
```

### Administrator Tools

```
$ sudo apt-get install virt-manager
$ sudo apt-get install xen-tools
```

### Connect with virt-manager
Change following parameters and re-connect again.    

```
# vim /etc/xen/xend-config.sxp 
     xend-unix-server yes
     xend-unix-path /var/lib/xend/xend-socket
# service libvirt-bin restart
libvirt-bin stop/waiting
libvirt-bin start/running, process 5345
# service xen restart
 * Restarting Xen daemons                                                                                                             ^[[A                                                                                                                           [ OK ]
# service xendomains restart

```


```
$ sudo virt-install --connect=xen:/// --name u14.04 --ram 1024 --disk u14.04.img,size=4 --location http://ftp.ubuntu.com/ubuntu/dists/trusty/main/installer-amd64/


# http://ftp.ubuntu.com/ubuntu/dists/trusty/main/installer-amd64/
```
