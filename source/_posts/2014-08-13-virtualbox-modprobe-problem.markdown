---
layout: post
title: "Virtualbox Modprobe Problem"
date: 2014-08-13 15:19
comments: true
categories: virtualbox
---
After upgrading the Linux Kernel, my virtualbox cannot automatically load the kernel modules for virtualbox. Following is the steps for finding out the problems and solving them.     
### Locating Problem
I could manually modprobe the virtualbox driver, but failed to load at boot, so I first check the status of the systemd's output.    
Checking the systemd's modules load service status:     

```
# systemctl status systemd-modules-load.service
● systemd-modules-load.service - Load Kernel Modules
   Loaded: loaded (/usr/lib/systemd/system/systemd-modules-load.service; static)
   Active: failed (Result: exit-code) since Wed 2014-08-13 13:32:34 CST; 1h 24min ago
     Docs: man:systemd-modules-load.service(8)
           man:modules-load.d(5)
  Process: 142 ExecStart=/usr/lib/systemd/systemd-modules-load (code=exited, status=1/FAILURE)
 Main PID: 142 (code=exited, status=1/FAILURE)

Aug 13 13:32:34 XXXyyy systemd[1]: systemd-modules-load.service: main process exited, code=exited, status=1/FAILURE
Aug 13 13:32:34 XXXyyy systemd[1]: Failed to start Load Kernel Modules.
Aug 13 13:32:34 XXXyyy systemd[1]: Unit systemd-modules-load.service entered failed state.
Warning: Journal has been rotated since unit was started. Log output is incomplete or unavailable.

```

Manually reload this service and check the status:    

```
[root@XXXyyy Trusty]# systemctl restart systemd-modules-load
Job for systemd-modules-load.service failed. See 'systemctl status systemd-modules-load.service' and 'journalctl -xn' for details.
[root@XXXyyy Trusty]# systemctl status systemd-modules-load
● systemd-modules-load.service - Load Kernel Modules
   Loaded: loaded (/usr/lib/systemd/system/systemd-modules-load.service; static)
   Active: failed (Result: exit-code) since Wed 2014-08-13 14:59:31 CST; 13s ago
     Docs: man:systemd-modules-load.service(8)
           man:modules-load.d(5)
  Process: 21364 ExecStart=/usr/lib/systemd/systemd-modules-load (code=exited, status=1/FAILURE)
 Main PID: 21364 (code=exited, status=1/FAILURE)

Aug 13 14:59:31 XXXyyy systemd[1]: systemd-modules-load.service: main process exited, code=exited, status=1/FAILURE
Aug 13 14:59:31 XXXyyy systemd[1]: Failed to start Load Kernel Modules.
Aug 13 14:59:31 XXXyyy systemd[1]: Unit systemd-modules-load.service entered failed state.

```
Use journalctl to view the PID's logs:    

```
[root@XXXyyy Trusty]# journalctl -b _PID=21364
-- Logs begin at Thu 2014-07-31 16:07:13 CST, end at Wed 2014-08-13 15:00:02 CST. --
Aug 13 14:59:31 XXXyyy systemd-modules-load[21364]: Failed to find module 'vboxdrv vboxnetflt vboxnetadp'
[root@XXXyyy Trusty]# systemctl status dkms.service 
● dkms.service - Dynamic Kernel Modules System
   Loaded: loaded (/usr/lib/systemd/system/dkms.service; disabled)
   Active: inactive (dead)

```
So the problem is quite clear: Failed to find module, and dkms service is not enabled.    
### Solving Problem
First enable the dkms.service via:    

```
# systemctl enable dkms.service
Created symlink from /etc/systemd/system/multi-user.target.wants/dkms.service to /usr/lib/systemd/system/dkms.service.

```
Install vboxhost-hook, this will add the hook to compile the virtualbox host modules:    

```
# yaourt -S vboxhost-hook

```
Add vboxhost into the /etc/mkinitcpio.conf:    

```
HOOKS="base udev autodetect modconf block filesystems keyboard fsck vboxhost"

```
Now recompile the initramfs via:    

```
mkinitcpio -p linux

```
dkms should also be installed:    

```
pacman -S linux-headers virtualbox-host-dkms viftualbox-guest-dkms
dkms install vboxhost/4.3.14
dkms install vboxguest/4.3.14

```

Finally I found the reason:    

```
# cat /etc/modules-load.d/virtualbox.conf
# Load virtualbox related modules at startup
vboxdrv
vboxnetflt
vboxnetadp

```
But previously I let them in one line!!!!!!!!!!!!!OMG.......    
Reboot and examine the result via `lsmod | grep vbox`.    
