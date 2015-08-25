---
layout: post
title: "Enable Trusty KickStart For SpaceWalk"
date: 2015-08-25 16:06:17 +0800
comments: true
categories: Linux
---
### Import distro-tree
Copy iso content into the distro-tree:    

```
# mount -t  iso9660 -o loop /mnt/iso/ubuntu-14.04.3-server-amd64.iso /mnt1/
# mkdir /var/distro-trees/ubuntu-14.04.3-amd64
# chmod 755 /var/distro-trees/ubuntu-14.04.3-amd64/
# cp -ar /mnt1/* /var/distro-trees/ubuntu-14.04.3-amd64/
```
We will copy the pxeboot startup file from CentOS7 into ubuntu14.04 distro tree for
cheating the spacewalk:    

```
# mount -t iso9660 -o loop /mnt/iso/CentOS-7-x86_64-Everything-1503-01.iso /mnt2/
# mkdir -p /var/distro-trees/ubuntu-14.04.3-amd64/images/pxeboot/
# cp /mnt2/images/pxeboot/{initrd.img,vmlinuz} /var/distro-trees/ubuntu-14.04.3-amd64/images/pxeboot/
# ls /var/distro-trees/ubuntu-14.04.3-amd64/images/pxeboot/ -l -h
....
```

### Kickstarting
Now in spacewalk go to Systems->Kickstart->Distributions, with the parameters like
following picture:    

![/images/2015_08_25_16_17_53_595x352.jpg](/images/2015_08_25_16_17_53_595x352.jpg)    
We copy the CentOS Kernel and initrd, so Spacewalk use redhat parameters for this
distribution, later we will fix this.     

Now create a profile via go to Systems->Kickstart->Profiles and "upload a new kickstart
file", just like following picture.    

![/images/2015_08_25_16_22_53_617x590.jpg](/images/2015_08_25_16_22_53_617x590.jpg)   

We fix the hardcoded breed from redhat to ubuntu via following steps:    

Get the list info via `cobbler list`:    

![/images/2015_08_25_16_27_12_515x205.jpg](/images/2015_08_25_16_27_12_515x205.jpg)    

Report the selected distro info:    

```
# cobbler distro report --name=trustyamd64:1:SpacewalkDefaultOrganization
``` 

![/images/2015_08_25_16_28_48_990x256.jpg](/images/2015_08_25_16_28_48_990x256.jpg)    

Edit it like following:    

```
# cobbler distro edit --name trustyamd64:1:SpacewalkDefaultOrganization --breed=ubuntu --os-version=jaunty --initrd=/var/distro-trees/ubuntu-14.04.3-amd64/install/netboot/ubuntu-installer/amd64/initrd.gz --kernel=/var/distro-trees/ubuntu-14.04.3-amd64/install/vmlinuz 
```

We should notice the initrd file and kernel has been modified!!!   

![/images/2015_08_25_16_32_24_933x261.jpg](/images/2015_08_25_16_32_24_933x261.jpg)   

Now edit the `/var/lib/tftpboot/pxelinux.cfg/default` file, find the item and modify it like following:    

```
LABEL trustykickstart:1:SpacewalkDefaultOrganization
        kernel /images/trustyamd64:1:SpacewalkDefaultOrganization/vmlinuz
        MENU LABEL trustykickstart:1:SpacewalkDefaultOrganization
        append initrd=/images/trustyamd64:1:SpacewalkDefaultOrganization/initrd.gz  ks=http://192.168.0.79/trustykickstart.cfg ksdevice=eth0 --
        ipappend 2
```
Now you could kickstart your ubuntu trusty now.     

### Register to SpaceWalk