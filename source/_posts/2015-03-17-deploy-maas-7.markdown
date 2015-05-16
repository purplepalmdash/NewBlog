---
layout: post
title: "Deploy MAAS(7)"
date: 2015-03-17 09:55
comments: true
categories: Virtualization
---
This will record the complete steps for deploying MAAS in a newly installed machine.    
### Installation
The start point should be at Ubuntu14.04.     

```
$ sudo add-apt-repository  ppa:maas-maintainers/maas-test
$ sudo vim /etc/apt/sources.list
# Add maas repository
deb http://ppa.launchpad.net/maas-maintainers/testing/ubuntu trusty main
deb-src http://ppa.launchpad.net/maas-maintainers/testing/ubuntu trusty main
$ sudo add-apt-repository ppa:juju/stable
$ sudo vim /etc/apt/sources.list
# Add juju repository
deb http://ppa.launchpad.net/juju/stable/ubuntu trusty main 
deb-src http://ppa.launchpad.net/juju/stable/ubuntu trusty main 
$ sudo apt-get update && sudo apt-get upgrade
$ sudo apt-get install maas-test maas-dhcp maas-dns juju juju-core juju-local juju-quickstart firefox git

```
Tips: for enable the vncserver on Ubuntu, do following:    

```
$ sudo apt-get install tightvncserver lxde
$ vncserver
$ vim ~/.vnc/xstartup
#!/bin/sh

xrdb $HOME/.Xresources
xsetroot -solid grey
#x-terminal-emulator -geometry 80x24+10+10 -ls -title "$VNCDESKTOP Desktop" &
#x-window-manager &
# Fix to make GNOME work
export XKL_XMODMAP_DISABLE=1
# /etc/X11/Xsession
startlxde &
$ vncserver -kill :1 && vncserver

```
The MAAS Controller relies on a google's theme which is blocked by GFW, so we have to use proxychains for acrossing it, please notice these operation could be done on host machine, or Maas Controller itself..    

```
$ git clone https://github.com/rofl0r/proxychains-ng.git 
$ ./configure --prefix=/usr && make && make install
$ sudo cp src/proxychain4.conf /etc
$ sudo vim /etc/proxychains4.conf
$ sudo apt-get install midori
$ proxychains4 midori 10.17.17.202/MAAS

```
Configure the MAAS Controller via:     

```
$ sudo maas-region-admin createadmin
[sudo] password for Trusty: 
Username: root
Password: 
Again: 
Email: root@localhost

```
This enabled the admin username/password, refresh the `10.17.17.202/MAAS` you could login to the MAAS Controller.    
### Configuration
#### Image Configuration
First download the images fromt the official repository via(On MaasController):     

```
$ sudo apt-get install simplestreams ubuntu-cloudimage-keyring apache2
$ sudo bash
# proxychains4 sstream-mirror --keyring=/usr/share/keyrings/ubuntu-cloudimage-keyring.gpg http://maas.ubuntu.com/images/ephemeral-v2/daily/ /var/www/html/maas/images/ephemeral-v2/daily 'arch=amd64' 'subarch~(generic|hwe-t)' 'release~(trusty|precise)' --max=1
^C
$ pwd
/var/www/html/maas/images
$ sudo mv ephemeral-v2/ ephemeral-v2.back
[sudo] password for Trusty: 
$ sudo tar xjf /home/Trusty/ephemeral-v2.tar.bz2 -C ./

```
Then Change the configuration in browser of opened `http://10.17.17.202/MAAS`:    

```
Click Configuration Button, and update the Ubuntu -> Main archive (required) from: 
http://archive.ubuntu.com/ubuntu 
to: 
http://mirrors.aliyun.com/ubuntu/ 
This repository enable the installed system for retrieving the install packages, use aliyun we could get much more faster speed.

Change the Boot Images -> Sync URL (required) from: 
http://maas.ubuntu.com/images/ephemeral-v2/releases/ 
to 
http://10.17.17.202/maas/images/ephemeral-v2/daily/ 
This will enable the Boot Images Sync URLs, use local repository will greatly improve the bootup speed.

```
#### Network Configuration
Since the midori's effect is not good, install qupzilla:    

