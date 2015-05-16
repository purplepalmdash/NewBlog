---
layout: post
title: "Tips For Setting Up CentOS Local Repository"
date: 2015-05-11 20:48
comments: true
categories: Linux
---
The material is learned from:     
[http://paulcodr.co/blog/2015/yumrepo-server-local/](http://paulcodr.co/blog/2015/yumrepo-server-local/)     
### Steps 
Local ISO Preparation:    

```
[root@localhost ~]# mkdir isos bin
[root@localhost ~]# ls isos
CentOS-6.6-x86_64-bin-DVD1.iso  CentOS-6.6-x86_64-bin-DVD2.iso

```
Download the scripts:    

```
# cd bin
# wget http://paulcodr.co/download/yum-scripts.zip
# unzip yum-scripts.zip 
Archive:  yum-scripts.zip
   creating: yum-scripts/
  inflating: yum-scripts/yum-create-server-centos6.6.sh  
  inflating: yum-scripts/yum-rsync-minimal-centos6.6.sh  

```
Change the priviledges:    

```
[root@localhost bin]# chown -R root:root /root/isos
[root@localhost bin]# chmod 750 -R /root/bin

```
Execute the script:    

```
[root@localhost bin]# mv yum-scripts/* ./
[root@localhost bin]# ls
yum-create-server-centos6.6.sh  yum-rsync-minimal-centos6.6.sh  yum-scripts  yum-scripts.zip
[root@localhost bin]# ./yum-create-server-centos6.6.sh 2>&1 | tee createserver.log

```
Verify it via:    

```
[root@localhost bin]#  du -hs /data/www/yumrpms/centos6.6/6.6/os/x86_64
5.6G    /data/www/yumrpms/centos6.6/6.6/os/x86_64
[root@localhost bin]#  ls -lh /data/www/yumrpms/centos6.6/
total 4.0K
lrwxrwxrwx 1 apache apache    3 May 11 12:49 6 -> 6.6
drwxr-xr-x 3 apache apache 4.0K May 11 12:47 6.6

```
Verify it on another PC:    

```
[root:/home/juju/iso]# curl http://10.7.7.124/yumrpms/centos6.6/6/os/x86_64/
.....
</table>
<address>Apache/2.2.15 (CentOS) Server at 10.7.7.124 Port 80</address>
</body></html>

```
Change the rsync repository in yum-rsync-minimal-cent6.6.sh:    

```
rsync://mirrors.yun-idc.com/centos/

```
Then:    

```
[root@localhost bin]# ./yum-rsync-minimal-centos6.6.sh 2>&1 | tee syncserver.log

```
Wait for rsync......   


