---
layout: post
title: "Trouble Shooting On Lost SSH Connection"
date: 2014-12-30 11:42
comments: true
categories: web
---
I found lots of ssh connection attack info under the folder of /var/log/btmp, So I decide to change the sshd default listening port, from 22 to xxxx. Following is the steps for doing this:      
### Change SSHD Listening Port
Change the default port from 22 to xxxx

```
# vim /etc/ssh/sshd_config
Change the port from 22 to xxxx
# service ssh restart

```
Now, congratulations, you lost all of your connections, since you have enable the iptables and banned all of the other ports.    
### Solution
Don't worry, we have digitalOcean's terminal service, from it we could reached the console.     
But the problem is: it's pretty slow for us to visit this webpage from China to US!    
Then we should use another machine which runs coreos.     
Create a new lxde based vnc machine simply via following command:    

```
core@Trustycore ~ $ docker pull dorowu/ubuntu-desktop-lxde-vnc

```
Run the machine    

```
docker run -i -t -p 6080:6080 dorowu/ubuntu-desktop-lxde-vnc

```
Then open your browser and visit:     
`http://Your_ip_address:6080/vnc.html` you could reached the vnc machine.   
### Memory Problem
Since the default memory is only 512MB, we have to enable the swapfile, thus we could use firefox for accessing the DigitalOcean terminal.    
Following is the steps:       

```
$ sudo dd if=/dev/zero of=/swapfile bs=1M count=1024
$ sudo chmod 600 /swapfile 
$ sudo mkswap /swapfile
$ sudo vim /etc/systemd/system/swap.service
 [Unit]  
 Description=Turn on swap  
 [Service]  
 Type=oneshot  
 Environment="SWAPFILE=/swapfile"
 RemainAfterExit=true  
 ExecStartPre=/usr/sbin/losetup -f ${SWAPFILE}  
 ExecStart=/usr/bin/sh -c "/sbin/swapon $(/usr/sbin/losetup -j ${SWAPFILE} | /usr/bin/cut -d : -f 1)"  
 ExecStop=/usr/bin/sh -c "/sbin/swapoff $(/usr/sbin/losetup -j ${SWAPFILE} | /usr/bin/cut -d : -f 1)"  
 ExecStopPost=/usr/bin/sh -c "/usr/sbin/losetup -d $(/usr/sbin/losetup -j ${SWAPFILE} | /usr/bin/cut -d : -f 1)"  
 [Install]  
 WantedBy=multi-user.target 
$ sudo  systemctl enable /etc/systemd/system/swap.service  
$ sudo systemctl start swap  

```
Now you could happily use firefox in your vnc window.   
Simply login to the terminal window, and modify the configuration file, restart the ssh service, now you could also change the iptables rules, to open xxxx port.    

Another way is to disable root login, in `/etc/ssh/sshd_config `, set`#PermitRootLogin yes` to `PermitRootLoginno`.    

You will be safe.     
