---
layout: post
title: "Install Chrome On CentOS"
date: 2015-01-21 20:21
comments: true
categories: linux
---
Until now I failed in installing chrome on CentOS, for the libstdc++ version is too old in the machine, but record the steps here, later I will continue to work on this issue.    
### Repository Preparation
Add following file in to your `/etc/yum.repos.d`:    

```
~% cat /etc/yum.repos.d/google-chrome.repo 
[google-chrome]
name=google-chrome
baseurl=http://dl.google.com/linux/chrome/rpm/stable/$basearch
enabled=1
gpgcheck=1
gpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub

```
Now install the chrome via:    

```
$ sudo yum install google-chrome-stable
	 Processing Dependency: libstdc++.so.6(GLIBCXX_3.4.15)(64bit) for package: google-chrome-stable-40.0.2214.91-1.x86_64
--> Finished Dependency Resolution
Error: Package: google-chrome-stable-40.0.2214.91-1.x86_64 (google-chrome)
           Requires: libstdc++.so.6(GLIBCXX_3.4.15)(64bit)

```
The failure reason is because our libstdc++ version is too old.    

### Check Lib Version
View where is libstdc++:    

```
$ ldconfig -p | grep stdc++
	libstdc++.so.6 (libc6,x86-64) => /usr/lib64/libstdc++.so.6

```
Get the strings which contains LIBCXX in the libstdc++.so.6:    

```
$ strings /usr/lib64/libstdc++.so.6  | grep LIBCXX
GLIBCXX_3.4
GLIBCXX_3.4.1
GLIBCXX_3.4.2
GLIBCXX_3.4.3
GLIBCXX_3.4.4
GLIBCXX_3.4.5
GLIBCXX_3.4.6
GLIBCXX_3.4.7
GLIBCXX_3.4.8
GLIBCXX_3.4.9
GLIBCXX_3.4.10
GLIBCXX_3.4.11
GLIBCXX_3.4.12
GLIBCXX_3.4.13
GLIBCXX_FORCE_NEW
GLIBCXX_DEBUG_MESSAGE_LENGTH

```
We could see the newest version of GLIBCXX is only 3.4.13, while chrome requuires 3.4.15. So the solution should be we install the newer version.    

### Upgrade GLIBCXX
TBD.    
