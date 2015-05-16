---
layout: post
title: "Adding Battery Widget and ACPI Notification in Awesome"
date: 2014-02-18 15:00
comments: true
categories: 
---
For keeping the "Clean Desktop", the cleaner in my office unpluged my laptop's powerline, and the laptop suddenly going to black when I was coding, so I want to write some scripts for calculating the battery's power percentage and got notification when the power of the battery is too low. <br />
###Add an indicator in Awesome Desktop
Awesome have a very good 3rd-party library called "Vicious", its page is at[http://awesome.naquadah.org/wiki/Vicious](http://awesome.naquadah.org/wiki/Vicious), following the guideline for install and configure it.<br />
Install the library: 

```
	$ cd ~/.config/awesome
	$ git clone http://git.sysphere.org/vicious

```
Modify the rc.lua to add following lines:

```lua rc.lua
-- Using vicious
-- Vicious is a modular widget library for awesome, derived from the Wicked widget library. 
vicious = require("vicious")

-- Add the Battery 
mybattery = wibox.widget.textbox()
vicious.register(mybattery, vicious.widgets.bat, "||Battery: $2% ", 30, "BAT0")

-------------------------------------
right_layout:add(mytextclock)
-- We add mybattery here!
right_layout:add(mybattery)
right_layout:add(mylayoutbox[s])
-------------------------------------


```
After modification, save the rc.lua and restart the awesome desktop, you will see the following pictures. <br />
![/images/awesomebattery.jpg](/images/awesomebattery.jpg)
###Add notification when battery is too low
We can use acpi for getting the battery and power supply information, so first let's install it: <br />

```
	$ sudo pacman -S  acpi

```
Then we can write an script named notifybattery.sh, put it under the /bin folder: <br />

```sh notifybattery.sh
battery_level=`acpi -b | grep -P -o '[0-9]+(?=%)'`
if [ $battery_level -le 10 ]
then
    notify-send "Battery low" "Battery level is ${battery_level}%!"
fi

```
Then we add an item under crotab:<br />

```
	$ crontab -e
	# crontab's configuration:
	2 * * * * /bin/notifybattery.sh

```
Now we can got an indication when battery is less than 10%. you can adjust the number to whatever you want. 
