---
layout: post
title: "Moving From Working PC to Own USB-Disk Based 6"
date: 2014-05-26 08:00
comments: true
categories: linux
---
### Kernel
As for i686 only support 4GB at most memory, we have to change the existing memory into a new one. PAE based kernel will support up to 64GB memory, so we upgrade our kernel to this one:     

```
yaourt -S linux-pae

```
Building will take for a while, two tips is:    
1. Change the building directory from `TMPDIR="/tmp"` to `TMPDIR=/real_file_system`, this configuration file is /etc/makepkg.conf.     
2. Add the `MAKEFLAGS="-j6"`, this will speed-up the building procedure.    

### FCITX
We have to set following variables, in /etc/locale.conf:    

```
# Enable UTF-8 with Australian settings.
LANG="en_US.UTF-8"

# Keep the default sort order (e.g. files starting with a '.'
# should appear at the start of a directory listing.)
LC_COLLATE="C"

# Set the short date to YYYY-MM-DD (test with "date +%c")
LC_TIME="en_US.UTF-8"

```
Then we install the googlepinyin input method via:   

```
sudo pacman -S fcitx-googlepinyin

```
Now hit `CTRL+SPACE` you can call the goolgepinyin out.    

### Some Other Tools
Install strace for tracing the program:   

```
sudo pacman -S strace

```
flash-plugins:   

```
sudo pacman -S flashplugin

```
quazilla, another browser:    

```
sudo pacman -S qupzilla

```
When writing octopress based blogs, you will face .rvmrc cannot executed, then enable the terminal emulator's setting, change it as `run as login shell`.    

Some more tips will be added later. 
