---
layout: post
title: "Moving From Working PC to Own USB-Disk Based 3"
date: 2014-05-22 15:06
comments: true
categories: linux
---
### Trouble Shooting
Unfortuately the qemu based pysical disk can't bootup the machine correctly, so I re-intall the sytem on USB-Disk from the scratch. This time the problem appears as another: It can startup the machine, but failed to boot-up in qemu.     
So I have to changed to use VirtualBox for booting the system.     
Get the disk id via;    

```
$ $ ls -l /dev/disk/by-id
lrwxrwxrwx 1 root root  9 May 22 14:45 usb-ATA_ST980811AS_xxxxxxxx-0:0 -> ../../sdb

```
Then use VirtualBox's Internal command for creating the vmdk file, this vmdk file actually contains the physical disk.    

```
$ VBoxManage internalcommands createrawvmdk -filename ./rawusb1.vmdk -rawdisk /dev/disk/by-id/usb-ATA_ST980811AS_XXXXXXXXXXX-0:0
RAW host disk access VMDK file ./rawusb1.vmdk created successfully.
$ sudo chown -R Trusty *

```
Now create a new virtual machine in virtualbox, use the newly created rawusb1.vmdk, bootup and you got the physical disk based virtual machine running.    
### Continue Install System

#### Python related environment
Install virtualenvironment via: 

```
sudo pacman -S python2-virtualenv python-virtualenv python-virtualenvwrapper

```
In company machine, use pip freeze for getting all of the packages:   

```
$ workon venv2
$ pip freeze>requirement.txt

```
In usb-disk based machine, install from the requirement.txt

```
$ mkdir .virtualenvs
# Add following lines into the .bashrc
export WORKON_HOME=~/.virtualenvs
source /usr/bin/virtualenvwrapper.sh
$ mkvirtualenv -p /usr/bin/python2.7 venv
$ pip install -r requirements.txt

```
After we update the installation, the package is the same as in computer machine.  

#### ZSH
Install zsh and use it for replacing default bash:     

```
$ sudo pacman -S zsh
$ chsh -s $(which zsh)

```
Now we can download the .zshrc from the company machine to usb disk based system.    

#### Configure GIT Under Proxy
Setting the proxy and set it for git using proxy:   

```
(venv)[Trusty@localhost ~]$ gcc -o connect connect.c 
(venv)[Trusty@localhost ~]$ sudo mv connect /usr/bin/
(venv)[Trusty@localhost ~]$ sudo chmod 777 /usr/bin/connect 
(venv)[Trusty@localhost ~]$ sudo vim /usr/bin/myproxy
(venv)[Trusty@localhost ~]$ sudo chmod 777 /usr/bin/myproxy
(venv)[Trusty@localhost ~]$ cat /usr/bin/myproxy 
/usr/bin/connect -H 1xx.xxx.xxx.xxx:2xxxx $@
(venv)[Trusty@localhost ~]$ git config --global core.gitproxy "/usr/bin/myproxy for *.*"
(venv)[Trusty@localhost ~]$ git config --global user.name "feixxxx"
(venv)[Trusty@localhost ~]$ git config --global user.email "feixxxx@gmail.com"

```

#### BlueTooth
Install blueman:    

```
$ sudo pacman -S patch automake autoconf libtool 
$ yaourt blueman
# choose blueman-bzr
$ sudo pacman -S bluez-utils bluez-libs python2-pybluez
$ yaourt -S bluez4
$ yaourt pulseaudio-bluez4

```
Configure bluetooth:   

```
$ sudo systemctl start bluetooth
$ sudo systemctl enable bluetooth
$ cat /etc/bluetooth/audio.conf

[General]
Enable=Socket

[A2DP]
SBCSources=1
$ 

```
Later bluemanager will be added into the awesome startup application.    
The configuration is pretty complex, this is the start-point for settingup the bluetooth, later we will configure the bluetooth headset.    
####  Tray items 

```
$ sudo pacman -S udiskie wicd wicd-gtk

```

#### Awesome Customization
Download the themes from github:    

```
$ sudo pacman -S hddtemp vicious
$ git clone https://github.com/Morley93/awesome-themes-3.5.git

```
Still have some problems. Need update.    
Then get the customized awesome configuration file. Be sure to use the default, because later you can customize yourself.    

Solve wicd error:    
Error:  Could not connect to wicd's D-Bus interface

```
$ sudo pacman -R wicd wicd-gtk
$ sudo rm -rf /etc/wicd /var/log/wicd /etc/dbus-1/system.d/wicd*
$ sudo pacman -S wicd wicd-gtk
$ sudo pacman -Syu systemd-sysvcompat
$ sudo gpasswd -a Trusty users
$ sudo systemctl enable wicd
$ sudo systemctl start wicd

```
Now your wicd is OK for see.      


udiskie2 problem, cannot start because lack of PyYAML:    

```
$ sudo pacman -S python2-pip
$ sudo pip2 install PyYAML

```

Now seems all of your tray icons will be OK.    

#### System Tools
Install the mlocate so we can use updatedb:    

```
$ sudo pacman -S mlocate
$ sudo updatedb

```
