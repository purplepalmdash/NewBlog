---
layout: post
title: "Expand storage in 59"
date: 2014-10-28 20:35
comments: true
categories: linux
---
I have 2 Servers in LAB, one had only 120G Harddisk, but with powerful CPU/Memory, the other have larger disk, but CPU/mem are not power enough, thus I use samba for sharing its storage.     
The samba server runs:   

```
# cat /etc/issue
Red Hat Enterprise Linux Server release 6.3 (Santiago)
Kernel \r on an \m

```
Query if samba installed:   

```
# rpm -qa samba
samba-3.5.10-125.el6.i686

```
Then configure it.    

```
# df -h 
.....
/dev/mapper/vg_linux01-lv_home
                      405G   37G  349G  10% /home

```
Make the directory for sharing:    

```
mkdir -p /home/Trusty/share

```
Add following share directory in /etc/samba/smb.conf:    

```
[myshare]
   comment = Mary's and Fred's stuff
   path = /home/Trusty/share
   valid users = Trusty
   public = no
   writable = yes
   printable = no
   create mask = 0765

```
Then add samba user:    

```
smbpasswd -a Trusty

```
Now `Trusty` become usable for samba.    
Restart samba service:    

```
service smb restart

```
And add samba as the start-up service:   

```
[root@Linux01 Trusty]# chkconfig smb on
[root@Linux01 Trusty]# chkconfig nmb on
[root@Linux01 Trusty]# chkconfig winbind on

```

In powerful server, listed the samba server's sharing directories:    

```
Trusty@Linux59:~> smbclient -L 1xx.xxx.xxx.53 -U Trusty
Enter Trusty's password: 
Domain=[MYGROUP] OS=[Unix] Server=[Samba 3.5.10-125.el6]

        Sharename       Type      Comment
        ---------       ----      -------
        myshare         Disk      Mary's and Fred's stuff
        IPC$            IPC       IPC Service (Samba Server Version 3.5.10-125.el6)
        Trusty            Disk      Home Directories
Domain=[MYGROUP] OS=[Unix] Server=[Samba 3.5.10-125.el6]

        Server               Comment
        ---------            -------

        Workgroup            Master
        ---------            -------

```

Now add it in /etc/fstab:    

```
//1xx.xxx.xxx.xx/myshare         /media/samba/  cifs defaults,username=Trusty,password=xxxx,ip=1xx.xxx.xxx.xx,_netdev 0 0

```
But this won't OK, because cifs depends on the network, we should add following line in root's crontab:     

```
@reboot sleep 10;mount -a

```
Next time you will see the remote samba sharing directory available at  /media/samba. Use mount to see the result.    

Change the uid/gid in mount:   

```
ip=1xx.xxx.xxx.53,uid=1001,gid=100,_netdev

```

