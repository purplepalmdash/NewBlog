---
layout: post
title: "Enable Bluetooth headset on Joggler"
date: 2013-12-18 17:08
comments: true
categories: Linux
---
###TroubleShooting on alsa
Current user canot use alsamixer

```
	Trusty@joggler:~$ alsamixer 
	cannot open mixer: No such file or directory

```
This is because the current user is not in the "audio" group, use root to add current user into "audio" group:

```
	root@joggler:~# usermod -a -G audio Trusty

```
Unmute the channel:

```
	$ amixer sset Master unmute
	Simple mixer control 'Master',0
	  Capabilities: pvolume pswitch penum
	  Playback channels: Front Left - Front Right
	  Limits: Playback 0 - 31
	  Mono:
	  Front Left: Playback 24 [77%] [-10.50dB] [on]
	  Front Right: Playback 24 [77%] [-10.50dB] [on]

```
Now we can use wired headset for listening music. 
###Setup Bluetooth
Scan the available equipments: 

```
	Trusty@joggler:~$ hcitool scan
	Scanning ...
		geougwoguw  geige 	
		geougwoguw  geige521
		geougwoguw  geige 	
		geougwoguw  geige723

```
Repair:

```
	bluez-simple-agent hci0 dd:64:22:KK:FF:BD repair

```
Then edit your /etc/asound.conf file:

```
	#/etc/asound.conf
	
	pcm.btheadset {
	   type plug
	   slave {
	       pcm {
	           type bluetooth
	           device XX:XX:XX:XX:XX:XX 
	           profile "auto"
	       }   
	   }   
	   hint {
	       show on
	       description "BT Headset"
	   }   
	}
	ctl.btheadset {
	  type bluetooth
	}  

```
mplayer using bluetooth:

```
	mplayer -ao alsa:device=btheadset bad.mp3

```

###Set the default sound card to bluetooth
Edit the .asoundrc file. 

```
	Trusty@joggler:~$ cat .asoundrc    
	pcm.!default {
	   type plug
	   slave {
	       pcm {
	           type bluetooth
	           device dd:64:22:KK:FF:BD
	           profile "auto"
	       }   
	   }   
	   hint {
	       show on
	       description "BT Headset"
	   }   
	}
	##ctl.btheadset {
	##  type bluetooth
	##}
	
	bluez-simple-agent hci0 dd:64:22:KK:FF:BD repair

```
Then edit your /etc/asound.conf file:

```
	#/etc/asound.conf
	
	pcm.btheadset {
	   type plug
	   slave {
	       pcm {
	           type bluetooth
	           device XX:XX:XX:XX:XX:XX 
	           profile "auto"
	       }   
	   }   
	   hint {
	       show on
	       description "BT Headset"
	   }   
	}
	ctl.btheadset {
	  type bluetooth
	}  

```
mplayer using bluetooth:

```
	mplayer -ao alsa:device=btheadset bad.mp3

```

###Set the default sound card to bluetooth
TBD, here I meet lots of problems. 
Edit the .asoundrc file. 

```
	
	
	apt-get autoremove pulseaudio
	pulseaudio --start

```
Why aplay -L and aplay -l will get different result? I have no idea.  
