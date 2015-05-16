---
layout: post
title: "Graphic Card On ArchLinux"
date: 2014-06-24 09:52
comments: true
categories: archlinux
---
Since I got several Intel powered PC, It's is essential to know how graphics card works, thus I could get the fastest performance of my PC or Server.    
### Detect Graphics Card
Use lspci we could get the output of all PCI equipments, get the VGA related information via:   

```
$ lspci | grep VGA
00:02.0 VGA compatible controller: Intel Corporation 2nd Generation Core Processor Family Integrated Graphics Controller (rev 09)

```
To know the detailed information of this equipment:     

```
$ lspci -v -s 00:02.0
00:02.0 VGA compatible controller: Intel Corporation 2nd Generation Core Processor Family Integrated Graphics Controller (rev 09) (prog-if 00 [VGA controller])
	Subsystem: Hewlett-Packard Company Device 161c
	Flags: bus master, fast devsel, latency 0, IRQ 57
	Memory at d4000000 (64-bit, non-prefetchable) [size=4M]
	Memory at c0000000 (64-bit, prefetchable) [size=256M]
	I/O ports at 4000 [size=64]
	Expansion ROM at <unassigned> [disabled]
	Capabilities: <access denied>
	Kernel driver in use: i915
	Kernel modules: i915

```
`Memory at c0000000 (64-bit, prefetchable) [size=256M]` shows the Intel Video Card with 256MB of video RAM. Or you can get the detailed via : ` sudo lspci -v  | more `.     

If you want the graphic ways, simply install following tool:   

```
$ sudo pacman -S hardinfo
$ hardinfo

```
The picture shows as following:    

![/images/hardinfo.jpg](/images/hardinfo.jpg)    

lshw could also shows the result:    

```
$ sudo lshw -class display
  *-display               
       description: VGA compatible controller
       product: 2nd Generation Core Processor Family Integrated Graphics Controller
       vendor: Intel Corporation
       physical id: 2
       bus info: pci@0000:00:02.0
       version: 09
       width: 64 bits
       clock: 33MHz
       capabilities: msi pm vga_controller bus_master cap_list rom
       configuration: driver=i915 latency=0
       resources: irq:57 memory:d4000000-d43fffff memory:c0000000-cfffffff ioport:4000(size=64)

```

### Get the config from Intel Doc
Refer to following link:    
[http://en.wikipedia.org/wiki/Comparison_of_Intel_graphics_processing_units](http://en.wikipedia.org/wiki/Comparison_of_Intel_graphics_processing_units), for example, My cpu is Intel(R) Core(TM) i5-2520M , then find the "Core i5-2xxxM", it shows the graphic card is HD Graphics 3000.   

### Configure Intel Graphics Card
Install driver:   

```
$ sudo pacman -S xf86-video-intel

```
32-bit 3D Support:

```
$ sudo pacman -S lib32-intel-dri

```


