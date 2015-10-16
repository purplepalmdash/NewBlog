---
layout: post
title: "Use OpenWRT Router For Lan Forwarding"
date: 2015-10-15 11:50:28 +0800
comments: true
categories: Linux
---
### USB Ethernet
Insert the USB Ethernet Dongle into the Ubuntu14.04, it will be automatically
recognized and initialized.    

```
$ dmesg | tail 
    [10323.307662] asix 2-2.2:1.0 eth1: register 'asix' at usb-0000:00:1d.7-2.2, ASIX
    AX88772B USB 2.0 Ethernet, 84:xx:xx:xx:xx
    [10323.307704] usbcore: registered new interface driver asix
    [10324.285425] IPv6: ADDRCONF(NETDEV_UP): eth1: link is not ready
$ ifconfig eth1
    eth1      Link encap:Ethernet  HWaddr 84:xx:xx:xx:
```

Be care to see the udev rules definition:    

```
$ cat /etc/udev/rules.d/70-persistent-net.rules 

# USB device 0x:0x (asix)
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="84:xx:xx:xx:xx",
ATTR{dev_id}=="0x0", ATTR{type}=="1", KERNEL=="eth*", NAME="eth1"
```

### IP Configuration
Add the following items into the network configuration file:    

```
# vim /etc/network/interfaces 
    # usb network eth1
    allow-hotplug eth1
    iface eth1 inet static
    address 10.0.80.1
    netmask 255.255.255.0
```

Now restart the network, to see the ethernet has been enabled.    

### DHCPD Configuration
Add following configuration to the /etc/dhcp/dhcpd.conf:   

```
### this is for USB NET

subnet
10.0.80.0 netmask 255.255.255.0 {
# --- default gateway
option routers
10.0.80.1;
# --- Netmask
option subnet-mask
255.255.255.0;
# --- Broadcast Address
option broadcast-address
10.0.80.255;
# --- Domain name servers, tells the clients which DNS servers to use.
option domain-name-servers
223.5.5.5,180.76.76.76;
option time-offset 0;
range 10.0.80.3 10.0.80.13;
default-lease-time 1209600;
max-lease-time 1814400;
}
``` 

### IPtables and dhcpd

Add following items into the ~/.config/awesome/rc.lua

```
autorunApps =
{
--.........
"blueman-manager",
"fcitx",
"/home/dash/Downloads/what/whatpulse",
-- "pidgin",
"sudo iptables -t nat -A POSTROUTING -s 10.0.70.0/24 ! -d 10.0.70.0/24  -j MASQUERADE",
"sudo iptables -t nat -A POSTROUTING -s 10.0.80.0/24 ! -d 10.0.80.0/24 -j MASQUERADE" 
"sudo dhcpd wlan0 eth1",
```

Now everytime we reboot the system, it will automatically start the dhcpd server and
let OpenWRT as the access Point.    
