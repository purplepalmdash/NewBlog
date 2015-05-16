---
layout: post
title: "Tips For Mac"
date: 2014-11-22 17:37
comments: true
categories: mac
---
### Set Proxy
The proxy setting method is the same as in Linux, just add following lines into the ~/.bashrc:    

```
# Set the proxy
alias unsethome='unset http_proxy https_proxy ftp_proxy ftps_proxy'
alias set2383='unsethome;export http_proxy=http://xxx.xx.xx238:2383;export https_proxy=http://xxx.xx.xx238:2383;export ftp_proxy=http://xxx.xx.xx238:2383;export ftps_proxy=http://xxx.xx.xx238:2383'

```
So next time simply run `set2383` then you could set the proxy for terminal based programs.    
### Package Management
brew is a very good package management tool for MAC, install it via:    

```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

```
Install packages like following:    

```
$ brew install wget

```
After installation the wget becomes available for using:    

```
Yosemite:~ Trusty$ which wget
/usr/local/bin/wget

```
### Brew Installed Packages
Use brew to install frequently used tools:    

```
$ brew install wget tree

```
### Git Configuration For Proxy
Since I worked under the proxy in office, so I need to configure a tunnel which could makes me go through the firewall:    

```
Yosemite:Code Trusty$ git config --global user.name "xxxx"
Yosemite:Code Trusty$ git config --global user.email "xxxx@gmail.com"
Yosemite:Code Trusty$ cat ~/.gitconfig
[user]
	name = xxx
	email = xxx@gmail.com

```
Compile the connect.c via:    

```
$ pwd
/Users/Trusty/Code/proxy
$ gcc -o connect connect.c

```
Configure the file via:   

```
Yosemite:proxy Trusty$ cat sock5.sh
#!/bin/bash
/Users/Trusty/Code/proxy/connect -H 1xx.x.xx.2xx:2xxx "$@"
Yosemite:proxy Trusty$ chmod 777 *

```
Add the following part in your ~/.gitconfig:    

```
[core]
	gitproxy = /Users/Trusty/Code/proxy/socks5.sh

```
Now open a new terminal and git from a test repository via:    

```
$ git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git linux-git
Cloning into 'linux-git'...
remote: Counting objects: 3857384, done.
remote: Compressing objects: 100% (5000/5000), done.
^Cfatal: index-pack failed95/3857384), 436.00 KiB | 152.00 KiB/s

```
See? You really acrossed the firewall and reached Linus Torvalds' git tree.    

### iterms2 Colorscheme
Default iterm2 is ugly, so we need to download the good style of colorschemes,     
[iterm2colorschemes.com](iterm2colorschemes.com)     
Also you could select whatever you like from the screen-shots.     
Hit cmd+i then you got whatever you want import.  

### sudo tips
For keeping the current environment, just do following:    

```
$ sudo visudo
Defaults	env_keep += "http_proxy https_proxy ftp_proxy ftps_proxy"

```
Restart or open a new terminal, now your sudo command won't fail because of the proxy configuration.   
### Make Alias to Chromium 
The default installation of applications in mac maybe at the random place, so we have to make alias for whatever application we want to call in shell, like following:    

```
alias chromium="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome 2>/dev/null"

```
So next time you could directly call `chromium` for testing. Notice, `2>/dev/null` means we don't care about the stderr out.     

### Call Console in Chromium
Simply call cmd+opt+i, mapping to keyboard is win+alt+i.     

### List Disk Usage
Since "fdisk -l" is illegal options in MACOS, we have to use following command for displaying the disk usage:    

```
$ diskutil list
/dev/disk0
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *64.0 GB    disk0
   1:                        EFI EFI                     209.7 MB   disk0s1
   2:          Apple_CoreStorage                         63.2 GB    disk0s2
   3:                 Apple_Boot Recovery HD             650.0 MB   disk0s3
/dev/disk1
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:                  Apple_HFS Hard                   *62.8 GB    disk1
                                 Logical Volume on disk0s2
                                 FBBDE745-2F1F-4B7A-8870-A9031F6E24CD
                                 Unencrypted

```

### Wallpapers
macOSx have lots of wallpapers, we could fetch it via:    

```
scp -r /Library/Desktop\ Pictures/ xxx@10.0.0.221:/home/xxx

```
Then all of the pictures are now in remote machines.   

### updatedb
For equivalent to Linux's updatedb, simply run:    

```
sudo /usr/libexec/locate.updatedb

```

