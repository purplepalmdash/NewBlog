---
layout: post
title: "Trouble-Shooting On ChromeOS's crouton Updating"
date: 2015-09-10 10:17:17 +0800
comments: true
categories: Linux
---
### Problem
After updating of ChromeOS itself, the crouton failed to start with following message:     

```
Entering /mnt/stateful_partition/crouton/chroots/xxxxxx...

ERROR: ld.so: object '/usr/local/lib/croutonfreon.so' from LD_PRELOAD cannot be
preloaded (cannot open shared object file): ignored.
_XSERVTransmkdir: Owner of /tmp/.X11-unix should be set to root
```

### Solution
First setup the proxy for acrossing the Fucking Great Fire Wall.    

In another PC which have the socket proxy, install privoxy:    

```
$ sudo apt-get install -y privoxy
```

Oh sorry I have to delete the whole chroot environment, delete it via:    

```
$ sudo delete-chroot trusty
```
This time try kali, list all of the available rleases via:    

```
$ sh ~/Downloads/crouton -r list
```

Install it via:    

```
$ sudo sh -e ~/Downloads/crouton -r kali -t x11
```

### Tips
List all of the releases and tags:   

```
# sh ~/Downlods/crouton -r list
# sh ~/Downlods/crouton -t list
```

Finally I choose the `sudo sh -e ~/Downloads/crouton -r sana -t e17`.    
