---
layout: post
title: "Android-studio"
date: 2013-09-29 14:11
comments: true
categories: Linux
---
1\.安装步骤   
Yaourt市场里可以直接安装:yaourt android-studio， 编译完后即可直接运行之。  
官方介绍是：基于IntelliJ IDEA的Android开发环境。 最早发布于2013年5月。  
IntelliJ IDEA是JetBrains开发的JAVA IDE. 号称是最好的Java和Polyglot IDE.    
Polyglot是一门计算机语言（或者说是脚本），使用C编写，类似于Lisp, Perl或sh

2\. Todo LIst    
Update android-sdk. because it couldn't be updated behind the proxy.    
如果在防火墙后，更新SDK可能会碰到问题，这时候，到安装android-sdk目录下，输入tools/android，更改Tools->proxy,并使用Force https to https即可    

3\.  Trouble shooting:   
如果提示，不能创建NAND， could not create temp file for system NAND disk image:    
解决方案为: $ sudo chmod 777 /tmp/android-Trusty/




