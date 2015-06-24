---
layout: post
title: "WH Worktips(6)"
date: 2015-06-24 11:54:12 +0800
comments: true
categories: Virtualization
---
### Migration
So this time we will migrate the whole machine, that is the Cobbler Server from one physical machine to another one. The steps are:    
1. Transfer the harddisk files.     
2. Edit the `/etc/udev/rules.d/70-persistent-net.rules`, Change the eth1 to eth0, and remove the eth0 item.    
3. Edit the `/etc/sysconfig/network-scripts/ifcfg-eth0`, its mac address to the one you specified on step 2.     
4. Restart the machine.      

### Modification && Test
Create a new machine, which mac address is `52:54:00:3a:87:4e`, and define it on Cobbler server:     

```
[root@z_WHServer ~]# cobbler system add --name=node147 --profile=CentOS-6.5-x86_64 --mac=52:54:00:3a:87:4e --interface=eth0 --ip-address=10.47.58.147 --hostname=node147 --gateway=10.47.58.1 --dns-name=node147
```
Now bootup the machine and let it be deployed by cobbler server. The deployment time depends on your disk speed.       

At the same time, edit the Ansible configuration:    

```
[root@z_WHServer Ansible]# cat hosts
[node147]
10.47.58.147
[root@z_WHServer Ansible]# pwd
/root/Code/Ansible
```

Copy the repository to the `10.47.58.2:/var/www/html/`, and edit the Ansible configuration.     
And Also configure the nfs server for the second host, previously we use the one we got from the external nfs server.    
Also the download vhd template files.    
```
$ scp -r ./4.4/ root@10.47.58.2:/var/www/html/
[root@z_WHServer html]# chmod 777 -R 4.4
[root@z_WHServer CloudStack-Ansible-Playbook]# vim templates/cloudstack.repo.j2
[cloudstack]
name=cloudstack
baseurl=http://10.47.58.2/4.4/
clouder@pc121:/home/juju$ scp ./systemvm64template-* root@10.47.58.2:/var/www/html/
root@10.47.58.2's password: 
systemvm64template-2014-06-23-master-xen.vhd.bz2                                                             100%  237MB  59.4MB/s   00:04 
systemvm64template-4.4.1-7-kvm.qcow2.bz2                                                                     100%  291MB  36.4MB/s   00:08
clouder@pc121:/home/juju$ scp ./vhd-util root@10.47.58.2:/var/www/html/
[root@z_WHServer html]# chmod 777 systemvm64template-*
[root@z_WHServer html]# chmod 777 vhd-util
[root@z_WHServer html]# vim /etc/exports 
/home/export *(rw,async,no_root_squash,no_subtree_check)
[root@z_WHServer html]# mkdir -p /home/export
[root@z_WHServer html]# chmod 777 -R /home/export/
[root@z_WHServer html]# chkconfig nfs on
[root@z_WHServer html]# chkconfig rpcbind on
[root@z_WHServer html]# service nfs restart
[root@z_WHServer html]# service rpcbind restart
[root@z_WHServer html]# iptables -D INPUT -j REJECT --reject-with icmp-host-prohibited
[root@z_WHServer home]# chown -R nobody /home/export/
[root@z_WHServer CloudStack-Ansible-Playbook]# vim cloudstack.yml
.......
    CSManagement:
      ManagementIP: 10.47.58.147
      SecondaryMount: /secondary
      NFSHost: 10.47.58.2
      NFSSecondaryShare: /home/export
      SysTemplateURLurl43: http://10.47.58.2/systemvm64template-2014-06-23-master-xen.vhd.bz2
      SysTemplateURLurl44: http://10.47.58.2/systemvm64template-4.4.1-7-kvm.qcow2.bz2 
      SysTemplateURLhv: xenserver
      VhdutilURL: http://10.47.58.2/vhd-util
.....
```

Now deploy the playbooks via the same process in:     
[http://purplepalmdash.github.io/blog/2015/06/19/wh-worktips-4/](http://purplepalmdash.github.io/blog/2015/06/19/wh-worktips-4/)    

```
# cd /root/Code/Ansible/CloudStack-Ansible-Playbook
# ansible-playbook -i /root/Code/Ansible/hosts --limit=node113 ./cloudstack.yml --tags=pip
# ansible-playbook -i /root/Code/Ansible/hosts --limit=node113 ./cloudstack.yml --tags=base
# ansible-playbook -i /root/Code/Ansible/hosts --limit=node113 ./cloudstack.yml --tags=mysql
# ansible-playbook -i /root/Code/Ansible/hosts --limit=node113 ./cloudstack.yml --tags=mysql3306
# ansible-playbook -i /root/Code/Ansible/hosts --limit=node113 ./cloudstack.yml --tags=csmanagement 
```

Visit 
[http://10.47.58.147:8080/client](http://10.47.58.147:8080/client)      



