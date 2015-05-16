---
layout: post
title: "Customize Awesome Startup Application"
date: 2014-04-26 08:21
comments: true
categories: awesome
---
Let applications automatically start at boot will greatly save your time in configurating the system. Following is some tips on how to automatically start applications in awesome desktop environment.    
###Xinit Way
My startup configuration is listed as:     

```
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"
exec awesome

```
So the awesome environment will be started.     
###Awesome Way
Run only once in awesome desktop, via following configuration file:     

```
function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
    findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

run_once("udiskie -2 --tray")
run_once("wicd-client --tray")

```
Add the code into ~/.config/awesome/rc.lua, then you can get the udiskie and wicd-client icon in the tray.     
###Change View Way

```
#dualview
killall conky
xrandr --output LVDS1 --mode 1366x768
xrandr --newmode $(gtf 1920 1080 60 | grep Modeline | sed s/Modeline\ // | tr -d '"')
xrandr --addmode VGA1 1920x1080_60.00
xrandr --output VGA1 --mode 1920x1080_60.00 --right-of LVDS1
xscreensaver -nosplash &
xset -b
xmodmap -e "pointer = 3 2 1"
fcitx &
sleep 2
sudo whatpulse &
conky &


```
###Systemd Way
For example, we want to enable xampp.service on every start:   

```
[root@DashArch system]# pwd
/etc/systemd/system
[root@DashArch system]# cat xampp.service

[Unit]
Description=xampp for ArchLinux, locate in /opt/lampp
After=network.target

[Service]
ExecStart=/opt/lampp/lampp start 
ExecStop=/opt/lampp/lampp stop
Type=forking

[Install]
WantedBy=multi-user.target

```
Then we can start/stop the service, enable/disable the service via:

```
systemctl start xampp.service
systemctl stop xampp.service
systemctl enable xampp.service

```
