---
layout: post
title: "OpenVSwitch and VXLAN How-to"
date: 2015-06-08 09:48:20 +0800
comments: true
categories: virtualization
---
Following records the steps for my setup for OpenVSwitch environment and configure VXLAN on it.     
### Preparation
I use two VMs for this experiment, created a new virtual network, it's 10.94.94.0/24, every vm machines adds into this network.   
VM1, VM2, both have 1G Memory. 1 Core.   
VM1: 10.94.94.11, VM2: 10.94.94.12.     

```
$ sudo apt-get update && sudo apt-get -y upgrade
$ sudo apt-get install build-essential$
$ sudo reboot
$ uname -a
$ uname -a
Linux OpenVSwitchVM1 3.13.0-24-generic #47-Ubuntu SMP Fri May 2 23:30:00 UTC 2014 x86_64 x86_64 x86_64 GNU/Linux
```     

### Generate DEB 
Following steps includes install dependencies, fetching source code, build, generate package, notice we use 2.3.0 version of the openvswitch.    

```
$ sudo apt-get install -y build-essential fakeroot debhelper \
                    autoconf automake bzip2 libssl-dev \
                    openssl graphviz python-all procps \
                    python-qt4 python-zopeinterface \
                    python-twisted-conch libtool
$ wget http://openvswitch.org/releases/openvswitch-2.3.0.tar.gz
$ tar xzvf openvswitch-2.3.0.tar.gz
$ cd openvsiwtch-2.3.0
$ DEB_BUILD_OPTIONS='parallel=8 nocheck' fakeroot debian/rules binary
$ cd ..
$ ls -al *.deb
openvswitch-common_2.3.0-1_amd64.deb         openvswitch-ipsec_2.3.0-1_amd64.deb   openvswitch-vtep_2.3.0-1_amd64.deb
openvswitch-datapath-dkms_2.3.0-1_all.deb    openvswitch-pki_2.3.0-1_all.deb       python-openvswitch_2.3.0-1_all.deb
openvswitch-datapath-source_2.3.0-1_all.deb  openvswitch-switch_2.3.0-1_amd64.deb
openvswitch-dbg_2.3.0-1_amd64.deb            openvswitch-test_2.3.0-1_all.deb

```
Also copy all of the deb files into another PC.   

### Installation
In two machines, do following steps for installing.    

```
$ sudo apt-get install -y bridge-utils
$ sudo dpkg -i openvswitch-common_2.3.1-1_amd64.deb \
         openvswitch-switch_2.3.1-1_amd64.deb
```

### VM Netorking Configuration
For VM1:    

```
root@OpenVSwitchVM1:~# ovs-vsctl add-br br0
root@OpenVSwitchVM1:~# ovs-vsctl add-br br1
# ovs-vsctl add-port br0 eth0
# ifconfig eth0 0 up
# ifconfig br0 10.94.94.11
# route add default gw 10.94.94.1 br0
# ifconfig br1 172.10.0.1

```

For VM2:     

```
# ovs-vsctl add-br br0
# ovs-vsctl add-br br1
# ovs-vsctl add-port br0 eth0
# ifconfig eth0 0 up && ifconfig br0 10.94.94.12
# route add default gw 10.94.94.1
# ifconfig br1 172.10.1.1
```

Ping each other, we could see br1 is not OK.     

### VXLAN Setup
On VM1, do following operation, to set the vx1:    

```
root@OpenVSwitchVM1:~# ovs-vsctl add-port br1 vx1 -- set interface vx1 type=vxlan options:remote_ip=10.94.94.12
root@OpenVSwitchVM1:~# ovs-vsctl show
a1e9afb6-345a-4f79-8e0b-131cd43cfb67
    Bridge "br0"
        Port "eth0"
            Interface "eth0"
        Port "br0"
            Interface "br0"
                type: internal
    Bridge "br1"
        Port "br1"
            Interface "br1"
                type: internal
        Port "vx1"
            Interface "vx1"
                type: vxlan
                options: {remote_ip="10.94.94.12"}
    ovs_version: "2.3.0"
```

On VM2, do following operation, to set vx1

```
root@OpenVSwitchVM2:~# ovs-vsctl add-port br1 vx1 -- set interface vx1 type=vxlan options:remote_ip=10.94.94.11
root@OpenVSwitchVM2:~# ovs-vsctl show
bce3f2b5-9b77-41dc-8130-b8922dd7ac9e
    Bridge "br1"
        Port "vx1"
            Interface "vx1"
                type: vxlan
                options: {remote_ip="10.94.94.11"}
        Port "br1"
            Interface "br1"
                type: internal
    Bridge "br0"
        Port "br0"
            Interface "br0"
                type: internal
        Port "eth0"
            Interface "eth0"
    ovs_version: "2.3.0"
```

So now you could ping each other via the br1 address.    

### Mirror Port
Do the following things for setting up the mirror port.    

```
#  modprobe dummy
#  ip link set up dummy0
root@OpenVSwitchVM1:~# ovs-vsctl add-port br1 dummy0
root@OpenVSwitchVM1:~# ovs-vsctl --id=@m create mirror name=mirror0 -- add bridge br1 mirrors @m
33931f5a-008f-44cf-abc6-38afb3062b5e
root@OpenVSwitchVM1:~# ovs-vsctl list port dummy0
_uuid               : 5f5fe675-b1ee-4acd-a0ab-f14e952d1603
bond_downdelay      : 0
bond_fake_iface     : false
bond_mode           : []
bond_updelay        : 0
external_ids        : {}
fake_bridge         : false
interfaces          : [a6fbabe9-790d-4be8-a362-b7cbdd46db89]
lacp                : []
mac                 : []
name                : "dummy0"
other_config        : {}
qos                 : []
statistics          : {}
status              : {}
tag                 : []
trunks              : []
vlan_mode           : []

```
