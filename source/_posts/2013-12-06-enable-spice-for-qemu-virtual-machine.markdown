---
layout: post
title: "Enable spice for qemu virtual machine"
date: 2013-12-06 13:59
comments: true
categories: Linux Qemu
---
###Package Installation
Install virt-viewer for browsing the virtual machine desktop. For default spicec is not OK.

```
	$ pacman -S gtk-vnc
	$ yaourt -S spice-gtk3
	$ yaourt -S virt-viewer
```
Install virt-manager

```
	[root@DashArch Trusty]# pacman -S virt-manager 
	[root@DashArch Trusty]# systemctl start libvirtd.service
	[root@DashArch Trusty]# systemctl enable  libvirtd.service
	ln -s '/usr/lib/systemd/system/libvirtd.service' '/etc/systemd/system/multi-user.target.wants/libvirtd.service'
	[root@DashArch Trusty]# ps -ef | grep libvirt
	root      8852     1  5 15:23 ?        00:00:00 /usr/bin/libvirtd -p /var/run/libvirtd.pid
```

###启动支持spice Server的qemu 
-vga qxl -spice port=5988,disable-ticketing将使能spice

```
	./run-qemu -boot d  -m 1024 -enable-kvm -drive file=./fpgawindows.qcow2,if=ide -drive file=./fake.qcow2,if=virtio -cdrom ./virtio-win-0.1-74.iso -usb -vga qxl -spice port=5988,disable-ticketing -localtime
```
在本地或者远程访问spice server:

```
	$ spice -h 127.0.0.1 -p 5988
```
但是ArchLinux上的X Server会出现问题，具体解决方案未明了。然而在Ubuntu上则是可以顺利访问的。
###启动支持VNC的Qemu

```
	./run-qemu -boot d  -m 1024 -enable-kvm -drive file=./fpgawindows.qcow2,if=ide -drive file=./fake.qcow2,if=virtio -cdrom ./virtio-win-0.1-74.iso -usb -vga std -nographic  -localtime -vnc :33
启动后vncviewer :33则可连接到qemu的窗口
```
###启动Qemu，以std方式
全新启动： 

```
	./run-qemu -boot d  -m 1024 -enable-kvm -drive file=./fpgawindows.qcow2,if=ide -drive file=./fake.qcow2,if=virtio -cdrom ./virtio-win-0.1-74.iso -usb -vga std  -localtime `

```
保存状态： ctl+alt+2

```
	$ savevm booted

```
启动到上一次保存的状态：

```
	$  ./run-qemu -boot d  -m 1024 -enable-kvm -drive file=./fpgawindows.qcow2,if=ide -drive file=./fake.qcow2,if=virtio -cdrom ./virtio-win-0.1-74.iso -usb -vga std  -localtime --loadvm booted

```


