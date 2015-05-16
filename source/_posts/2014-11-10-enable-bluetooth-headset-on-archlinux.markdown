---
layout: post
title: "Enable Bluetooth Headset On ArchLinux"
date: 2014-11-10 09:33
comments: true
categories: linux
---
Since my operating system upgraded, I have to re-set my bluetooth headset. I use A2DP via Bluez5/Pulseaudio.      
### Installation
First install following packages:     

```
# pacman -S pulseaudio-alsa bluez bluez-libs bluez-utils

```
Then start the service via systemd:    

```
# systemctl start bluetooth

```
### Configuration
I use an expect script for automatically connect to my MW600 and play:    

``` sh
#!/usr/bin/expect

# This script is for automatically scan my bluetooth headset, which is Sony-Errison mw-600

# Timeout should be very short in local
# set timeout 3

spawn ssh Trusty@localhost -Y
expect {
        "yes/no" {
                    send "yes\n"
                                exp_continue
                                    }
            "assword" {
                        send "xxxxxxx!\n"
                                }
}
expect $

# Now we are in the controlled session, run bluetooth related commands.
send "bluetoothctl\r"
expect #
send "power on\r"
expect "yes"
send "agent on\r"
expect #
send "default-agent\r"
expect #
send "connect 8C:64:22:5F:FF:BD\r"
expect "connection successful" 
# Now exit the bluetoothctl
send "exit\r"
expect $

# After execute the command in this ssh session, simply exit. 
send "exit\r"
expect $

```
Everytime I want to use bluetooth headset, just run:    

```
 $ /home/Trusty/auto/autobluetooth.sh && pavucontrol &

```

### Flash Content
Install following package for let alsa use pulseaudio:    

```
$ sudo pacman -S pulseaudio-alsa

```
Restart opera(or other browser which calls flash), now your sound will be played via bluetooth.   
