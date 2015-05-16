---
layout: post
title: "Linux Tips"
date: 2014-10-18 19:21
comments: true
categories: Linux
---
### 1. Know the System Installation Date
You can use tune2fs to know the installation date of your Linux System, be ware the /dev/sda[] should be the root partition of your disk. See my following example:    

```
tune2fs -l /dev/sda1 or /dev/sdb1* | grep 'Filesystem created:'
$ sudo tune2fs -l /dev/sda2  | grep 'Filesystem created:' 
Filesystem created:       Mon May  5 17:31:40 2014

```
### 2. View Thread Status
View the thread status via proc filesystem.     

```
$ ps -ef | grep conky
Trusty      1396     1  0 19:15 ?        00:00:03 conky
Trusty      7410  6161  0 19:23 pts/5    00:00:00 grep --color=always conky
$ cd /proc/1396/task
$ ls
1396  1397  1398  1399  1400  1401  1402  1403
$ cat 1396/status| grep "State"
State:	S (sleeping)

```

### 3. Write to other users
Use w to get the tty, then write to other users.    

```
root@lilimarleen:/# w
 00:47:04 up 28 min,  2 users,  load average: 0.00, 0.01, 0.02
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
root     pts/0    1xx.xxx.xxx.xxx  00:26    0.00s  0.08s  0.00s w
root     pts/2    18x.xxx.xxx.xx   00:40   32.00s  0.03s  0.03s -bash
root@lilimarleen:/# echo "Hi, LiliMarleen">/dev/pts/2
root@lilimarleen:/# echo "Do you have lunch">/dev/pts/2

```

### 4. Share Terminals
Make sure the screen command is available on your machine, then:    
Server side:   

```
$ screen -S share

```
Client side:    

```
$ screen -x share

```
Now both side input could be seen.    
 

### 5. Create xz file
xz file will greatly decrease the file size, we use following command for create a xz file:    

```
tar cvfJ tar_xz_file.tar.xz folder_or_file

```
extract from xz from could be:    

```
tar -xJf tar_xz_file.tar.xz

```

### 6. Login issue
When you met 

```
file /home/xxx/.Xauthority does not exist

```
simply run following command once you login:   

```
$ startx

```
Next time you won't met this complains.    

### 7. Execution priviledge
Login to Opensuse, run ifconfig will complains it needs root priviledge:   

```
Absolute path to 'ifconfig' is '/sbin/ifconfig', so running it may require superuser privileges (eg. root)

```
Simply add one line to the end of your ~/.bashrc file:     

```
export PATH=/sbin/:$PATH

```
Next time you could directly run `ifconfig`, or if you don't want to change your .bashrc file, do `/sbin/ifconfig`.     

### 8. Show history timestap

```
[Trusty@Linux01 ~]$  export HISTTIMEFORMAT="%F %T `whoami` "
[Trusty@Linux01 ~]$ history | more
    6  2014-10-29 03:33:01 Trusty ls | grep trb
    7  2014-10-29 03:33:01 Trusty ./trbTest.py 
    8  2014-10-29 03:33:01 Trusty history |grep export
    9  2014-10-29 03:33:01 Trusty su root

```

### 9. Vrome setting    
Chromium install the vrome then set the options of     

```
set useletter=0

```
The keyshorts: go to address line Ctrl+L, in MAC Win+L.     

### 10. Replace the word until end of the line
In vim by following command:    

```
:%s/\<foo\>.*//
On each line, delete the whole word "foo" and all following text (to end of line).

```

### 11. Managing all of the running vagrants
See following command:    

```
[Trusty@/media/y/Vagrant/vccw/myproxy/vccw-1.9.1]$ VBoxManage list runningvms
"vccw-191_default_1417846604747_55987" {7b802d9e-dee2-4662-9694-e7cff6cbc49b}
[Trusty@/media/y/Vagrant/vccw/myproxy/vccw-1.9.1]$ VBoxManage controlvm vccw-191_default_1417846604747_55987 savestate
0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%

```

### 12. Battery 
To know the current battery via acpi, run:     

