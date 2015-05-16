---
layout: post
title: "MAAS Deploy(1)"
date: 2015-03-11 07:11
comments: true
categories: virtualization
---
This deploy series will record every steps that I deploy OpenStack on Ubuntu based server.     
### Network Configuration
I want to deploy the MAAS environment in a seperated network, thus I have to create the new network in virt-manager via following steps:   
First, double-click localhost(QEMU), this will pop-up the configuration of the virt-manager.     
Second, in the Virtual Networks, click "+", name it, change its ip range addresses to `10.17.17.0/24`, de-select `Enable DHCPv4`, In the last window, select "Forwarding to phsical network", select the bridge interface that you have in your physical machine.     
By this two steps you will have the isolated NAT networks.    

Possible problems, I met in my ArchLinux:    

```
First :
Cannot start Virtual Network: "out of memory"

Solved via:    
$ sudo pacman -S ebtables
$ sudo systemctl restart libvirtd

Error creating virtual network: Cannot check dnsmasq binary /sbin/dnsmasq: No such file or directory
$ sudo pacman -S dnsmasq

```

### Mass Controller Machine Installation
In virt-manager, create a new virtual machine, which takes around 1.5G Memory and 2 Cores, 40G memory. The network we used is the one we created in last step, this will create the maas controller in this isolated network, thus every newly-created nodes will start-up from this controller.    

Start install this machine, you won't have the auto-configured ip address, so you should manually specify the IP Address for this controller machine, mine use `10.17.17.202`.    

### Mass Controller Configuration
First add maas testing repository to the existing apt configuration files, Make sure you have added following 2 lines at the end of the file:    

```
$ sudo add-apt-repository  ppa:maas-maintainers/maas-test
$ sudo vim /etc/apt/sources.list
deb http://ppa.launchpad.net/maas-maintainers/testing/ubuntu trusty main 
deb-src http://ppa.launchpad.net/maas-maintainers/testing/ubuntu trusty main 
$ sudo apt-get update

``` 
The maas-test is located at:    
[https://launchpad.net/~maas-maintainers/+archive/ubuntu/maas-test?field.series_filter=trusty](https://launchpad.net/~maas-maintainers/+archive/ubuntu/maas-test?field.series_filter=trusty)    

Now install following packages:    

```
$ sudo apt-get install ssh nano iptraf htop wget lynx dnsutils maas maas-dhcp maas-dns git build-essential

```

Met hashsum missing, solved via following:    

```
$ sudo rm -fR /var/lib/apt/lists/*  
$ sudo mkdir /var/lib/apt/lists/partial  
$ sudo bash
$ proxychains4 apt-get update

```
After installation, you will got MAAS installed, so open your browser and visit `http://10.17.17.202/MAAS`, you will get a hint that you have to run following commands for making MAAS service really avaiable:    

```
$ sudo maas-region-admin createsuperuser

```
The configuration above should input the username/password, and also your email address, etc. After inputing all of this, visit `http://10.17.17.202/MAAS` again, now you got the MAAS configuration webpages.    
