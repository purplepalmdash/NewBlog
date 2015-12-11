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
Add/Remove port of the ovs-bridged:    

```
# ovs-vsctl add-port ovsbr0 tap0 tag=22
# ovs-vsctl show
901c2b29-0764-4370-8d06-168b18339236
    Bridge "ovsbr0"
        Port "eth0"
            Interface "eth0"
        Port "tap0"
            tag: 22
            Interface "tap0"
        Port "ovsbr0"
            Interface "ovsbr0"
                type: internal
    ovs_version: "2.0.2"
# ovs-vsctl del-port ovsbr0 tap0
```
If you want to remove the tag, then:    

```
ovs-vsctl set port vnet0 tag=100
ovs-vsctl remove port vnet0 tag 100
```

### VLAN / OpenVswitch/ virt-manager
Dumpxml will displayed as following:    

```
    <interface type='bridge'>
      <mac address='52:54:00:0e:6b:d1'/>
      <source bridge='ovsbr0'/>
      <vlan trunk='yes'>
        <tag id='22' nativeMode='untagged'/>
      </vlan>
      <virtualport type='openvswitch'>
        <parameters interfaceid='d5b7b981-8998-44c0-9344-0ade6b69ec1f'/>
      </virtualport>
      <target dev='vnet0'/>
      <model type='virtio'/>
      <alias name='net0'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
    </interface>
    <interface type='bridge'>
      <mac address='52:54:00:3c:c9:24'/>
      <source bridge='ovsbr0'/>
      <vlan trunk='yes'>
        <tag id='100' nativeMode='untagged'/>
      </vlan>
      <virtualport type='openvswitch'>
        <parameters interfaceid='06898d54-c0da-48c6-8b01-3307e70b995a'/>
      </virtualport>
      <target dev='vnet1'/>
      <model type='virtio'/>
      <alias name='net1'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x04' function='0x0'/>
    </interface>
    <interface type='bridge'>
      <mac address='52:54:00:7b:e7:b0'/>
      <source bridge='ovsbr0'/>
      <virtualport type='openvswitch'>
        <parameters interfaceid='303c1f65-23ff-4017-93ba-f196ca1d05fb'/>
      </virtualport>
      <target dev='vnet2'/>
      <model type='virtio'/>
      <alias name='net2'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x05' function='0x0'/>
    </interface>
```
