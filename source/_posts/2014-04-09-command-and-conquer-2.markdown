---
layout: post
title: "Command and Conquer 2"
date: 2014-04-09 08:44:23 +0800
comments: true
categories: C&C
---
###Position
From FullCircle issue 24, to issue 55
###C&C 11
This chapter tells you how to automatical your tasks using crontab.    
Useful commands

```sh cron.sh
	find /var/logs/ -name "*.log" | while read line; do cat "${line}"; done
	sudo crontab -e root

```
crontab format:     
<minute><hour><day><month><day of week><command>    
Example:     
*/5 * * * * command     Every 5 minutes    
00 18 * * sun command   Every Sunday at 6     
* */2 * * * command     Every 2 hours    
Further reading:    
Python version of script for those interested:     
http://lswest.pastebin.com/m5b536464    
Bash script tutorial:    
http://www.linux.org/docs/ldp/howto/Bash-Prog-Intro-HOWTO.html    
Cron tutorial:     
http://www.clickmojo.com/code/cron-tutorial.html    
###C&C 12
This Chapter tells you how to use different shell, and its history, functions.    
###C&C 13
This chapter tell you how to listen music using MOC(Music On Console), and use IRC under terminal(irssi), later I will install them and try.     
###C&C 14
This chapter introduce how to change you prompt,(export PS1), some useful tools, for example:    
"watch vmstat" will display the vmstat every 2 seconds.     
Tiling window manager, awesome, DWM, Xmodnad, ratpoison, ion, etc.     
Live-Office?     
###C&C 15
This chapter take ping for example and show you how to use man and help.     
###C&C 16
This chapter shows how to detect and bind keys.    
xev for X, showkey for terminal, for detecting keys.    
.Xmodmap for key definition,    keycode 153 = XF86MonBrightnessDown    
/usr/include/X11/keysymdef.h contains all of the list of the symbols, extra function keys in /usr/include/X11/XKeySymDB    
Further Reading: http://people.freedesktop.org/~hughsient/quirk/quirk-keymap-index.html    
###C&C 17
This chapter shows disk usage skills.    
###C&C 18
This chapter introduce harddisk and S.M.A.R.T    
###C&C 19
This chapter introduct screen, remember use ctlr+a /d for detaching the session.    
###C&C 20
This chapter continue introducing screen, for sharing session:    
ctrl + a :multiuser on ctrl+a :acladd <ruser>    
Other user connect via screen -x $USER/<screenID/name>    
Other different commands.    
###C&C 21
Introducing Tmux for remote usage.Also byobu is introduced.    
###C&C 22
Switch to ZSH, need to re-read after back.    
###C&C 23
Colorscheme, need to re-read after back.     
###C&C 24
Talks on how to set ssh proxy.     
###C&C 25
gstm of GUI program which did ssh port forwarding.     
diff usage    
###C&C 26
wget and curl, use it according to your own habit.     
###C&C 27
Network Configuration.    
###C&C 28
fdisk, find, etc.     
###C&C 29
Classic Command List.    
###C&C 30
Language for System.     
###C&C 31
conky skills, let conky display how many updates available.     
###C&C 32
Conky skills, his conky could display the listening music and album picture.But how about the pandora?     
###C&C 33
Conky skills, to-do and the zenity for creating the diaglog.    
###C&C 34
zenity configuration, MPD daemon.     
###C&C 35
Asia Language support, in fact we are much more professionaler than the author :)     
###C&C 36
Use of graphicmagic, which derived from imagik from 2002, try it later.    
###C&C 37
Latex Introduction.    
###C&C 38
Issue 51, damaged.    
###C&C 40
Latex continued.     
###C&C 41
/etc/motd(Message Of The Day)     
###C&C 42
vim/gvim, notice some command, and author's vimrc file.     
###C&C 43
Advance usage of vi/vim , TBD    