```
$ acpi -b

```
To know the more detailed info of Battery, goto:    

```
$ cd /sys/class/power_supply/BAT0

```

### 13. Add arp entry
So if you have rebooted the existing testing environment, your arp entries may be lost, simply use following command for adding it:     

```
$ arp -s 192.168.1.10 00:01:02:03:04:05

```
Now you will directly reached 192.168.1.10 via the specified mac address.     

### 14. Enable opera proxy
After Opera upgraded to latest version its configuration for proxy is failed, so I change the startup command from `opera` to:    

```
$ opera --proxy-server="socks://127.0.0.1:1395"
$ alias opera='opera --proxy-server="socks://127.0.0.1:1395"'

```

### 15. Delete a package and its configuration file
Use `pacman -R --help` for more detailed infos, so remove the vagrant including its configuration will be:    

```
$ sudo pacman -R vagrant -n

```

### 16. Install rar/unrar on CentOS    
Install the rar/unrar via following command:    

```
#  wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.i686.rpm
#  sudo rpm -ivh rpmforge-release-0.5.2-2.el6.rf.i686.rpm
#  sudo yum install rar unrar

```    

### 17. zsh History
The default installed zsh has no history record, thus we have to enable the history via following setting:     

```
$ touch $HOME/.zsh_history
$ tail ~/.zshrc
# For setting zsh history
HISTFILE=$HOME/.zsh_history
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
HISTSIZE=5000
SAVEHIST=5000

```
Now you will got the history recorded for 5000 lines, and each of them could be shared to each other.     

### 18. Calculate Code Lines
We could use cloc for calculate the code lines. In Ubuntu, simply run following commands for installing cloc:    

```
$ sudo apt-get install cloc

```
cloc via following command:    

```
$ cloc Your_Source_Code_Directory

```
After a while your statistics result will be displayed on the screen.    

### 19. CMAKE prefix
For specify the cmake's prefix we use following command:     

```
$ cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr ./ && make && sudo make install

```

### 20. xclip
Sometimes we have to quickly redirect some output from the system output to system clipboard, we use xclip, add following alias to your ~/.bashrc or ~/.zshrc:    

```
# Alias the xclip for directly to my system buffer, thus we could use shift+insert for copy the content.
alias myclip='xclip -selection clipboard'

```

### 21. Virtualbox Fixed Address
The host-only adapter should have the static addresses, thus you won't mix each other.     

```
$ sudo vim /etc/network/interfaces
auto eth1
iface eth1 inet static
    address 192.168.56.101
    netmask 255.255.255.0
    gateway 192.168.56.1

```

### 22. Autologin Using ssh
When you add the rsa content into the ~/.ssh/authorized_keys, but you still can't auto-login, then you have to consider the priviledge problem:    

```
$ ls ~/.ssh/authorized_keys  -l 
-rw-r--r--. 1 Trusty Trusty 392 Feb 11 11:36 /home/Trusty/.ssh/authorized_keys
$ chmod g-w ~/.ssh/authorized_keys

```
Now you could reach the machine without inputting password.    

### 23. Change Static Address For CentOS
Change the following file:    

```
$ sudo vim /etc/sysconfig/network-scripts/ifcfg-eth*
DEVICE=eth0 
BOOTPROTO=none 
ONBOOT=yes 
NETWORK=10.0.1.0 
NETMASK=255.255.255.0 
IPADDR=10.0.1.27 
USERCTL=no

```
Restart and then you could find your CentOS have static address.    


### 24. Disable Touchpad
First use `xinput list` for list all of the input devices for X, then set the property of them via:    

```
$ xinput list
⎡ Virtual core pointer                          id=2    [master pointer  (3)]
⎜   ↳ Virtual core XTEST pointer                id=4    [slave  pointer  (2)]
⎜   ↳ Logitech USB Optical Mouse                id=9    [slave  pointer  (2)]
⎜   ↳ PS/2 Generic Mouse                        id=12   [slave  pointer  (2)]
⎜   ↳ SynPS/2 Synaptics TouchPad                id=13   [slave  pointer  (2)]

......

$ xinput set-prop 13 "Device Enabled" 0


```

