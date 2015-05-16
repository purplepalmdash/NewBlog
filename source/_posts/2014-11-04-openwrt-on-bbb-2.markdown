---
layout: post
title: "OpenWRT on BBB(2)"
date: 2014-11-04 16:54
comments: true
categories: embedded
---
### Cheetsheet For Using NFS
Following configuration use the 192.168.1.221's tftp server and 192.168.1.11's nfs server, why I use different nfs server because 192.168.1.11 runs ubuntu and could reached by nfs client easily.    

```
setenv ipaddr 192.168.1.16
setenv serverip 192.168.1.221
tftpboot ${fdtaddr} am335x-boneblack.dtb
tftpboot ${kloadaddr} uImage
setenv bootargs console=ttyO0,115200n8 root=/dev/nfs rw nfsroot=192.168.1.11:/srv/nfs4/BBBrootfs ip=192.168.1.1 rootwait
bootm ${kloadaddr} - ${fdtaddr}

```
### How to start more services
Current we only got following output:   

```
procd: - init -
//.......
procd: - init complete -

```
From the Kernel Source code we know the init startup sequence:    

```
$ cd /media/y/embedded/BBB/svnco/trunk/build_dir/target-arm_cortex-a9+vfpv3_uClibc-0.9.33.2_eabi/linux-omap/linux-3.14.4
$ cd init
$ vim main.c
if (!try_to_run_init_process("/etc/preinit") ||
	    !try_to_run_init_process("/sbin/init") ||
	    !try_to_run_init_process("/etc/init") ||
	    !try_to_run_init_process("/bin/init") ||
	    !try_to_run_init_process("/bin/sh"))
		return 0;

```

The preinit is called by `/etc/preinit`, while in this file, we found:      

```
for pi_source_file in /lib/preinit/*; do
        . $pi_source_file
done

```
This means all of the preinit script is listed under NFS Server's /lib/preinit/ folder.    

Add our own preinit startup file:    

```
[root@TrustyArch preinit]# ls
02_default_set_state  30_failsafe_wait             70_initramfs_test  90_init_console~
10_indicate_failsafe  40_run_failsafe_hook         80_mount_root      99_10_failsafe_login
10_indicate_preinit   50_indicate_regular_preinit  90_init_console    99_10_run_init
[root@TrustyArch preinit]# vim 90_init_console
#!/bin/sh
# Copyright (C) 2006-2010 OpenWrt.org
# Copyright (C) 2010 Vertical Communications

init_console() {
    preinit_echo "Called 90_init_console here!"
    if [ "$pi_suppress_stderr" = "y" ]; then
        exec <$M0 >$M1 2>&0
    else 
        exec <$M0 >$M1 2>$M2
    fi
}

boot_hook_add preinit_essential init_console
[root@TrustyArch preinit]# chmod 777 90_init_console
[root@TrustyArch preinit]# rm -f 90_init_console~ 

```
Now restart the BBB, to see if really take effects.     
Also add a new file named 50_choose_console, with the setted M0 and M1, you could get your console.    

```
$ cat 50_choose_console
#!/bin/sh
# Copyright (C) 2006-2010 OpenWrt.org
# Copyright (C) 2010 Vertical Communications

choose_console() {
    # the shell really doesn't like having stdin/out closed
    # that's why we use /dev/pty/m0 and m1 (or equivalent) as replacement
    # for /dev/console if there's no serial console available

    if grep -q devfs /proc/filesystems; then
        M0=/dev/pty/m0
        M1=/dev/pty/m1
        M2=/dev/pty/m1
    elif [ -x /sbin/hotplug2 ]; then
        M0=/dev/ptmx
        M1=/dev/ptmx
        M2=/dev/ptmx
    elif [ -x /sbin/udevd ]; then
        M0=/dev/pty/ptmx
        M1=/dev/pty/ptmx
        M2=/dev/pty/ptmx
    fi
    dd if=/dev/console of=/dev/null bs=1 count=0 >/dev/null 2>/dev/null && {
        M0=/dev/console
        M1=/dev/console
        M2=/dev/console    
    }
}

boot_hook_add preinit_essential choose_console

```
But I still cannot get the terminal.    

