---
layout: post
title: "Building Android On Server"
date: 2014-10-15 10:41
comments: true
categories: Linux
---
### New LXC Machine
Building Android need a Ubuntu machine, so I created the LXC machine which runs Ubuntu.    
Install the bootstrap:    

```
zypper in bootstrap

```
Then create the Ubuntu LXC via:    

```
export LANG=en_US.UTF-8
Linux59:~ # lxc-create -n Ubuntu_Container -t /usr/share/lxc/templates/lxc-ubuntu

```
Start the container, username and password are ubuntu:    

```
lxc-start -n Ubuntu_Container

```
### Configure the LXC Machine
Better we have the static IP, and let the Container startup when machine boot.    
#### Static IP Configuration
Change the network configuration via modifying the /etc/network/interfaces:    

```
auto eth0

# Enable it for dhcp
#iface eth0 inet dhcp

# Enable them for static IP address
iface eth0 inet static
address 1xx.xxx.xxx.159
netmask 255.255.255.0
network 1xx.xxx.xxx.0
broadcast 1xx.xxx.xxx.255
gateway 1xx.xxx.xxx.1

```
Then next time you login into the machine, it hold the address of 159.    
#### Start Together With Host Machine
Create a new definition file of systemd under the /usr/lib/systemd/system directory:    

```
Linux59:/usr/lib/systemd/system # cat lxc\@.service
[Unit]
Description=%i LXC
After=network.target

[Service]
Type=forking
ExecStart=/usr/bin/lxc-start -d -n %i
ExecStop=/usr/bin/lxc-stop -n %i

[Install]
WantedBy=multi-user.target

Linux59:/usr/lib/systemd/system # pwd
/usr/lib/systemd/system

```
Let `Ubuntu_Container` runs when system bootup.    

```
# systemctl enable lxc@Ubuntu_Container.service
ln -s '/usr/lib/systemd/system/lxc@.service' '/etc/systemd/system/multi-user.target.wants/lxc@Ubuntu_Container.service'

```
#### Update
visudo to change the settings:    

```
ubuntu  ALL=(ALL:ALL) ALL
Defaults env_keep = "http_proxy https_proxy ftp_proxy"

```
Enable proxy for apt-get:    

```
$ cat /etc/apt/apt.conf
Acquire::http::Proxy "http://127.0.0.1:9001";

```
Update the system and install some packages:    

```
$ sudo apt-get update
$ sudo apt-get install tmux openjdk-7-jdk
$ sudo update-alternatives --config java && sudo update-alternatives --config javac
$ sudo apt-get install git gnupg flex bison gperf    zip curl libc6-dev libncurses5-dev:i386 x11proto-core-dev   libx11-dev:i386 libreadline6-dev:i386 libgl1-mesa-glx:i386   libgl1-mesa-dev  mingw32 tofrodos   python-markdown libxml2-utils xsltproc zlib1g-dev:i386
$ sudo apt-get install build-essential 
$ sudo apt-get install g++-multilib
$ sudo ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so

```
#### Configuration on USB
Create following file:    

```
ubuntu@Ubuntu_Container:~$ cat /etc/udev/rules.d/51-android.rules 
# adb protocol on passion (Nexus One)
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="4e12", MODE="0600", OWNER="ubuntu"
# fastboot protocol on passion (Nexus One)
SUBSYSTEM=="usb", ATTR{idVendor}=="0bb4", ATTR{idProduct}=="0fff", MODE="0600", OWNER="ubuntu"
# adb protocol on crespo/crespo4g (Nexus S)
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="4e22", MODE="0600", OWNER="ubuntu"
# fastboot protocol on crespo/crespo4g (Nexus S)
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="4e20", MODE="0600", OWNER="ubuntu"
# adb protocol on stingray/wingray (Xoom)
SUBSYSTEM=="usb", ATTR{idVendor}=="22b8", ATTR{idProduct}=="70a9", MODE="0600", OWNER="ubuntu"
# fastboot protocol on stingray/wingray (Xoom)
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="708c", MODE="0600", OWNER="ubuntu"
# adb protocol on maguro/toro (Galaxy Nexus)
SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", ATTR{idProduct}=="6860", MODE="0600", OWNER="ubuntu"
# fastboot protocol on maguro/toro (Galaxy Nexus)
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="4e30", MODE="0600", OWNER="ubuntu"
# adb protocol on panda (PandaBoard)
SUBSYSTEM=="usb", ATTR{idVendor}=="0451", ATTR{idProduct}=="d101", MODE="0600", OWNER="ubuntu"
# adb protocol on panda (PandaBoard ES)
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="d002", MODE="0600", OWNER="ubuntu"
# fastboot protocol on panda (PandaBoard)
SUBSYSTEM=="usb", ATTR{idVendor}=="0451", ATTR{idProduct}=="d022", MODE="0600", OWNER="ubuntu"
# usbboot protocol on panda (PandaBoard)
SUBSYSTEM=="usb", ATTR{idVendor}=="0451", ATTR{idProduct}=="d00f", MODE="0600", OWNER="ubuntu"
# usbboot protocol on panda (PandaBoard ES)
SUBSYSTEM=="usb", ATTR{idVendor}=="0451", ATTR{idProduct}=="d010", MODE="0600", OWNER="ubuntu"
# adb protocol on grouper/tilapia (Nexus 7)
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="4e42", MODE="0600", OWNER="ubuntu"
# fastboot protocol on grouper/tilapia (Nexus 7)
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="4e40", MODE="0600", OWNER="ubuntu"
# adb protocol on manta (Nexus 10)
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="4ee2", MODE="0600", OWNER="ubuntu"
# fastboot protocol on manta (Nexus 10)
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="4ee0", MODE="0600", OWNER="ubuntu"

```
### Building
#### Enable git proxy
Configure the git configuration:    

