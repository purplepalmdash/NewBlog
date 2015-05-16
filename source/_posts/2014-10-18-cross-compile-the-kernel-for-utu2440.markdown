---
layout: post
title: "Cross-compile the kernel for utu2440"
date: 2014-10-18 16:09
comments: true
categories: embedded
---
### Cross-compiler Preparation
The official documentation said use gcc-3.4.1 for compiling the kernel.     

```
$ cat ~/.zshrc | grep -i set341
alias set341='export PATH=/opt/cross/arm-linux-gcc_3.4.1/bin:$PATH'
$ set341
$ pwd
/media/y/embedded/utu2440/UTU2440-F-T1-20080328/YC2440CDROM_DM9000_080328/utuLinuxfor2440V1.5.8/utu-linux_for_s3c2440_dm9000_V1.5.8
$ arm-linux-gcc -v
Reading specs from /opt/cross/arm-linux-gcc_3.4.1/bin/../lib/gcc/arm-linux/3.4.1/specs
Configured with: /work/crosstool-0.27/build/arm-linux/gcc-3.4.1-glibc-2.3.2/gcc-3.4.1/configure --target=arm-linux --host=i686-host_pc-linux-gnu --prefix=/usr/local/arm/3.4.1 --with-headers=/usr/local/arm/3.4.1/arm-linux/include --with-local-prefix=/usr/local/arm/3.4.1/arm-linux --disable-nls --enable-threads=posix --enable-symvers=gnu --enable-__cxa_atexit --enable-languages=c,c++ --enable-shared --enable-c99 --enable-long-long
Thread model: posix
gcc version 3.4.1

```
### Kernel Compilation
Compile the kernel via:    

```
$ make menuconfig
"Load an Alternate Configuration File"-> config_480272_ts
$ make uImage -j4

```
Trouble shooting: in ArchLinux, install uboot's mkimage tool via:    

```
$ yaourt -S uboot-mkimage

```
After compilation finished, copy it to tftpd server and test:    

```
$ cp arch/arm/boot/uImage /media/nfs/rootfs/
$ ls -l uImage 
-rwxrwxrwx 1 root root 1483696 Oct 19  2014 uImage
$ ls -l s3c_kernel/uImage_T5_480x272_ts 
-rw------- 1 nobody nobody 1483468 Oct 19  2014 s3c_kernel/uImage_T5_480x272_ts

```
We use the compiled kernel and let it runs into the system. Next step we will upgrade the Linux kernel, this may lead to some kernel driver related working.        
Current kernel is:   

```
[root@utu-linux /]# uname -a
Linux utu-linux 2.6.13-utulinux2440 #380 Sat Oct 18 16:14:06 CST 2014 armv4tl unknown

```