### 25. visudo
Sometimes in the visudo we set NOPASSWD, but it didn't take effects, why? because you are belong to some groups, while these group rules overwrite the previous rules you set, simply change all of the corresponding rules to:    

```
NOPASSWD:ALL

```
Save the file and now you will see `sudo command` won't ask you input anything.    

### 26. Youtube download
Ubuntu could directly download youtube videos via install youtube-dl:     

```
$ sudo apt-get install youtube-dl

```

### 27. perl-rename
As ArchLinux's default rename tool is very simple use following rename tools provided via perl:    

```
$ sudo pacman -S perl-rename
$  vim ~/.zshrc
### The default rename didn't support regex, use perl-rename instead.
alias rename='perl-rename'


```

### 28. udiskie
udiskie is for automatically mount/umount usb disks, but the ubuntu won't support it in official repository, we could install it via:    

```
$ sudo pip install udiskie

```
mount and umount disks via:    

```
$ sudo udiskie-mount -a
$ sudo udiskie-umount -a

```

### 29. git merge conflicts
Sometimes when you `git pull` from remote repository, you will got some anoying hint messages which shows you have merge conflicts, following is the steps for solving this issue:    

```
$ git pull
$ git stash
$ git pull

```
Now you are ready to work under merged trees.   

### 30. Git remote repository
When first git clone to local, then git push origin master, it will complains:    

```
[Trusty@~/Code/herokublog]$ git push origin master
fatal: remote error: 
  You can't push to git://github.com/xxxx/herokublog.git
  Use https://github.com/xxxx/herokublog.git
[Trusty@~/Code/herokublog]$ ssh -T git@github.com
X11 forwarding request failed on channel 0
Hi xxxx! You've successfully authenticated, but GitHub does not provide shell access.
[Trusty@~/Code/herokublog]$ git remote set-url origin git@github.com:xxxx/herokublog.git

```
After setting this, we could use `git push origin master` for submitting our changes.    

### 31. Replace all of the strings under one folder
Simply use sed for replacing these strings:    

```
Trusty@MassTestOnUbuntu1404:~/charms/trusty$ grep -rl "http://archive.ubuntu.com" ./ | wc -l
3
Trusty@MassTestOnUbuntu1404:~/charms/trusty$ grep -rl "http://archive.ubuntu.com" ./ | xargs sed -i 's|http://archive.ubuntu.com|http://http://mirrors.aliyun.com|g'
Trusty@MassTestOnUbuntu1404:~/charms/trusty$ grep -rl "http://archive.ubuntu.com" ./ | wc -l
0
Trusty@MassTestOnUbuntu1404:~/charms/trusty$ grep -rl "http://mirrors" ./ | wc -l
3

```

### 32. Use local LXC repository

```
So, let's say you downloaded the ubuntu trusty amd64 tarballs, you need to do:
 - mkdir -p /var/cache/lxc/download/ubuntu/trusty/amd64/default/
 - copy rootfs.tar.xz in /var/cache/lxc/download/ubuntu/trusty/amd64/default/
 - unpack the content of meta.tar.xz in /var/cache/lxc/download/ubuntu/trusty/amd64/default/
 - Then run the download template with: -d ubuntu -r trusty -a amd64

```

### 33. Use rsync for syncing the files

```
$ rsync -e 'ssh -p 1234' username@hostname:SourceFile DestFile
Example:    
$ rsync -avH --progress '-e ssh -p 2223' Trusty@1xx.xxx.xxx.xxx:/home/Trusty/charms/trusty/ ~/charms/trusty/

```

### 34. Use dmidecode to view your hardware configuration
dmidecode is a tool-set for dump out your SMIBIOS configuration in readable format, use following command for readout the maximum support moemory of your system, and the already installed memory information on your system:    

```
$ sudo dmidecode -t 16
$ sudo dmidecode -t 17

```

### 35. Use fslint for searching out the duplicated files
fslint could search the directory and find out the duplicated files.   
Install it via:    