```
ubuntu@Ubuntu_Container:~$ git config --global user.email "xxx@gmail.com"
ubuntu@Ubuntu_Container:~$ git config --global user.name "xxx"

```
Compile the connect.c for getting the cross-firewall tool.    

```
$ gcc -o connect connect.c
$ sudo mv connect /usr/bin
$ sudo chmod  777 /usr/bin/connect
$ cat /usr/bin/myproxy 
/usr/bin/connect -H 127.0.0.1:9001 $@
$ sudo chmod 777 /usr/bin/myproxy

```
Let your git authenticated by github, please refers to the following article:    
[http://kkkttt.github.io/blog/2014/10/14/verified-to-github/](http://kkkttt.github.io/blog/2014/10/14/verified-to-github/)    

Then add the proxy setting in .gitconfig:    

```
[core]
	gitproxy = /usr/bin/myproxy


```
#### Preparation
Install repo:    

```
   57  echo $PATH
/home/ubuntu/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games
   58  curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
   59  chmod a+x ~/bin/repo

```
Make a new directory for holding the source code:    

```
$ mkdir ~/code
$ repo init -u https://android.googlesource.com/platform/manifest

```
sync the repository:   

```
$ repo sync

```
#### Build
Set the environment variables:   

```
. build/envsetup.sh
lunch 

```
In lunch you could select whatever you like.    
Then make via following command:    

```
make -j 8

```
Trouble-shooting:   

```
Your version is: java version "1.7.0_65".
The correct version is: Java SE 1.6.

```
Ok, we change the java version via:    

```
$ sudo apt-get install software-properties-common
$ sudo apt-get install python-software-properties
Add the PPA:
$ sudo add-apt-repository ppa:webupd8team/java
Update the repo index:
$ sudo apt-get update
$ sudo apt-get install oracle-java6-installer

```
After installation, update the java version via:    

```

$ sudo update-alternatives --config java
[sudo] password for ubuntu: 
There are 3 choices for the alternative java (providing /usr/bin/java).

  Selection    Path                                            Priority   Status
------------------------------------------------------------
* 0            /usr/lib/jvm/java-6-oracle/jre/bin/java          1062      auto mode
  1            /usr/lib/jvm/java-6-openjdk-amd64/jre/bin/java   1061      manual mode
  2            /usr/lib/jvm/java-6-oracle/jre/bin/java          1062      manual mode
  3            /usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java   1051      manual mode

Press enter to keep the current choice[*], or type selection number: 

```
Now you could run building. 

###Trouble Shooting
Build error:    

```
If you are building an old version of android probably you’ll have this error

host C++: obbtool <= frameworks/base/tools/obbtool/Main.cpp
:0:0: error: “_FORTIFY_SOURCE” redefined [-Werror]
:0:0: note: this is the location of the previous definition
cc1plus: all warnings being treated as errors
To fix this, edit build/core/combo/HOST_linux-x86.mk and replace:

HOST_GLOBAL_CFLAGS += -D_FORTIFY_SOURCE=0
with

HOST_GLOBAL_CFLAGS += -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0
And that’s it.

```

When you meet "error: reference ‘counts’ cannot be declared ‘mutable’", install gcc/g++ 4.4 and re-compiling.    

```
$ sudo apt-get install gcc-4.4 g++-4.4  g++-4.4-multilib gcc-4.4-multilib
make CC=gcc-4.4 CXX=g++-4.4

```

View the CPU ranking:    
![http://itianti.sinaapp.com/index.php/cpu](http://itianti.sinaapp.com/index.php/cpu)     

```
490	Intel Core i5-2520M @ 2.50GHz	￼	3537
851	Intel Xeon 5160 @ 3.00GHz	￼	2047

```

### View Result
Since we use the remote machine, we have to enable the vncserver, first install it via:    

```
sudo apt-get install vnc4server

```
Install lubuntu-desktop as the default X:    

```
sudo apt-get install lubuntu-desktop

```
