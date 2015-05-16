---
layout: post
title: "Wireless on PogoPlug"
date: 2013-10-26 10:16
comments: true
categories: Linux Pogoplub
---
###Hardware Preparation
Insert the usb wireless card and view the dmesg information:

```
	$ dmesg | tail
	[911884.740000] usb 1-1.3: USB disconnect, device number 4
	[911897.530000] usb 1-1.4: new high speed USB device number 5 using oxnas-ehci
	[911897.640000] usb 1-1.4: New USB device found, idVendor=0bda, idProduct=8179
	[911897.640000] usb 1-1.4: New USB device strings: Mfr=1, Product=2, SerialNumber=3
	[911897.650000] usb 1-1.4: Product: 802.11n NIC
	[911897.650000] usb 1-1.4: Manufacturer: Realtek
	[911897.660000] usb 1-1.4: SerialNumber: 00E04C0001
The model is Mercury FW150US, See details of the lsusb
	$ lsusb -v -d 0bda:8179
	Bus 001 Device 005: ID 0bda:8179 Realtek Semiconductor Corp. 
	......
```

But the output didn't show its information, we google it, knows:   
只是一个8176和8179之分，后来才知道原来这款瑞昱的芯片有两个版本，8176对应的是rtl8192cu，8179对应的是rtl8188eu。   
8179 is the rtl8188eu, so we need to find rtl8188eu device driver.   
###Driver Preparation
Prepare the cross-compiler, download "gcc-linaro-arm-linux-gnueabi-2012.02-20120222_linux.tar.bz2", uncompress it and add it into your system path.    
Prepare the Linux source code, named "linux-3.1.10.pogoplug.tar.bz2", uncompress it.    
How do we get the cross-compiler version?  

```
	$ cat /proc/version
	Linux version 3.1.10 (lintel@lintel-ThinkPad-T430) (gcc version 4.6.3 20120201 (prerelease) (Linaro GCC 4.6-2012.02) ) #10 SMP PREEMPT Fri Jun 7 19:14:08 CST 2013
```

From the result, we know the cross-compiler is 4.6.3 version.   
Download the corresponding cross-compiler and add it to the sytem path. Then we download the PogoPlug Linux Source, uncompress it and also get the rtl8188eu from [https://github.com/Red54/linux-shumeipai2/tree/sunxi-3.0/drivers/net/wireless/rtl8188eu](https://github.com/Red54/linux-shumeipai2/tree/sunxi-3.0/drivers/net/wireless/rtl8188eu "GitHub Driver Download"), copy the rtl8188eu's driver under driver/net/wireless, then modify the Kconfig file:  

```
	\+source "drivers/net/wireless/rtl8192cu/Kconfig"
	source "drivers/net/wireless/rtl8188eu/Kconfig"
```

and also the Makefile:

```
	obj-$(CONFIG_RTL8192CU)  += rtl8192cu/
	\+obj-$(CONFIG_RTL8188EU)  += rtl8188eu/
	obj-$(CONFIG_IPW2100) += ipw2x00/
	obj-$(CONFIG_IPW2200) += ipw2x00/
```

Then, we get the running kernel's configuration file via:

```
	cat /proc/config.gz | gunzip >running.config
```

upload the configuration file to the directory of the kernel source, then

```
	$ export ARCH=arm
	$ export CROSS_COMPILE=arm-linux-gnueabi-
	$ make  ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- menuconfig
	in menuconfig, load the running.config, then navigate to driver->net->wireless, choose rtl8188eu's driver, compile it to kernel
	$ make  ARCH=arm CROSS_COMPILE=arm-linux-gnueabi-
	$ sudo yaourt mkimage
	Install mkimage, then go to arch/arm/boot
	$ mkimage -n 'linux-3.1.10' -A arm -O linux -T kernel -C none -a 0x60008000 -e 0x60008000 -d zImage uImage
```

upload the generated uImage to pogoplug, then we have to update the kernel image into our own image

```
	# Install mtd-utils first
	$ apt-get install mtd-utils
	# Erase the mtd partition which contains existing kernel
	$ /usr/sbin/flash_erase /dev/mtd1 0xB00000 22
	# Write newly generated uImage into the mtd partition
	$ /usr/sbin/nandwrite -p -s 0xB00000 /dev/mtd1 /root/uImage	
```

Reboot the pogoplug.
###Wireless Configuration
On pogoplug, install following software:

```
	$ apt-get install iw wireless-tools 
```

Use wpa_supplicant to generate the configuraiton file and generate the password

```
	wpa_supplicant -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf
	wpa_passphrase NETGEAR79 xxxxxx > /etc/wpa_supplicant/NETGEAR79.conf
```

With the generated file we can directly connect to the exisint wireless network.   
Then we have to update the network configration file,  

```
	$ vim /etc/network/interfaces
	auto lo eth0
	iface lo inet loopback
	iface eth0 inet dhcp
	
	auto wlan0
	allow-hotplug wlan0
	iface wlan0 inet dhcp
	wpa-conf /etc/wpa_supplicant/NETGEAR79.conf
```

After everything is done, we can remove the wired connection, and change the wired-bind ip address to wireless binded ip address, everything will be the same as before. But the bootup may be 1 or 2 seconds than the wired connection. 	
