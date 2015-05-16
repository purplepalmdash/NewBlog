---
layout: post
title: "Build ChromiumOS"
date: 2014-11-05 17:43
comments: true
categories: Linux
---
### First Time Build
This build failed for I could not get the repository sync.    

I setup the environment on 159's /media/nfs:     

```
$ git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
$ export PATH="$PATH":`pwd`/depot_tools
$ echo $PATH
/home/ubuntu/bin:/home/ubuntu/bin:/home/ubuntu/bin:/home/ubuntu/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/media/nfs/ChromiumOS/depot_tools
$ cat script.sh 
#!/bin/sh
cat >./sudo_editor<<EOF
#!/bin/sh
echo Defaults !tty_tickets > $1
echo Defaults timestamp_timeout=180 >> $1
EOF
chmod +x ./sudo_editor
sudo EDITOR=./sudo_editor visudo -f /etc/sudoers.d/relax_requirements
$ export BOARD=x86-generic
$ repo init -u https://git.chromium.org/chromiumos/manifest.git
$ repo sync

```
### Second Time Build


```
Trusty@Linux59:~/Code/ChromiumOS> pwd
/home/Trusty/Code/ChromiumOS
Trusty@Linux59:~/Code/ChromiumOS>  git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
Trusty@Linux59:~/Code/ChromiumOS> export PATH=`pwd`/depot_tools:"$PATH"
Trusty@Linux59:~/Code/ChromiumOS> mkdir chromiumos
Trusty@Linux59:~/Code/ChromiumOS> cd chromiumos/
Trusty@Linux59:~/Code/ChromiumOS/chromiumos> repo init -u https://chromium.googlesource.com/chromiumos/manifest.git --repo-url https://chromium.googlesource.com/external/repo.git 
Trusty@Linux59:~/Code/ChromiumOS/chromiumos> repo sync
Trusty@Linux59:~/Code/ChromiumOS/chromiumos> cros_sdk
root's password:
(cr) ((c405e7b...)) Trusty@Linux59 ~/trunk/src/scripts $ export BOARD=x86-generic
(cr) ((c405e7b...)) Trusty@Linux59 ~/trunk/src/scripts $ ./setup_board --board=${BOARD}
# ./set_shared_user_password.sh
# ./build_packages --board=${BOARD}


```
