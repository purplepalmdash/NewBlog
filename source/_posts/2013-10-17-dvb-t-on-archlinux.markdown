---
layout: post
title: "DVB-T on ArchLinux"
date: 2013-10-17 10:20
comments: true
categories: Linux
---
First we have to get the description of the DVB-T USB stick, use lsusb will get the result of the inserted DVB Disk:  

```
	$ lsusb
	Bus 002 Device 004: ID 0bda:2838 Realtek Semiconductor Corp. RTL2838 DVB-T
Also we can check the demsg information to get the DVB-T stick information:  
	[44867.951615] usb 2-2: new high-speed USB device number 4 using xhci_hcd
	[44868.345834] usbcore: registered new interface driver dvb_usb_rtl28xxu
	[44868.345912] usb 2-2: dvb_usb_v2: found a 'Realtek RTL2832U reference design' in warm state
	[44868.416639] usb 2-2: dvb_usb_v2: will pass the complete MPEG2 transport stream to the software demuxer
	[44868.416662] DVB: registering new adapter (Realtek RTL2832U reference design)
	[44868.537249] usb 2-2: DVB: registering adapter 0 frontend 0 (Realtek RTL2832 (DVB-T))...
	[44868.543138] r820t 9-001a: creating new instance
	[44868.555987] r820t 9-001a: Rafael Micro r820t successfully identified
	[44868.563544] Registered IR keymap rc-empty
	[44868.563698] input: Realtek RTL2832U reference design as /devices/pci0000:00/0000:00:1c.7/0000:25:00.0/usb2/2-2/rc/rc0/input33
	[44868.563806] rc0: Realtek RTL2832U reference design as /devices/pci0000:00/0000:00:1c.7/0000:25:00.0/usb2/2-2/rc/rc0
	[44868.566081] usb 2-2: dvb_usb_v2: schedule remote query interval to 400 msecs
	[44868.581802] usb 2-2: dvb_usb_v2: 'Realtek RTL2832U reference design' successfully initialized and connected
```

Now we can check whtether DVB-T stick works:

```
	[root@XXXyyy ~]# ls /dev/v4l
	by-id  by-path
	[root@XXXyyy ~]# ls /dev/dvb
	adapter0
```

To get the first digital signal, we have to install linuxtv-dvb-apps

```
	# pacman -S linuxtv-dvb-apps
```