```
$ sudo apt-get install fslint
$ fslint-gui

```

### 36. Limitation Bandwidth
Use following command could limit the specified userspace programs' bandwidth:    

```
$ trickle -s -d 50 -w 100 firefox
http://stackoverflow.com/questions/10328568/simulate-limited-bandwidth-from-within-chrome

```

### 37. Grep with color
grep's default output is without colorful output, do following for enable the colorful output:    

```
alias grep='grep --color=always'

```
Add this into your .zshrc, so everytime it boots up the grep will output with colors.   

### 38. RaspberryPI items
For optimize the RaspberryPI, need to do following:     

```
relatime/atime, use relatime
cat /sys/block/mmcblk0/queue/scheduler/
noop deadline cfq
use noop
[noop] deadline cfq

```

### 39. Install OpenStack On CentOS
The following tips:    

```
   35  packstack --answer-file=/root/answer.txt
   41  cat /etc/sysconfig/selinux
   42  vim /etc/selinux/config
Disable selinux, then try it again

```

<<<<<<< HEAD
### 40. Install OpenContrail/OpenStack
[https://fosskb.wordpress.com/2014/10/18/openstack-juno-on-ubuntu-14-10/](https://fosskb.wordpress.com/2014/10/18/openstack-juno-on-ubuntu-14-10/)    
[https://techwiki.juniper.net/Documentation/Contrail/Contrail_Controller_Getting_Started_Guide/10_In_Context%3A_Contrail_Controller_Getting_Started_Guide](https://techwiki.juniper.net/Documentation/Contrail/Contrail_Controller_Getting_Started_Guide/10_In_Context%3A_Contrail_Controller_Getting_Started_Guide)     
=======
### 40. Docker save/load
In the server, do:    

```
docker save ubuntu>/root/myubuntu.tar

```
Scp it to client machine, and in client machine, do:    

```
docker load</root/myubuntu.tar

```
Examine it via:    

```
[root@10-17-17-183 ~]# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
ubuntu              latest              d0955f21bf24        2 weeks ago         188.3 MB

```

### 41. Build Maas Based CentOS Image
Following is just the commands:    

```
root@pc121:~/iso/CentOSImage/maas-image-builder# #./bin/maas-image-builder -o centos6-amd64-root-tgz centos --edition 6                        
root@pc121:~/iso/CentOSImage/maas-image-builder# pwd
/home/clouder/iso/CentOSImage/maas-image-builder


```
>>>>>>> 58372fecc80eeda12cddd4001534fc541cab8f30

### 42. View multiply errors
For displaying all of the error/warnings.    

```
for file in $(ls /var/log/nova/); do cat /var/log/nova/$file | grep -iE 'error|warn' ; done

```

### 43. Reference for docker and contrail
[http://www.opencontrail.org/docker-with-opencontrail/](http://www.opencontrail.org/docker-with-opencontrail/)     

### 44. Run Jobs at certain time
Following is an example for automatically download the iso file at the spare time of the office network.     

```
# echo "wget http://mirrors.aliyun.com/ubuntu-releases/15.04/ubuntu-15.04-server-amd64.iso -O /home/juju/iso/ubuntu-15.04-server-amd64.iso " | at 12:27

```

### 45. Check kvm
We could use `kvm-ok` for checking your cpu is compatible for use kvm acceleration.    

```
$ sudo apt-get install cpu-checker
$ kvm-ok

```
The output will shows whether your cpu support kvm or not.   

### 46. Quickly Installation the Desktop
Turn your minimal CentOS into a full Desktop:     

```
$  sudo yum install system-config-kickstart
$  sudo yum install gnome-desktop
$  sudo yum -y groupinstall "X Window System" "Desktop"

```
Enter the desktop via `startx`

### 47. Restart bluetooth in Ubuntu
Sometimes the bluetooth will fail on Ubuntu, using following command for restart the bluetooth service:    

```
$ sudo /etc/init.d/bluetooth restart

```
Now you could continue to detect the devices and setup the configuration.     
