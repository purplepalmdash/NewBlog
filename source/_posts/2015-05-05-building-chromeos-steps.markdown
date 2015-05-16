---
layout: post
title: "Building ChromeOS Steps"
date: 2015-05-05 11:43
comments: true
categories: Linux
---
My aim is for enable the bluetooth Networking in my Chromebook, AKA BNEP, so first I have to build out some experimentation platforms for investigation, following is the steps for building out the ChromeOS Images and let it run under kvm based virtual machine.    
### Prerequistites
I use a 6-Giga-Byte memory machine for building, first install following packages:    

```
$ sudo apt-get install git-core gitk git-gui subversion curl

```
Since I am in china mainland, the connection to googlesourcecode is blocked by Great Fire Wall(Fuck you!), I have to use proxychains for automatically convert my TCP/UDP flow to sock flow. That's why in some steps I use proxychains4 in front of the commands. If you are free to reach Internet, you should remove the proxychains4 in front of each command.   
Then install `depot_tools`.   

```
dasdh@BuildMaasImage:~/Code$ pwd
/home/dasdh/Code
dasdh@BuildMaasImage:~/Code$ mkdir depot_tools
dasdh@BuildMaasImage:~/Code$ proxychains4  git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
$ export PATH=`pwd`/depot_tools:"$PATH"
$ echo $PATH
/home/dasdh/Code/depot_tools:/home/dasdh/Code/depot_tools:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games

``` 
Config git:    

```
dasdh@BuildMaasImage:~/Code$ git config --global user.email "kkkttt@gmail.com"
dasdh@BuildMaasImage:~/Code$ git config --global user.name "Dash"

```
Maybe in the future you will use github repository, better you use `ssh-keygen` to generate the public ssh key and upload it to github.    Make sure your architecture is x86_64, and add following into your ~/.bashrc:     

```
dasdh@BuildMaasImage:~/Code$ uname -m
x86_64
dasdh@BuildMaasImage:~/Code$ cat ~/.bashrc | grep umask
umask 022

```
### Get Source Code
Get the code via following commands:   

