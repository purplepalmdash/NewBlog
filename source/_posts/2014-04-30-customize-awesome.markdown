---
layout: post
title: "Customize Awesome"
date: 2014-04-30 21:12
comments: true
categories: awesome
---
###Wallpaper Setting
When switching to big display in awesome, the desktop background will not fill the whole screen, thus we need to automatically set the background when we execute the ./singleview script, ./singleview script is a script which I wrote for switching to big display. Listed as following:    

```
killall conky
xrandr --output LVDS1 --off
xrandr --newmode $(gtf 1680 1050 60 | grep Modeline | sed s/Modeline\ // | tr -d '"')
xrandr --addmode VGA1 1680x1050_60.00
xrandr --output VGA1 --mode 1680x1050_60.00 
xscreensaver -nosplash &
xset -b
xmodmap -e "pointer = 3 2 1"
fcitx &
sleep 4
###Add bluetooth
pactl load-module module-alsa-sink device=btheadset 
pacmd load_module module-bluetooth-discover
###Set Background
feh --bg-scale /home/Trusty/document/water.jpg

```
The last line is the newly-added one which is used for re-setting the background wallpaper.    
###Conky Background Setting
But when you set the background, your conky will become ugly, just like following picture:    
![/images/nobg.jpg](/images/nobg.jpg)    

So you need to set the ~/.conky.rc, add following lines:    

```
own_window yes
own_window_colour 41A834
TEXT
......
${image  /home/Trusty/document/greenleaf2.jpg  -p 0,0 -s 300x540}

```
The "own_window yes" could be commented.    
So now you got conky looks like following:    
![/images/goodbg.jpg](/images/goodbg.jpg)
