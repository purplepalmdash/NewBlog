---
layout: post
title: "Single Node OpenStack Startup"
date: 2015-02-27 20:29
comments: true
categories: Virtualization
---
Following records the main steps for starting up the single node Openstack environment.    
### Ubuntu Setup and Configuration
#### Setup
Use virt-manager, create a new virtual machine, install the system from ubuntu-12.04.3-server-amd64.iso, allocate 2 CPU and 4096 Memory, allocate the 80GB disk.   
Create disk via:    

```
Trusty@pc119:~/Code/Virt-Manager/SingleNode> qemu-img create -f qcow2 SingleNode.qcow2 80G
Formatting 'SingleNode.qcow2', fmt=qcow2 size=85899345920 encryption=off cluster_size=65536 lazy_refcounts=off

```
Configure the networking, bridge, then beging installing.   
IP address set to 192.168.188.190/255.255.255.0, gateway first we set it to 192.168.188.1, later we will change it, because it's a pseudo-addresses.    
#### Configuration
First save a snapshot, shutdown the running virtual machine, then you could clone it for back up.    
Configure the network in virtual machine via:    

```
$ sudo ip route add default gw 192.168.0.xxx
$ sudo ip route add 192.168.0.0/24 dev eth0

```
SSH fast connect:    

```
$ sudo vi /etc/ssh/sshd_config
UseDNS no
$ sudo service ssh restart

```
Now you could ssh to the virtual machine and update corresponding configurations.   

In fact the snapshot could be made here.     
Transfer the installtion media to virtual machine:    

```
$ scp ./contrail-install-packages_1.21-74\~havana_all.deb Trusty@192.168.188.190:/home/Trusty/

```

### Install OpenContrail
Set the root password:    

```
$ sudo bash
root@SingleNode:~# passwd
Enter new UNIX password: 
Retype new UNIX password: 
passwd: password updated successfully

```
Install the deb file via:    

```
root@SingleNode:~# ls
contrail-install-packages_1.21-74~havana_all.deb
root@SingleNode:~# dpkg -i contrail-install-packages_1.21-74~havana_all.deb 

```
Now setup the whole packages.    

```
root@SingleNode:/etc/apt# cd /opt/contrail/contrail_packages/
root@SingleNode:/opt/contrail/contrail_packages# ls
contrail_debs.tgz  preferences  setup.sh  sources.list  VERSION
root@SingleNode:/opt/contrail/contrail_packages# ./setup.sh

``` 
Copy the example testbed file to `testbed.py`:    

```
root@SingleNode:/opt/contrail/utils# cp fabfile/testbeds/testbed_singlebox_example.py fabfile/testbeds/testbed.py

```
Edit this file to, notice the + means we did modifications    :    

```
from fabric.api import env

#Management ip addresses of hosts in the cluster
+++ host1 = 'root@127.0.0.1'

#External routers if any
#for eg. 
#ext_routers = [('mx1', '10.204.216.253')]
ext_routers = []

#Autonomous system number
router_asn = 64512

#Host from which the fab commands are triggered to install and provision
+++ host_build = 'root@127.0.0.1'

#Role definition of the hosts.
env.roledefs = {
    'all': [host1],
    'cfgm': [host1],
    'openstack': [host1],
    'control': [host1],
    'compute': [host1],
    'collector': [host1],
    'webui': [host1],
    'database': [host1],
    'build': [host_build],
    'storage-master': [host1],
    'storage-compute': [host1],
}

#Openstack admin password
env.openstack_admin_password = 'secret123'

#Hostnames
env.hostnames = {
+    'all': ['SingleNode']
}

+++ env.password = 'rootpass'
#Passwords of each host
env.passwords = {
+++     host1: 'rootpass',

+++     host_build: 'rootpass',
}

#For reimage purpose
env.ostypes = {
+++    host1:'ubuntu',
}

```
Now use fab to install :    

```
root@SingleNode:/opt/contrail/utils# fab -c fabrc install_contrail

```
This will take some minutes.   
Then setup all:    

```
# cd /opt/congrail/utils
# fab setup_all

```
After installation the machine will be reboot.    
A snapshot will be created when reboot done, this will be the cloned initial startpoint for OpenContrail.    
### Start
Create a simple web server via python:    

```
python -m SimpleHTTPServer 8000

```
Then Create the image in OpenStack via:    

