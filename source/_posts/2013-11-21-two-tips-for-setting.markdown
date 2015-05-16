---
layout: post
title: "Two Tips for setting"
date: 2013-11-21 18:49
comments: true
categories: Linux
---
###Disable the vim wraping
There is a line in ~/.vimrc:

```
	autocmd FileType text setlocal textwidth=78

```
comment this line then everything goes OK.
###Change Awesome theme and change the titlebar width
Download the 3rd party themes from [https://github.com/Morley93/awesome-themes-3.5](https://github.com/Morley93/awesome-themes-3.5), then copy them to your own theme location, normally under the "/usr/share/awesome/themes/", Choose whatever you want, and edit the ~/.config/awesome/default.rc.lua:

```lua rc.lua
beautiful.init("/usr/share/awesome/themes/wabbit/theme.lua")

```
Save and exit then you got the new theme.    
How to change the title bar?   
In /usr/share/awesome/themes/wabbit/theme.lua, edit the following lines:

```lua theme.lua
--theme.font          = "MonteCarlo medium 11"
theme.font          = "MonteCarlo medium 9"

```
I think 9 is good for me, but change this to 11 or bigger will make old men happy.     
You can change this number into a very big or very small number, then some funny things will happen :)
