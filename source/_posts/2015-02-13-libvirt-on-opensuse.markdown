---
layout: post
title: "Libvirt On OpenSuse"
date: 2015-02-13 03:48
comments: true
categories: virtualization
---
In order to try OpenContrail, I installed it on Virtualbox based, but it got failed, I think maybe it's because virtualbox's nested virtualization is not OK. So that's why I have to try libvirt.     
### Installation
Install the virt-manager related software via:    

```
$ sudo zypper install kvm libvirt libvirt-python qemu virt-manager
$ sudo zypper in patterns-openSUSE-kvm_server

```
Now if you directly call virt-manager you will got the following hint:    

```
 error: authentication failed: Authorization requires authentication but no agent is available.
    error: failed to connect to the hypervisor

```
Or if you run `virsh -c qemu:///system` you will got the same hint message.     
Solution is we have to enable the polkit service, add following script:    

```
$ sudo vim /usr/bin/polkitexec
#! /bin/bash

prg=$1

[ "$prg" ] || exec echo "missing argument"
[ -x "$prg" ] || which $prg &>/dev/null || exec echo "program not found: $1"

shift
args=$*

[ `id -u` -eq 0 ] && exec $prg $args

uname -m | grep -q 64 && lib=/usr/lib64 || lib=/usr/lib

if [ "$DESKTOP_SESSION" = "kde" ]; then 
        pga=polkit-kde-authentication-agent-1
        lpga=/usr/$lib/kde4/libexec/$pka
else
        pga=polkit-gnome-authentication-agent-1
        lpga=/usr/lib/$pga
fi

case $DESKTOP_SESSION in
        gnome|gnome-shell|cinnamon*) exec $prg $args ;;
        *) ps nc -C $pga &>/dev/null && exec $prg $args || { [ ! -x $lpga ] && exec echo "program not found: $lpga" || $lpga & $prg $args ;} ;;
esac
$ sudo chmod 777 /sur/bin/polkitexec
$ vim ~/.zshrc
# Wrap virt-manager with polkitexec. 
alias virt-manager='polkitexec virt-manager'

```
Now the virt-manager could be run correctly.    

### Trouble-Shooting
If you met following error, add root to your kvm.conf is OK.      

```
Could not access KVM kernel module: Permission denied
failed to initialize KVM: Permission denied
No accelerator found!

```
First change the priviledge:    

```
#chown root:kvm /dev/kvm

```
Then modify the /etc/libvirt/qemu.conf:    

```
#user="root"
user="root"
#group="root"
group="root"

```
Restart the libvirtd and restart the virt-manager:   

```
#service libvirtd restart

```
Now continue to install OpenContrail.     
