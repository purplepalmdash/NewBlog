---
layout: post
title: "tftpd on ubuntu"
date: 2014-10-18 15:24
comments: true
categories: linux
---
For updating the kernel on s3c2440 board, I have to setup the tftpd server.    
### tftpd server
Install tfpd-hpa:    

```
sudo apt-get install tftpd-hpa

```
Setup the directory name and edit the /etc/default/tftpd-hpa:    

```
root@joggler:/etc# cat /etc/default/tftpd-hpa 
# /etc/default/tftpd-hpa

TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/media/nfs/rootfs"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="--secure"

```
Then restart the server:    

```
service tftpd-hpa restart

```
Other commands:    

```
service tftpd-hpa status
service tftpd-hpa stop
service tftpd-hpa start
service tftpd-hpa restart
service tftpd-hpa force-reload

```
### Testing
In the same machine, use following commands for testing the tftpd server(Make sure you have the get.txt under the root directory of your tftpd specified directory):    

```
$ tftp localhost
tftp> get get.txt
tftp> quit

```
### utu2440 
Test the utu2440's load_kernel function.     
Copy the corresponding kernel file in tftpd server:    

```
$ cp s3c_kernel/uImage_T5_480x272_ts ./uImage
$ chmod 777 uImage

```
First set the ipaddr for utu2440's uboot:     

```
utu-bootloader=>>>setenv ipaddr 10.0.0.15
utu-bootloader=>>>ping 10.0.0.1
dm9000 i/o: 0x18000300, id: 0x90000a46 
MAC: 00:0c:20:02:0a:5b
host 10.0.0.1 is alive

```
then set the server's address to 10.0.0.11(that's joggler with tftpd server enabled), use `printenv` for inspecting your configuration:    

```
utu-bootloader=>>>setenv ipaddr 10.0.0.15
utu-bootloader=>>>printenv
ipaddr=10.0.0.15
serverip=10.0.0.11

```
View the embedded 'install-kernel' command:    

```
utu-bootloader=>>>printenv
install-kernel=tftp 30000000 uImage;nand erase 60000 200000;nand write.i 30000000 60000 0
utu-bootloader=>>>run install-kernel
dm9000 i/o: 0x18000300, id: 0x90000a46 
MAC: 00:0c:20:02:0a:5b
TFTP from server 10.0.0.11; our IP address is 10.0.0.15
Filename 'uImage'.
Load address: 0x30000000
Loading: #################################################################
         #################################################################
         #################################################################
         #################################################################
         ##############################
done
Bytes transferred = 1483468 (16a2cc hex)

NAND erase: device 0 offset 0x60000, size 0x200000
Erasing at 0x25c000 -- 100% complete.
OK

NAND write: device 0 offset 0x60000, size 0x0

Writing data at 0x1ca200 -- 100% complete.
 1483776 bytes written: OK
utu-bootloader=>>>boot

```
Yes now you could compile your own kernel for utu2440.    


