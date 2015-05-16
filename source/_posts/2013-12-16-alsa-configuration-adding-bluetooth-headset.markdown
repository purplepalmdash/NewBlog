---
layout: post
title: "Alsa Configuration(Adding bluetooth headset"
date: 2013-12-16 19:46
comments: true
categories: Linux ALSA
---
After upgrading 3.12.5, my archlinux dropped its alsa configuration, also I bought a new bluetooth headset MW600, following is the steps for catching back the alsa sound, and let bluetooth headset working together with alsa.   
###Fetching back sound
Found out the hadware

```
	$ sudo alsactl init
	Found hardware: "HDA-Intel" "Intel CougarPoint HDMI" "HDA:111d7605,103c3587,00100105 HDA:11c11040,103c3066,00100200 HDA:80862805,80860101,00100000" "0x103c" "0x161c"
	Hardware is initialized using a generic method

```
The acl should be reset via:

```
	sudo setfacl -m u:Trusty:rw /dev/snd/*

```

