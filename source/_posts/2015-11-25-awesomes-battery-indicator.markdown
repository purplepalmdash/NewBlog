---
layout: post
title: "Awesome's Battery Indicator"
date: 2015-11-25 12:18:29 +0800
comments: true
categories: Linux
---
### Background
I installed ArchLinux+Awesome On my SurfacePro, while the charger of Surface Pro is not
so tight to the pad. Thus I have to use a battery indicator in Awesome.     
### Software
Refers to:     

[http://www.everythingisvoid.com/uncategorized/simple-battery-status-indicator-awesome-window-manager](http://www.everythingisvoid.com/uncategorized/simple-battery-status-indicator-awesome-window-manager)     

Install steps on ArchLinux:    

```
$ sudo pacman -S luarocks5.1 gobject-introspection acpi
$ sudo luarocks-5.1 install battery_status
```

You could manually run `show_battery_status` or add it into your own rc.lua file:     

```
$ vim ~/.config/awesome/rc.lua
----.....................
autorunApps =
{
--.........
"synergyc 192.168.0.119",
"sudo echo 1240>/sys/class/backlight/intel_backlight/brightness", 
"fcitx",
"show_battery_status", 
----.....................
```

Now restart the awesome you could see the battery indicator.     

### Add Charging Indicator
First download the source code from github:    

```
$ git clone https://github.com/svarogg/battery_status
```

Debug with luarocks loader:    

```
rocks-5.1   lua5.1 -lluarocks.loader
Lua 5.1.5  Copyright (C) 1994-2012 Lua.org, PUC-Rio
> require("rex_posix")
> rex = require("rex_posix")
> battery_rex = rex.new([[([^,]{1,3})%]])
> rex=require("rex_posix")
> battery_rex=rex.new([[([^,]{1,3})%]])
> acpi=io.popen('acpi 2>&1')
> acpi_res = acpi:read("*line")
> acpi:close()
> print (acpi_res)
Battery 0: Full, 100%
> percentage=battery_rex:match(acpi_res)
> print (percentage)
100
> print(type(percentage))
string
> print(type(tonumber(percentage)))
number
> adapter = io.popen('acpi -a 2>&1')
> adapter_res = adapter:read("*line")
> adapter:close()
> print(adapter_res)
Adapter 0: on-line
> charge_rex = rex.new([[(on|off)]])
> print(charge_rex:match(adapter_res))
on
```

We get the status of the charge, then update the corresponding icon to the systray.   

The modified repository could be fetched from:    

[https://github.com/purplepalmdash/Awesome-Battery-Indicator](https://github.com/purplepalmdash/Awesome-Battery-Indicator)    
