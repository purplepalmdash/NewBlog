---
layout: post
title: "Import More ISOs in Cobbler"
date: 2015-06-23 20:52:09 +0800
comments: true
categories: Virtualization
---
### Ubuntu12.04
Since you have the iso files, import it via:    

```
[root@CobblerServer iso]# mount -t iso9660 -o loop /mnt/iso/ubuntu-12.04.3-server-amd64.iso /mnt1
[root@CobblerServer iso]# cobbler import --name=Ubuntu-12.04 --arch=x86_64 --path=/mnt1/
[root@CobblerServer iso]# cobbler profile list
   CentOS-7-x86_64
   Ubuntu-12.04-x86_64
   Ubuntu14.04-x86_64
```

To make it quickly deployment, visit:      
[http://purplepalmdash.github.io/blog/2015/05/18/my-configuration-on-cobbler-for-deploying-ubuntu12-dot-04/](http://purplepalmdash.github.io/blog/2015/05/18/my-configuration-on-cobbler-for-deploying-ubuntu12-dot-04/)    

Edit its profile like following:     

```
[root@CobblerServer kickstarts]# cobbler profile edit --name=Ubuntu-12.04-x86_64 --kickstart=/var/lib/cobbler/kickstarts/ubuntu1204.seed 
```

Create a new virtual machine for testing.    

```
[root@CobblerServer kickstarts]# cobbler system add --name=test1204 --profile=Ubuntu-12.04-x86_64 --mac=52:54:00:e4:2c:df --interface=eth0 --ip-address=10.3.3.33 --hostname=test1204 --gateway=10.3.3.1 --dns-name=test1204
```

Testing the tftpserver via:     

```
[dash@~]$ tftp 10.3.3.3   
tftp> get /pxelinux.0
tftp> quit
[dash@~]$ ls pxelinux.0 
pxelinux.0
```

Trouble-Shooting, you should very careful on your pxelinux.0 file, make sure you have the correct ones. Recently it's hard to get the right pxelinux.0 from cobbler loader sync.     


### Ubuntu15.04
Import the iso via:    

```
[root@CobblerServer iso]# mount -t iso9660 -o loop ./ubuntu-15.04-server-amd64.iso /mnt1/
[root@CobblerServer iso]# cobbler import --name=Ubuntu-15.04 --arch=x86_64 --path=/mnt1
```

Notice, here you will met Signature mismatch problem, do following:     
First update Cobbler: ?    

```
$ vim /etc/yum.repos.d/cobbler26.repo
[home_libertas-ict_cobbler26]
name=Cobbler (2.6.x) (CentOS_CentOS-6)
type=rpm-md
baseurl=http://download.opensuse.org/repositories/home:/libertas-ict:/cobbler26/CentOS_CentOS-6/
gpgcheck=1
gpgkey=http://download.opensuse.org/repositories/home:/libertas-ict:/cobbler26/CentOS_CentOS-6/repodata/repomd.xml.key
enabled=1
$ sudo yum install -y cobbler cobbler-web
```

And Trouble-Shooting for iptables(If you use redsocks):     

```
# iptables -t nat -I OUTPUT -d 10.3.3.0/24 -j RETURN
```
Then signature update will OK:    

```
[root@CobblerServer redsocks]# cobbler signature update
task started: 2015-06-23_144247_sigupdate
task started (id=Updating Signatures, time=Tue Jun 23 14:42:47 2015)
Successfully got file from http://cobbler.github.com/signatures/2.6.x/latest.json
*** TASK COMPLETE ***

```

Re-import:      

```
[root@CobblerServer iso]# cobbler import --name=Ubuntu-12.04 --arch=x86_64 --path=/mnt1/
*** TASK COMPLETE ***
[root@CobblerServer mnt]# cobbler profile list
   CentOS-7-x86_64
   Ubuntu-12.04-x86_64
   Ubuntu-15.04-x86_64
   Ubuntu14.04-x86_64
```

Edit the profile via:      

```
[root@CobblerServer lib]# cd /var/lib/cobbler/kickstarts/
[root@CobblerServer kickstarts]# ls
default.ks    esxi5-ks.cfg      legacy.ks     sample_autoyast.xml  sample_esx4.ks   sample_esxi5.ks  sample_old.seed  ubuntu1204.seed
esxi4-ks.cfg  install_profiles  pxerescue.ks  sample_end.ks        sample_esxi4.ks  sample.ks        sample.seed
[root@CobblerServer kickstarts]# vim ubuntu1504.seed
```

Test it via:    

```
$ qemu-img create -f qcow2 Cobbler1504Test.qcow2 100G
$ cobbler profile edit --name=Ubuntu-15.04-x86_64 --kickstart=/var/lib/cobbler/kickstarts/ubuntu1504.seed
$  cobbler system add --name=test1504 --profile=Ubuntu-15.04-x86_64 --mac=52:54:00:2e:c0:ff --interface=eth0 --ip-address=10.3.3.34 --hostname=test1504 --gateway=10.3.3.1 --dns-name=test1504

```

Installed failed, verify it tomorrow.    
