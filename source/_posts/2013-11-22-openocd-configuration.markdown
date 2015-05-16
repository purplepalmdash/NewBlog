---
layout: post
title: "openOCD Configuration"
date: 2013-11-22 20:37
comments: true
categories: Embedded
---
###OpenOCD Device Scan
Install and view the OpenOCD:

```
	$ pacman -S openocd
	[Trusty@XXXyyy debian_octopress]$ openocd -v
	Open On-Chip Debugger 0.7.0 (2013-11-02-01:53)
	Licensed under GNU GPL v2
	For bug reports, read
		http://openocd.sourceforge.net/doc/doxygen/bugs.html

```
Insert your openJTAG debug board, and view its connection:

```
	[Trusty@XXXyyy debian_octopress]$ lsusb
	Bus 001 Device 016: ID 1457:5118 First International Computer, Inc. OpenMoko Neo1973 Debug board (V2+)

```
From the dmesg information:

```
	[15767.673553] usb 1-1: new full-speed USB device number 11 using xhci_hcd
	[15767.695990] usb 1-1: Device not responding to set address.
	[15767.938262] usb 1-1: Device not responding to set address.
	[15768.140725] usb 1-1: device not accepting address 11, error -71
	[15768.421057] usb 1-1: new full-speed USB device number 13 using xhci_hcd
	[15769.015800] usbcore: registered new interface driver usbserial
	[15769.016012] usbcore: registered new interface driver usbserial_generic
	[15769.016075] usbserial: USB Serial support registered for generic
	[15769.020028] usbcore: registered new interface driver ftdi_sio
	[15769.020050] usbserial: USB Serial support registered for FTDI USB Serial Device
	[15769.020458] usb 1-1: Ignoring serial port reserved for JTAG
	[15769.020499] ftdi_sio 1-1:1.1: FTDI USB Serial Device converter detected
	[15769.020544] usb 1-1: Detected FT2232C
	[15769.020548] usb 1-1: Number of endpoints 2
	[15769.020550] usb 1-1: Endpoint 1 MaxPacketSize 64
	[15769.020553] usb 1-1: Endpoint 2 MaxPacketSize 64
	[15769.020555] usb 1-1: Setting MaxPacketSize 64
	[15769.026647] usb 1-1: FTDI USB Serial Device converter now attached to ttyUSB0
	[15975.012193] usb 1-1: USB disconnect, device number 13
	[15975.012449] ftdi_sio ttyUSB0: FTDI USB Serial Device converter now disconnected from ttyUSB0
	[15975.012465] ftdi_sio 1-1:1.1: device disconnected
	[15975.270658] usb 1-1: new full-speed USB device number 14 using xhci_hcd
	[15975.355869] usb 1-1: Ignoring serial port reserved for JTAG
	[15975.366867] ftdi_sio 1-1:1.1: FTDI USB Serial Device converter detected
	[15975.366902] usb 1-1: Detected FT2232C
	[15975.366904] usb 1-1: Number of endpoints 2
	[15975.366906] usb 1-1: Endpoint 1 MaxPacketSize 64
	[15975.366908] usb 1-1: Endpoint 2 MaxPacketSize 64
	[15975.366909] usb 1-1: Setting MaxPacketSize 64
	[15975.371933] usb 1-1: FTDI USB Serial Device converter now attached to ttyUSB0
	[16608.914153] usb 1-1: USB disconnect, device number 14
	[16608.914371] ftdi_sio ttyUSB0: FTDI USB Serial Device converter now disconnected from ttyUSB0
	[16608.914402] ftdi_sio 1-1:1.1: device disconnected
	[16609.394763] usb 1-1: new full-speed USB device number 15 using xhci_hcd
	[16609.395097] usb 1-1: Device not responding to set address.
	[16609.598734] usb 1-1: Device not responding to set address.
	[16609.801899] usb 1-1: device not accepting address 15, error -71
	[16609.962045] usb 1-1: new full-speed USB device number 16 using xhci_hcd
	[16609.962371] usb 1-1: Device not responding to set address.
	[16610.250376] usb 1-1: Ignoring serial port reserved for JTAG
	[16610.261380] ftdi_sio 1-1:1.1: FTDI USB Serial Device converter detected
	[16610.261428] usb 1-1: Detected FT2232C
	[16610.261431] usb 1-1: Number of endpoints 2
	[16610.261433] usb 1-1: Endpoint 1 MaxPacketSize 64
	[16610.261435] usb 1-1: Endpoint 2 MaxPacketSize 64
	[16610.261437] usb 1-1: Setting MaxPacketSize 64
	[16610.266397] usb 1-1: FTDI USB Serial Device converter now attached to ttyUSB0

```
From the above information we could know, Now we have a new Serial port named ttyUSB0, and also a FT2232C debug port. Currently we don't use Serial Port, FT2232 is all we want to configure. 
###OpenOCD Configuration
We have to make a cfg file for OpenOCD to use. There are some pre-defined configuration files for us to refer under the directory of "/usr/share/openocd/scripts/", since we know the debug board information and we know exactly the development board info, we can easily write our own OpenOCD startup scripts.   
Get the interface definition via:

