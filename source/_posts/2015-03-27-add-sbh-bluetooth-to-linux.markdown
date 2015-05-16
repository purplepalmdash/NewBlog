---
layout: post
title: "Add SBH BlueTooth to Linux"
date: 2015-03-27 10:05
comments: true
categories: Linux
---
I bought a SBH Sony Bluetooth headset, following is the steps for adding it to system.      
### Add Device
Use Blueman for adding the equiment, first click the SBH headset to let it enter discover mode, also in blueman we enable the discover mode too, when setup the equipment, the code you have to enter is 0000.    
The device kindle is not headset, but the a2dp?     
### Add Configuration for ALSA
Edit the /etc/asound.conf, my configuration file is listed as following:     

```
pcm.btheadset {
   type plug
   slave {
       pcm {
           type bluetooth
           device xxx.xxx.xxx.xxx
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
pcm.sbhbtheadset {
   type plug
   slave {
       pcm {
           type bluetooth
           device xxx.xxx.xxx.xxx
           profile "auto"
       }   
   }   
   hint {
       show on
       description "SBH BT Headset"
   }   
}
ctl.sbhbtheadset {
  type bluetooth
}  

```
The first equipment is another bluetooth headset. We define our SDH to sdhbtheadset.    
Examine our added equipment via following command:    

```
$ aplay -L
default
    Playback/recording through the PulseAudio sound server
null
    Discard all samples (playback) or generate zero samples (capture)
pulse
    PulseAudio Sound Server
btheadset
    BT Headset
sbhbtheadset
    SBH BT Headset

```
### Send Sound
The commands are listed as following:    

```
$ pactl load-module module-alsa-sink device=sbhbtheadset
17
[Trusty@~]$ pacmd load_module module-bluetooth-discover
Welcome to PulseAudio! Use "help" for usage information.
>>> Unknown command: load_module module-bluetooth-discover
>>> %                                                             
[Trusty@~]$ pactl list sinks short
1       alsa_output.sbhbtheadset        module-alsa-sink.c      s16le 2ch 44100Hz      SUSPENDED
[Trusty@~]$ pacmd set-default-sink 1
Welcome to PulseAudio! Use "help" for usage information.
>>> >>> %                  

```
Now you are ready for listening Music via bluetooth headset, enjoy it.   
