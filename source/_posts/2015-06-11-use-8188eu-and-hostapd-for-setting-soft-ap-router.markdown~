---
layout: post
title: "Use 8188eu and Hostapd For Setting Soft-AP Router"
date: 2015-06-11 16:25:51 +0800
comments: true
categories: Linux
---
### HostAPD
Install HostAPD via following commands:    

```
$ sudo apt-get autoremove hostapd
$ wget https://github.com/jenssegers/RTL8188-hostapd/archive/v2.0.tar.gz
$ tar -zxvf v2.0.tar.gz
$ cd RTL8188-hostapd-2.0/hostapd
$ sudo make
$ sudo make install
$ sudo service hostapd restart
[ ok ] Stopping advanced IEEE 802.11 management: hostapd.
[ ok ] Starting advanced IEEE 802.11 management: hostapd.

```

### dhcpd
We need a dhcp server for assigning a new IP address to the clients who joins the ap:    
An example file is listed as following:    

```
ddns-update-style none;
ignore client-updates;
authoritative;
option local-wpad code 252 = text;
 
subnet
10.0.0.0 netmask 255.255.255.0 {
# --- default gateway
option routers
10.0.0.1;
# --- Netmask
option subnet-mask
255.255.255.0;
# --- Broadcast Address
option broadcast-address
10.0.0.255;
# --- Domain name servers, tells the clients which DNS servers to use.
option domain-name-servers
10.0.0.1, 8.8.8.8, 8.8.4.4;
option time-offset
0;
range 10.0.0.3 10.0.0.13;
default-lease-time 1209600;
max-lease-time 1814400;
}
```

### WLAN0 Network
The WLAN0 equipment network should be configured as following:    

```
$ cat /etc/network/interface
# wireless wlan0
allow-hotplug wlan0
iface wlan0 inet static
address 10.0.70.1
netmask 255.255.255.0

```
So next time you reboot the computer, it will automatically get the ip address for wlan0.    

### Enable the ip forwarding
Using following 2 commands for enabling your AP.    

```
$ sudo iptables -t nat -A POSTROUTING -s 10.0.70.0/24 ! -d 10.0.70.0/24  -j MASQUERADE
$ sudo dhcpd wlan0
```
I add these two lines into the start file of awesome(My desktop environment).    