```
	[Trusty@XXXyyy interface]$ pwd
	/usr/share/openocd/scripts/interface
	[Trusty@XXXyyy interface]$ grep "1457" ./ -r
	./neodb.cfg:ft2232_vid_pid 0x1457 0x5118
	./ftdi/neodb.cfg:ftdi_vid_pid 0x1457 0x5118

```
So we directly copy the neodb.cfg to our openocd.cfg under our home directory. But the usb name of our OpenOCD is changed, 

```
	ft2232_device_desc "USB<=>JTAG&RS232

```
The definition is taken from the output of "lsusb -v -d 1457:5118"    


We also want to define the port for telnet and gdb connection 

```
	#########daemon configuration####
	telnet_port 4444
	gdb_port 3333


```
The Target configuration is taken from the /usr/share/openocd/scripts/target/stm32f1x.cfg, which is the definition of the stm32f1x. Copy them directly to your own config file.     

Finally your configuration file should be listed as:

```linux-config openocd.cfg

#########daemon configuration####
telnet_port 4444
gdb_port 3333

########Interface Info###########
################################################
# Since our board takes the same vid_pid
# We directly use openmoko's definition.
################################################
#
# Openmoko USB JTAG/RS232 adapter
#
# http://wiki.openmoko.org/wiki/Debug_Board_v3
#
interface ft2232
ft2232_device_desc "USB<=>JTAG&RS232"
ft2232_layout jtagkey
ft2232_vid_pid 0x1457 0x5118

########Board Info###########
# Adjust Work-area size (RAM size) according to MCU in use:
#STM32F103VC --> 48KB
#STM32F103RB --> 20KB
#set WORKAREASIZE 0x5000
# STM32F103RE --> 64KB
# set WORKAREASIZE 0x10000

# reset_config parameter (see OpenOCD manual):
# none --> srst and trst of MCU not connected to JTAG device
# srst_only --> only srst of MCU connected to JTAG device
# trst_only --> only trst of MCU connected to JTAG device
# srst_and_trst --> srst and trst of MCU connected to JTAG device
# default setting: "reset_config none" will produce a single reset via SYSRESETREQ (JTAG commands) at reset pin of MCU
#reset_config none


#script for stm32f1x family

if { [info exists CHIPNAME] } {
   set _CHIPNAME $CHIPNAME
} else {
   set _CHIPNAME stm32f1x
}

if { [info exists ENDIAN] } {
   set _ENDIAN $ENDIAN
} else {
   set _ENDIAN little
}

# Work-area is a space in RAM used for flash programming
# By default use 16kB
if { [info exists WORKAREASIZE] } {
   set _WORKAREASIZE $WORKAREASIZE
} else {
   set _WORKAREASIZE 0x4000
}

# JTAG speed should be <= F_CPU/6. F_CPU after reset is 8MHz, so use F_JTAG = 1MHz
adapter_khz 1000

adapter_nsrst_delay 100
jtag_ntrst_delay 100

#jtag scan chain
if { [info exists CPUTAPID] } {
   set _CPUTAPID $CPUTAPID
} else {
  # See STM Document RM0008
  # Section 26.6.3
   set _CPUTAPID 0x3ba00477
}
jtag newtap $_CHIPNAME cpu -irlen 4 -ircapture 0x1 -irmask 0xf -expected-id $_CPUTAPID

if { [info exists BSTAPID] } {
   # FIXME this never gets used to override defaults...
   set _BSTAPID $BSTAPID
} else {
  # See STM Document RM0008
  # Section 29.6.2
  # Low density devices, Rev A
  set _BSTAPID1 0x06412041
  # Medium density devices, Rev A
  set _BSTAPID2 0x06410041
  # Medium density devices, Rev B and Rev Z
  set _BSTAPID3 0x16410041
  set _BSTAPID4 0x06420041
  # High density devices, Rev A
  set _BSTAPID5 0x06414041
  # Connectivity line devices, Rev A and Rev Z
  set _BSTAPID6 0x06418041
  # XL line devices, Rev A
  set _BSTAPID7 0x06430041
  # VL line devices, Rev A and Z In medium-density and high-density value line devices
  set _BSTAPID8 0x06420041
  # VL line devices, Rev A
  set _BSTAPID9 0x06428041

}
jtag newtap $_CHIPNAME bs -irlen 5 -expected-id $_BSTAPID1 \
	-expected-id $_BSTAPID2 -expected-id $_BSTAPID3 \
	-expected-id $_BSTAPID4 -expected-id $_BSTAPID5 \
	-expected-id $_BSTAPID6 -expected-id $_BSTAPID7 \
	-expected-id $_BSTAPID8 -expected-id $_BSTAPID9

set _TARGETNAME $_CHIPNAME.cpu
target create $_TARGETNAME cortex_m -endian $_ENDIAN -chain-position $_TARGETNAME

$_TARGETNAME configure -work-area-phys 0x20000000 -work-area-size $_WORKAREASIZE -work-area-backup 0

# flash size will be probed
set _FLASHNAME $_CHIPNAME.flash
flash bank $_FLASHNAME stm32f1x 0x08000000 0 0 0 $_TARGETNAME

# if srst is not fitted use SYSRESETREQ to
# perform a soft reset
cortex_m reset_config sysresetreq

```




```

[root@XXXyyy target]# openocd -f /media/y/embedded/stm32/dev/openocd.cfg -f ./stm32f1x.cfg 

```
