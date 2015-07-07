---
layout: post
title: "WH Worktips(7)"
date: 2015-07-07 15:22:23 +0800
comments: true
categories: Virtualization
---
### Cloudstack Agent Repository
Setup the CloudStack Agent Repository via:    

```
# yum install yum-plugin-downloadonly
# vim /etc/yum.repos.d/cloudstack.repo
[cloudstack]
name=cloudstack
baseurl=http://cloudstack.apt-get.eu/rhel/4.3/
enabled=1
gpgcheck=0
# mkdir Code
# yum install --downloadonly --downloaddir=/root/Code/ cloud-agent
```
Now all of the installation rpm packages has been downloaded to directory, simply upload them to a server, use `createrepo .` to generate the repository, and link them to nginx's root directory.    
Mine is under:    
[http://192.168.0.79/4.4.3CloudStackAgent/](http://192.168.0.79/4.4.3CloudStackAgent/)    

### Agent Installation Steps
In a new deployed machine:     

```
# mv CentOS-* /root/
[root@node161 yum.repos.d]# cat cloudstack.repo 
[cloudstack]
name=cloudstack
baseurl=http://192.168.0.79/4.4.3CloudStackAgent/
enabled=1
gpgcheck=0
# yum install -y cloud-agent
```

Configure qemu and libvirt:    

```
[root@node161 yum.repos.d]# cp /etc/libvirt/qemu.conf /etc/libvirt/qemu.conf.orig
[root@node161 yum.repos.d]# sed -i '/#vnc_listen = "0.0.0.0"/ a vnc_listen = "0.0.0.0"' /etc/libvirt/qemu.conf
[root@node161 yum.repos.d]# diff -du /etc/libvirt/qemu.conf.orig /etc/libvirt/qemu.conf


# cp /etc/libvirt/libvirtd.conf /etc/libvirt/libvirtd.conf.orig
# sed -i '/#listen_tls = 0/ a listen_tls = 0' /etc/libvirt/libvirtd.conf
# sed -i '/#listen_tcp = 1/ a listen_tcp = 1' /etc/libvirt/libvirtd.conf
# sed -i '/#tcp_port = "16509"/ a tcp_port = "16509"' /etc/libvirt/libvirtd.conf
# sed -i '/#auth_tcp = "sasl"/ a auth_tcp = "none"' /etc/libvirt/libvirtd.conf
# sed -i '/#mdns_adv = 1/ a mdns_adv = 0' /etc/libvirt/libvirtd.conf
# diff -du /etc/libvirt/libvirtd.conf.orig  /etc/libvirt/libvirtd.conf

[root@node161 yum.repos.d]# cp /etc/sysconfig/libvirtd /etc/sysconfig/libvirtd.orig
[root@node161 yum.repos.d]# sed -i '/#LIBVIRTD_ARGS="--listen"/ a LIBVIRTD_ARGS="--listen"' /etc/sysconfig/libvirtd
[root@node161 yum.repos.d]# diff -du /etc/sysconfig/libvirtd.orig  /etc/sysconfig/libvirtd
[root@node161 yum.repos.d]# rm -f /etc/libvirt/libvirtd.conf.orig 

# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
127.0.0.1       node161
```

Now you could add the host into the cloudstack management interface.    
