---
layout: post
title: "Conky Customization"
date: 2013-11-22 15:08
comments: true
categories: Linux
---
###Add existing user to specified group
The problem is : why I can't use hddtemp? This is because hddtemp need priviledge for accessing the disk related equipment.     

```
	[Trusty@XXXyyy ~]$ whoami
	Trusty
	[Trusty@XXXyyy ~]$ groups
	root log kvm users vboxusers
	[Trusty@XXXyyy ~]$ su root
	Password: 
	[root@XXXyyy Trusty]# groups
	root bin daemon sys adm disk wheel log

```
But this didn't solve the problem, I have to add prividge in /etc/sudoes, 

```
	# visudo
	Trusty ALL = NOPASSWD: /usr/bin/hddtemp

```
Therefore in the configuration file of conky I need to replace the hddtemp with "sudo hddtemp", everything will be displayed. 
###Now testing the Conky
After you have installed conky, the first thing for you to do is to edit its configuration file, to decide what to display on your own widget, my configuration file is listed as following:

```html conkyrc.conf
alignment top_right
background yes
border_width 1
cpu_avg_samples 2
default_color black
default_outline_color blue
default_shade_color blue
draw_borders no
draw_graph_borders yes
draw_outline no
draw_shades no
use_xft yes
xftfont AR PL KaitiM GB:size=12
gap_x 5
gap_y 30
minimum_size 280 5
net_avg_samples 2
no_buffers yes
out_to_console no
out_to_stderr no
extra_newline no
own_window yes
own_window_class Conky
own_window_type override
##设置conky的默认背景色
##own_window_colour 573049
##很重要，只有启用argb才能透明，但是如果窗口属性如果设置为override，可能无法生效
#own_window_argb_visual yes
##设置透明的alpha值0-255，0为透明，255不透明
#own_window_argb_value 0
##own_window_argb_visual true
##own_window_argb_value 120
own_window_transparent yes
double_buffer yes
stippled_borders 0
update_interval 1
uppercase no
use_spacer none
show_graph_scale no
show_graph_range no

TEXT
#${color red}${font AR PL KaitiM GB:style=Blod:size=17}    ${time %Y.%m.%d %H:%M:%S}
#${font AR PL KaitiM GB:style=Blod:size=12}
#${font AR PL KaitiM GB:style=Blod:size=12}${scroll 16 $nodename - $sysname $kernel on $machine}
#$hr
#${font AR PL KaitiM GB:style=Blod:size=14}${color green}${exec cal}
#$hr
${font AR PL KaitiM GB:style=Blod:size=12}${color purple}Uptime:$color $uptime
${color purple}Frequency (in MHz):$color $freq
#${color purple}Frequency (in GHz):$color $freq_g
${color purple}RAM: $color$mem/$memmax - $memperc% ${membar 4}
${color purple}Swap: $color$swap/$swapmax - $swapperc% ${swapbar 4}
${color purple}CPU1: $color${cpu cpu1}% ${cpubar 4}
${color purple}CPU2: $color${cpu cpu2}% ${cpubar 4}
${color purple}CPU3: $color${cpu cpu3}% ${cpubar 4}
${color purple}CPU4: $color${cpu cpu4}% ${cpubar 4}
${color purple}Processes: $color $processes  ${color red}Running:$color $running_processes
$hr
#${color red}Temp:
${color purple}CPU1 Temp: ${color red}${exec sensors | grep 'Core 0' | awk {'print $3'}}
${color purple}CPU2 Temp: ${color red}${exec sensors | grep 'Core 1' | awk {'print $3'}}
${color purple}System Temp: ${color red}${exec sensors | grep 'temp1' | tail -1 | awk {'print $2'}}
${color purple}Hard Temp: ${color red}${exec sudo hddtemp /dev/sda -n -u=C}°C
$hr
#${color red}File systems:
${color black}${exec df -h | grep /dev/sda3 | awk {'print $3'}} / $color${fs_used /}/${fs_size /} ${fs_bar 6 /}
${exec df -h | grep /dev/sda2 | awk {'print $3'}} x $color${exec df -h | grep /dev/sda2 | awk {'print $3'}}/138GB ${fs_bar 6 /media/ubuntu}
#${exec df -h | grep /dev/sda8 | cut -c40-43} /boot $color${fs_used /boot}/${fs_size /boot} ${fs_bar 6 /boot}
$hr
#${color red}Networking:
#${color red}eth0:
#Up:$color ${upspeed eth0} ${color red} - Down:$color ${downspeed eth0}
${color red}br0:
Up:$color ${upspeed br0} ${color red} - Down:$color ${downspeed eth0}
#${color red}ppp0:
#${color red}Up:$color ${upspeed ppp0} ${color red} - Down:$color ${downspeed ppp0}
$hr
${color red}Name              PID   CPU%   MEM%
${color black} ${top name 1} ${top pid 1} ${top cpu 1} ${top mem 1}
${color black} ${top name 2} ${top pid 2} ${top cpu 2} ${top mem 2}
${color black} ${top name 3} ${top pid 3} ${top cpu 3} ${top mem 3}
${color purple} ${top name 4} ${top pid 4} ${top cpu 4} ${top mem 4}
${color purple} ${top name 5} ${top pid 5} ${top cpu 5} ${top mem 5}


```
In fact I didn't finished the Translucent, so I use the Transparent, a little bit ugly, but it's OK. 
###Add it into awesome
Simply add one line in your ~/.config/awesome/rc.lua could solve the problem:

```
	awful.util.spawn("conky")

```
Now you can enjoy your Conky. 

![conky.jpg](/images/conky.jpg)


