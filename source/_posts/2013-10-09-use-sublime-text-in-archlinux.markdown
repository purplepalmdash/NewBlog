---
layout: post
title: "Use sublime-text in ArchLinux"
date: 2013-10-09 19:11
comments: true
categories: Linux
---
1\. Install Sublime-text in ArchLinux:    

```
	$ pacman -S sublime-text
```

2\. Now we could install the package control from the [https://sublime.wbond.net/installation](https://sublime.wbond.net/installation).    
After installed the package control, sublime-text should be reboot for make package control to be used.    

3\. Install stino for Arduino development. You can refer to [https://github.com/Robot-Will/Stino](https://github.com/Robot-Will/Stino).   
Beware that Preferences should be set to the corresponding directory, and because Arduino upload uses the ttyUSB device, you'd better use Sublime under root priviledge(directly use root or use sudo subl).       

4\. To enable vim-like operation, you have to do the following steps:    
a\. Under Preference-->Settings-->Default: Change the "ignored_packages":["Vintage"] into "ingonored_packages":[]      
b\. Under Preference-->Settings-->User, Change:     

```
	{
		"ignored_packages":
		[
			"Vintage"
		],
	}
```

into

```
	{
		"ignored_packages":
		[
			//"Vintage"
		],
		"vintage_ctrl_keys": true,
		"vintage_start_in_command_mode": true
	}
```

5\. Now you can enjoy your sublime, but beware that some vim-link items should be enhanced. 