```
$ sudo apt-get install qupzilla
$ proxychains4 quazilla http://10.17.17.202/MAAS

```
Under `Cluster->Interfaces->eth0->Edit`, change it to `Management(DNS and DHCP)`, and then modify following items:    
![/images/2015_03_17_11_17_28_411x358.jpg](/images/2015_03_17_11_17_28_411x358.jpg)      

MAAS ssh key should be generated via following steps:    

```
Trusty@MassController:~$ sudo mkdir /home/maas
[sudo] password for Trusty: 
Trusty@MassController:~$ sudo chown maas:maas /home/maas/
Trusty@MassController:~$ sudo chsh maas
Changing the login shell for maas
Enter the new value, or press ENTER for the default
        Login Shell [/bin/false]: /bin/bash
Trusty@MassController:~$ sudo su - maas
maas@MassController:~$ ssh-keygen 
Generating public/private rsa key pair.

``` 
Copy the generated key to [http://10.17.17.202/MAAS/account/prefs/sshkey/add/](http://10.17.17.202/MAAS/account/prefs/sshkey/add/)    And remember the api-key, for later we will use it for generating nodes information.     
Enable the remote control of your host's libvirt:    

```
$ sudo apt-get install libvirt-bin
maas@MassController:~$ ssh-copy-id root@10.17.17.1
maas@MassController:~$ virsh -c qemu+ssh://root@10.17.17.1/system list  --all
 Id    Name                           State
----------------------------------------------------
 2     MaasController                 running
 -     Ubuntu1404Maas                 shut off
 -     Ubuntu203                      shut off

```
Also we have to configure the network under [http://10.17.17.202/MAAS/networks/maas-eth0/edit/](http://10.17.17.202/MAAS/networks/maas-eth0/edit/):    
![/images/2015_03_17_11_34_31_478x283.jpg](/images/2015_03_17_11_34_31_478x283.jpg)     

Also we should manually edit the MaasController's network configuration via:   

```
$ cat /etc/network/interfaces
auto lo
iface lo inet loopback
# The primary network interface
auto eth0
# iface eth0 inet dhcp
iface eth0 inet static                                                                                                                        
        address 10.17.17.202                                                                                                                  
        netmask 255.255.255.0                                                                                                                 
        network 10.17.17.0                                                                                                                    
        broadcast 10.17.17.255                                                                                                                
        gateway 10.17.17.1                                                                                                                    
        # dns-* options are implemented by the resolvconf package, if installed                                                               
        dns-nameservers 114.114.114.114 127.0.0.1 10.17.17.202

```
Restart and the network configuration is OK, notice only we set 127.0.0.1 as the dns server, we could enable the local FQDN.     

### Add Nodes
Create the vm in virt-manager, its start-up is via PXE, and with 3G Mem, 60G space, 2-Core which copies the Host CPU.    
Then in browser edit like following:     
![/images/2015_03_17_11_47_59_511x576.jpg](/images/2015_03_17_11_47_59_511x576.jpg)    
Then in the `Nodes`, select the node, and commision selected node.After commission, the status will be changed to ready.   
![/images/2015_03_17_11_54_29_589x157.jpg](/images/2015_03_17_11_54_29_589x157.jpg)    

### Juju Configuration
Use following command for quickstart juju:    

```
$ juju-quickstart -i

```
The configuration image is listed as:    
![/images/2015_03_17_11_57_47_559x457.jpg](/images/2015_03_17_11_57_47_559x457.jpg)    

Generate the local tools:    

```
$ mkdir .juju/metadata
Trusty@MassController:~$ juju metadata generate-tools -d ~/.juju/metadata

```
Then start the node via:     

```
$ juju bootstrap --metadata-source ~/.juju/metadata --upload-tools -v --show-log --constraints="mem=3G"

```
After it success, the juju and MAAS environment is ready for use.    
 
