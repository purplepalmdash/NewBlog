---
layout: post
title: "ArchLinux On Surface Pro(1)"
date: 2014-06-16 13:51
comments: true
categories: SurfacePro
---
### System Management
#### Users and Groups
Install zsh and use zsh as the newly added users's default SHELL:    

```
# pacman -S zsh
# useradd -m -g root -G audio -s /bin/zsh Trusty

```
Then we add the newly added user into the sudo group and configure the sudo parameters:     

```
# pacman -S sudo
# visudo
Trusty ALL=(ALL) NOPASSWD: ALL
Defaults env_keep += "LANG LANGUAGE LINGUAS LC_* _XKB_CHARSET http_proxy https_proxy ftp_proxy ftps_proxy"

```
Now the user is OK, and you can directly use newly added user for login, I suggest you swiftly switch to the newly added user, because using root is not a good idea, it's not safe.    
And we can copy the existing zshrc file from the company machine.    

#### Yaourt
Add following command into /etc/pacman.conf:    

```
[archlinuxfr]
SigLevel = Never
Server = http://repo.archlinux.fr/$arch

```
Then:    

```
sudo pacman -Syu && sudo pacman -S yaourt

```

#### Packages
Install following packages:    

```
# pacman -S chromium firefox xorg xorg-xinit awesome xf86-video-intel xf86-video-ati pidgin thunderbird wget libreoffice gnome-terminal tigervnc xfce4  evince gimp smplayer alsa-utils gvim eclipse git subversion wireshark-gtk tcpdump ddd gdb meld qemu virtualbox wqy-bitmapfont wqy-microhei wqy-microhei-lite wqy-zenhei fcitx fcitx-libpinyin rox gpicview conky fcitx-googlepinyin nodejs cronie ntfs-3g dmenu lm_sensors pm-utils

```
Configure:    

```
[Trusty@~]$ cat ~/.xinirc 
exec awesome
[Trusty@~]$ cat ~/.vnc/xstartup 
#!/bin/sh

export XKL_XMODMAP_DISABLE=1
exec startxfce4

```
Configure crontab:     

```
crontab -e
*/4 * * * * sudo fdisk -l /dev/sdb

```

Configure lm_sensors:   

```
# yes | sensors-detect
```

Brightness of the screen(Too light!!!! should be darker!!!):    

```
$ sudo echo 1240>/sys/class/brightness/intel_backlight/brightness
```


### Network Configration(Wireless)
The wireless configuration on SurfacePro is quite annoying procedure, so following are
the steps for configurating it.    

Install NetworkManager:    

```
$ sudo pacman -S networkmanager
```

Disable the dhcpd.service of systemd, cause the networkmanager will have its own dhcp
client for configurating:    

```
$ sudo systemctl --type=service 
$ sudo systemctl disable dhcpcd.service
```

Now enable and start the NetworkManager.service:    

```
$ sudo systemctl enable NetworkManager.service
```

Using the applet for configurating the Network Manager:    

```
$ sudo pacman -S network-manager-applet
```
Call nm-applet via:   

```
$ nm-applet
```

Configure the wireless connection, the NM will automatically store it so now you could
reboot for using the wifi(Make sure you have removed the wired connection).      


### Auto-Login Awesome
Since awesome will using the terminal by default, while I use synergyc for connecting
to the synergys server, this will cause me to using surface pro's keyboard, so enable
auto-login for avoiding this.   

Install lightdm via:    

```
$ sudo pacman -S lightdm
$ sudo systemctl enable lightdm.service
```

Install lightdm-greeter via:    

```
$ sudo pacman -S lightdm-gtk-greeter
$ sudo vim /etc/lightdm/lightdm.conf
greeter-session=lightdm-gtk-greeter
```
The greeter session could be view under `ls -l /usr/share/xgreeters`.   

Configure the auto-login for awesome:    

```
# vim /etc/lightdm/lightdm.conf

[Seat:*]
pam-service=lightdm
pam-autologin-service=lightdm-autologin
autologin-user=username
autologin-user-timeout=0
session-wrapper=/etc/lightdm/Xsession


# groupadd -r autologin
# gpasswd -a username autologin
```
Now restart the machine and it will automatically falls into the awesome login session.      

### fcitx 
Always a big problem!!!!!   

```
$ sudo pacman -S fcitx fcitx-googlepinyin fcitx-configtool fcitx-qt4 fcitx-qt5
fcitx-gtk2
```

in /etc/locale.conf:    

```
# Enable UTF-8 with Australian settings.
LANG="en_US.UTF-8"

# Keep the default sort order (e.g. files starting with a '.'
# should appear at the start of a directory listing.)
LC_COLLATE="C"

# Set the short date to YYYY-MM-DD (test with "date +%c")
LC_TIME="en_US.UTF-8"
```

Configure it via:    

```
$ vim .xprofile 
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
```

Restart the surfacepro, now you could using fcitx along with awesome/lightdm/firefox(need fcitx-gtk2)      
