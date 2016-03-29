---
layout: post
title: "Use Debmirror For Setup Local Repository"
date: 2016-03-29 11:31:42 +0800
comments: true
categories: 
---
### Setup Repository
Install debmirror via:    

```
$ sudo apt-get install -y debmirror
$ sudo mkdir /home/UbuntuMirror
$ sudo vim /usr/local/bin/mirrorbuild.sh
```

The mirrorbuild.sh file listed as following:    

```sh
#### Start script to automate building of Ubuntu mirror #####
## THE NEXT LINE IS NEEDED THE REST OF THE LINES STARTING WITH A # CAN BE DELETED

#!/bin/bash

## Setting variables with explanations.

#
# Don't touch the user's keyring, have our own instead
#
export GNUPGHOME=/home/mirrorkeyring

# Arch=         -a      # Architecture. For Ubuntu can be i386, powerpc or amd64.
# sparc, only starts in dapper, it is only the later models of sparc.
#
arch=i386,amd64

# Minimum Ubuntu system requires main, restricted
# Section=      -s      # Section (One of the following -
main/restricted/universe/multiverse).
# You can add extra file with $Section/debian-installer. ex:
main/debian-installer,universe/debian-installer,multiverse/debian-installer,restricted/debian-installer
#
section=main,restricted,universe,multiverse

# Release=      -d      # Release of the system (...Hardy, Intrepid... Lucid, Precise,
Quantal, Saucy, Trusty ), and the -updates and -security ( -backports can be added if
desired)
# List of updated releases in: https://wiki.ubuntu.com/Releases
#

release=trusty,trusty-security,trusty-updates

# Server=       -h      # Server name, minus the protocol and the path at the end
# CHANGE "*" to equal the mirror you want to create your mirror from. au. in Australia
ca. in Canada.
# This can be found in your own /etc/apt/sources.list file, assuming you have Ubuntu
installed.
#
server=archive.ubuntu.com

# Dir=          -r      # Path from the main server, so http://my.web.server/$dir,
Server dependant
#
inPath=/ubuntu

# Proto=        --method=       # Protocol to use for transfer (http, ftp, hftp, rsync)
# Choose one - http is most usual the service, and the service must be avaialbe on the
server you point at.
#
proto=http

# Outpath=              # Directory to store the mirror in
# Make this a full path to where you want to mirror the material.
#
outPath=/home/UbuntuMirror

# The --nosource option only downloads debs and not deb-src's
# The --progress option shows files as they are downloaded
# --source \ in the place of --no-source \ if you want sources also.
# --nocleanup  Do not clean up the local mirror after mirroring is complete. Use this
option to keep older repository
# Start script
#
debmirror       -a $arch \
                --no-source \
                -s $section \
                -h $server \
                -d $release \
                -r $inPath \
                --progress \
                --method=$proto \
                $outPath


#### End script to automate building of Ubuntu mirror ####
```

Modify the related priviledge:    

```
$ sudo chmod +x /usr/local/bin/mirrorbuild.sh
$ sudo chown -R root:dash /home/UbuntuMirror/
$ sudo chmod -R 571 /home/UbuntuMirror/
$ sudo chmod 777 -R /home/mirrorkeyring/
$ gpg --no-default-keyring --keyring /home/mirrorkeyring/pubring.gpg --import
/usr/share/keyrings/ubuntu-archive-keyring.gpg
$ gpg --no-default-keyring --keyring /home/mirrorkeyring/trustedkeys.gpg --import
/usr/share/keyrings/ubuntu-archive-keyring.gpg
```
Now you could build the local repository via:    

```
$ mirrorbuild.sh
```

### Resize Repository
First we syncing all of the Repositries, to see its size:    

```
$ ➜  UbuntuMirror du -hs *
72M	dists
192G	pool
12K	project
```

Now we add some regex for restrict :    

```
$ sudo vim /usr/local/bin/mirrorbuild.sh
debmirror       -a $arch \
                --no-source \
                -s $section \
                -h $server \
                -d $release \
                -r $inPath \
                --progress \
                --method=$proto \
                --exclude-deb-section=admin \
                --exclude-deb-section=base \
                --exclude-deb-section=comm \
                --exclude-deb-section=devel \
                --exclude-deb-section=doc \
                --exclude-deb-section=electronics \
                --exclude-deb-section=embedded \
                --exclude-deb-section=games \
                --exclude-deb-section=gnome \
                --exclude-deb-section=graphics \
                --exclude-deb-section=hamradio \
                --exclude-deb-section=interpreters \
                --exclude-deb-section=kde \
                --exclude-deb-section=libdevel \
                --exclude-deb-section=libs \
                --exclude-deb-section=mail \
                --exclude-deb-section=math \
                --exclude-deb-section=misc \
                --exclude-deb-section=net \
                --exclude-deb-section=news \
                --exclude-deb-section=oldlibs \
                --exclude-deb-section=otherosfs \
                --exclude-deb-section=perl \
                --exclude-deb-section=python \
                --exclude-deb-section=science \
                --exclude-deb-section=shells \
                --exclude-deb-section=sound \
                --exclude-deb-section=tex \
                --exclude-deb-section=text \
                --exclude-deb-section=utils \
                --exclude-deb-section=web \
                --exclude-deb-section=x11 \
```

which will deduce the size for syncing, but this won't reduce much.   

```
➜  UbuntuMirror du -hs *
22M	dists
33G	pool
12K	project
``` 

I think this is only works for debian.    