```
dasdh@BuildMaasImage:~$ mkdir chromiumos
dasdh@BuildMaasImage:~$ pwd
/home/dasdh

```
Then get the credential for chromiumOS( go to https://chromium-review.googlesource.com/new-password for getting the commands):    

```
$  touch ~/.gitcookies
$  chmod 0600 ~/.gitcookies
$  git config --global http.cookiefile ~/.gitcookies
$  tr , \\t <<\__END__ >>~/.gitcookies
 .googlesource.com,TRUE,/,TRUE,2147483647,o,git-kkkttt.gmail.com=1/goeugoueogewoguoweugoawohouaohuowauhoaeuo
 __END__
$  git config --global "url.https://chromium.googlesource.com/a/.insteadOf" "https://chromium.googlesource.com/"
$  git config --global --add "url.https://chromium.googlesource.com/a/.insteadOf" "https://chromium.googlesource.com/a/"
$  proxychains4 git ls-remote https://chromium.googlesource.com/a/chromiumos/manifest.git

```
The final output result should be a list of file.   
Because the google source code use https connection, so we need to define the .netrc like following:    

```
$ touch ~/.netrc
$ chmod 0600 ~/.netrc
$ vim ~/.netrc
machine chromium.googlesource.com
login git-kkkttt.gmail.com
password agowugoweugowugouwoguoweugoeugo

machine chromium-review.googlesource.com
login git-kkkttt.gmail.com
password agowugoweugowugouwoguoweugoeugo

```
Now your configuration is ready, initialize the repository via:    

```
$ proxychains4 repo init -u https://chromium.googlesource.com/chromiumos/manifest.git --repo-url https://chromium.googlesource.com/external/repo.git
$ proxychains4 repo sync 

```
repo sync will take a very long time for getting all of the source code down, and it will takes arount 8G disk size.   
### Build Source Code
After source code is avaiable, start building it via:    

```
$ proxychains cros_sdk

```
Since the proxychains failed, I've enable the redsocks for crossing the GFW, in the last part of this article shows its installation and configuration.    
Using redsocks we could continue the building:    

```
$ cros_sdk
dasdh@BuildMaasImage ~/trunk/src/scripts $ 

```
Now start building via:    

```
#  export BOARD=amd64-generic
# ./setup_board --board=${BOARD}
# ./set_shared_user_password.sh
# ./build_packages --board=${BOARD}
# ./build_image --board=${BOARD} --noenable_rootfs_verification dev

```
If you met hostname error, make sure your hostname is added in `/etc/hosts`.    

The building result is listed as:    

```
(cr) dasdh@BuildMaasImage ~/trunk/src/build/images/amd64-generic/R44-7040.0.2015_05_06_0543-a1 $ pwd
/home/dasdh/trunk/src/build/images/amd64-generic/R44-7040.0.2015_05_06_0543-a1
(cr) dasdh@BuildMaasImage ~/trunk/src/build/images/amd64-generic/R44-7040.0.2015_05_06_0543-a1 $ ls -l -h
total 1.2G
-rw-r--r-- 1 dasdh eng  399 May  6 05:52 boot.config
-rw-r--r-- 1 dasdh eng  214 May  6 05:49 boot.desc
-rw-r--r-- 1 dasdh eng 2.5G May  6 05:52 chromiumos_image.bin
-rw-r--r-- 1 dasdh eng  586 May  6 05:52 config.txt
drwxr-xr-x 2 dasdh eng 4.0K May  6 05:52 esp
-rwxr-xr-x 1 dasdh eng 5.6K May  6 05:43 mount_image.sh
-rwxr-xr-x 1 dasdh eng 4.8K May  6 05:43 pack_partitions.sh
-rw-r--r-- 1 dasdh eng  12K May  6 05:43 partition_script.sh
-rwxr-xr-x 1 dasdh eng 4.7K May  6 05:43 umount_image.sh
-rwxr-xr-x 1 dasdh eng 5.0K May  6 05:43 unpack_partitions.sh

```
I think the chromiumos_image.bin is what we want.   
### RedSocks
Download the redsocks source code and compile it:    

```
# cd /opt/src
# git clone https://github.com/darkk/redsocks.git
# cd redsocks
# apt-get install libevent-dev 
# make 

```
Write configuration files:    

```
# cat redsocks.sh
#! /bin/sh

case "$1" in
  start|"")
    cd /opt/src/redsocks
    if [ -e redsocks.log ] ; then
      rm redsocks.log
    fi
    ./redsocks -p /opt/src/redsocks/redsocks.pid #set daemon = on in config file
    # start redirection
    iptables -t nat -A OUTPUT -p tcp --dport 80 -j REDIRECT --to 12345
    iptables -t nat -A OUTPUT -p tcp --dport 443 -j REDIRECT --to 12345
    ;;

  stop)
    cd /opt/src/redsocks
    if [ -e redsocks.pid ]; then
      kill `cat redsocks.pid`
      rm redsocks.pid
    else
      echo already killed, anyway, I will try killall
      killall -9 redsocks
    fi
    # stop redirection
    iptables -t nat -F OUTPUT
    ;;

  start_ssh)
    #ssh -NfD 1234 user@example.cc #TODO: change it!!!
    ssh -NfD 1234 544644af4382ec37bc0009da@weatherapp-kkkttt.rhcloud.com
    ;;

  stop_ssh)
    ps aux|grep "ssh -NfD 1234"|awk '{print $2}'|xargs kill
    ;;

  clean_dns)
    iptables -A INPUT -p udp --sport 53 -m state --state ESTABLISHED -m gfw -j DROP -m comment --comment "drop gfw dns hijacks"
    ;;

  *)
    echo "Usage: redsocks start|stop|start_ssh|stop_ssh|clean_dns" >&2
    exit 3
    ;;
esac
# cat redsocks.conf
base {
        // debug: connection progress & client list on SIGUSR1
        log_debug = on;

        // info: start and end of client session
        log_info = on;

        /* possible `log' values are:
         *   stderr
         *   file:/path/to/file
         *   syslog:FACILITY  facility is any of "daemon", "local0"..."local7"
         */
        log = stderr;

        // detach from console
        daemon = on;

        /* Change uid, gid and root directory, these options require root
         * privilegies on startup.
         * Note, your chroot may requre /etc/localtime if you write log to syslog.
         * Log is opened before chroot & uid changing.
         */
        // user = nobody;
        // group = nobody;
        // chroot = "/var/chroot";

        /* possible `redirector' values are:
         *   iptables   - for Linux
         *   ipf        - for FreeBSD
         *   pf         - for OpenBSD
         *   generic    - some generic redirector that MAY work
         */
        redirector = iptables;
}

redsocks {
        /* `local_ip' defaults to 127.0.0.1 for security reasons,
         * use 0.0.0.0 if you want to listen on every interface.
         * `local_*' are used as port to redirect to.
         */
        local_ip = 127.0.0.1;
        local_port = 12345;

        // `ip' and `port' are IP and tcp-port of proxy-server
        ip = 127.0.0.1;
        port = 1234;

        // known types: socks4, socks5, http-connect, http-relay
        type = socks5;
}


```
Everytime you use the redsocks, enable it via:     

```
# ./redsocks.sh start_ssh
# ./redsocks.sh start

```
Disable it via:     

```
# ./redsocks.sh stop
# ./redsocks.sh stop_ssh

```

### Run ChromeOS in kvm
Now Transfer the image to image for vm:     

```
$ export BOARD=amd64-generic
(cr) dasdh@BuildMaasImage ~/trunk/src/build/images/amd64-generic/latest $ cd ~/trunk/src/scripts/
(cr) ((df83602...)) dasdh@BuildMaasImage ~/trunk/src/scripts $ ./image_to_vm.sh --board=${BOARD}
Resizing stateful partition to 3072MB

```
Verify if kvm is supported on your system:    

```
dasdh@BuildMaasImage:~/src/scripts$ kvm-ok
INFO: /dev/kvm exists                                                                                                                          
KVM acceleration can be used      

```
Now run via:    

```
$ cd ~/chromiumos/src/scripts
$ ./bin/cros_start_vm --image_path=../build/images/${BOARD}/latest/chromiumos_qemu_image.bin

```
