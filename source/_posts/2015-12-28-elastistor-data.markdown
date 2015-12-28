---
layout: post
title: "elastistor data"
date: 2015-12-28 22:01:03 +0800
comments: true
categories: 
---
Using NFS for testing.    

```
dash@agent:/sdb4$ echo "iops 5"
iops 5
dash@agent:/sdb4$ time cp Kinetis\ SDK\ 1.3.0\ Mainline\ -\ Windows.exe /mnt/

real    1m1.908s
user    0m0.002s
sys     0m0.156s
dash@agent:/sdb4$ time cp Kinetis\ SDK\ 1.3.0\ Mainline\ -\ Windows.exe /mnt/2.exe

real    0m59.375s
user    0m0.001s
sys     0m0.154s
dash@agent:/sdb4$ rm -f /mnt/
2.exe                                     Kinetis SDK 1.3.0 Mainline - Windows.exe  
dash@agent:/sdb4$ rm -f /mnt/*
dash@agent:/sdb4$ echo "iops 50"
iops 50
dash@agent:/sdb4$ time cp Kinetis\ SDK\ 1.3.0\ Mainline\ -\ Windows.exe /mnt/2.exe

real    0m29.177s
user    0m0.001s
sys     0m0.144s
dash@agent:/sdb4$ time cp Kinetis\ SDK\ 1.3.0\ Mainline\ -\ Windows.exe /mnt/

real    0m29.798s
user    0m0.002s
sys     0m0.146s
dash@agent:/sdb4$ rm -f /mnt/*
dash@agent:/sdb4$ echo "iops 2"
iops 2
dash@agent:/sdb4$ time cp Kinetis\ SDK\ 1.3.0\ Mainline\ -\ Windows.exe /mnt/2.exe

real    2m26.402s
user    0m0.002s
sys     0m0.151s
dash@agent:/sdb4$ time cp Kinetis\ SDK\ 1.3.0\ Mainline\ -\ Windows.exe /mnt/

real    2m24.976s
user    0m0.002s
sys     0m0.142s

```
