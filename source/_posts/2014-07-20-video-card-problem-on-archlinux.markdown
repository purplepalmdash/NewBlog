---
layout: post
title: "Video Card Problem on ArchLinux"
date: 2014-07-20 10:52
comments: true
categories: 
---
The video card crash problem is caused by acceleration method chosen. My ArchLinux Installed on 2013.06.30, while at that time the default acceleration method is uxa, but now most of it uses sna. So if I choose sna instead of uxa, then problem will be solved.    

```
[Trusty@~]$ cat /var/log/Xorg.0.log | grep -i uxa
[  7841.603] (**) intel(0): Option "AccelMethod" "uxa"
[  7841.638] (II) UXA(0): Driver registered support for the following operations:
[  7841.638] (II) intel(0): Use legacy UXA acceleration.
[Trusty@~]$ vim at /etc/X11/xorg.conf.d/20-intel.conf
2 files to edit
[Trusty@~]$ sudo vim /etc/X11/xorg.conf.d/20-intel.conf
[Trusty@~]$ cat /etc/X11/xorg.conf.d/20-intel.conf
Section "Device"
   Identifier  "Intel Graphics"
   Driver      "intel"
   Option      "AccelMethod"  "sna"
EndSection

```

After Reboot, view the result. :

```
[Trusty@~]$ cat /var/log/Xorg.0.log | grep -i sna
[    73.402] (**) intel(0): Option "AccelMethod" "sna"
[    73.532] (II) intel(0): SNA initialized with Sandybridge (gen6, gt2) backend
[Trusty@~]$ cat /var/log/Xorg.0.log | grep -i uxa

```

Hope crash won't happen again.    
