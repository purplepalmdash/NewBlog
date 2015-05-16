---
layout: post
title: "DXG ScreenSaver Hack"
date: 2014-04-22 20:12
comments: true
categories: dxg
---
First, download the ScreenSavers hacker form:    
[http://www.mobileread.com/forums/showthread.php?t=88004](http://www.mobileread.com/forums/showthread.php?t=88004)    
And unzip this file, copy the "Update_ss_0.43.N_dxg_install.bin" to the root directory of Kindle. 


Then In kindle, [HOME] -> [MENU] > Settings -> [MENU] > Update Your Kindle. The DXG will automatically reboot.    
Now mount the DXG into your computer, touch the "last" file under the linkss folder, as:    

```
	[root@XXXyyy mnt]# cd linkss/
	[root@XXXyyy linkss]# ls
	auto        backups  cover_cache  info.txt          overflow  screensavers
	autoreboot  bin      etc          mounted_824x1200  run
	[root@XXXyyy linkss]# touch last

```
Now reboot your Kindle Again, your Kindle will remain the last read page as the ScreenSaver.    
