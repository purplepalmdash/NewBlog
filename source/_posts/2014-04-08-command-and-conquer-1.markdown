---
layout: post
title: "Command and Conquer 1"
date: 2014-04-08 17:19:22 +0800
comments: true
categories: C&C
---
###Position: 
From FullCircle 13, Ended at FullCircle 23.     
###C&C 1
Try to run following command:    

```sh run.sh
man man
man -k PDF
man apropos
apropos PDF
man --help

```
Fastly get help from manual, for example, following command will let you dive into regex:    

```sh run.sh
man -k regex
re_comp (3)          - BSD regex functions
re_exec (3)          - BSD regex functions
regcomp (3)          - POSIX regex functions
regerror (3)         - POSIX regex functions
regex (3)            - POSIX regex functions
regex (7)            - POSIX.2 regular expressions
regexec (3)          - POSIX regex functions
regfree (3)          - POSIX regex functions

````
###C&C 2
This part describe how to come and go into the directory.
###C&C 3
This part describe how to copy and move the file.     
###C&C 4
This part introduce the nano and vim. Remember one: :e in vim means edit another file.     
###C&C 5
This part introduce aptitude, Notice the comment of the aptitude search result:    
1. p, No trace of the package exists on the system.    
2. c, The package is deleted, but its configuration file is still on the system.    
3. i, The package is installed.     
4. v, The package is virtual.    
And one command: sudo aptitude safe-upgrade.     
###C&C 6
This part shows how to find something in your system.    
1. grep, "grep -n"(print line number),  "grep -ir"(recursively and ignore case).    
2. *, difference of "echo *" and "echo '*'".    
3. xargs,     

```sh run.sh
find recipes -type f -name '*-cake.txt' | xargs -I % cp % old-recipes/
find recipes -type f -name '*-cake.txt'
recipes/a-cake.txt
recipes/b-cake.txt
recipes/c-cake.txt
cp recipes/a-cake.txt old-recipes/
cp recipes/b-cake.txt old-recipes/
cp recipes/c-cake.txt old-recipes/

```
4. updatedb and locate.     
###C&C 7
The author talks lots on why you should not fear terminal.    
###C&C 8
1. cut way:     

```sh cut.sh
Trusty@HN:~/code/purec/FC/C8$ cat /etc/issue
Ubuntu 13.04 \n \l

Trusty@HN:~/code/purec/FC/C8$ cat /etc/issue|head -n 1
Ubuntu 13.04 \n \l
Trusty@HN:~/code/purec/FC/C8$ cat /etc/issue|head -n 1|cut --delimiter=" " -f 1,2
Ubuntu 13.04

```
2. sed way:     

```sh sed.sh
Trusty@HN:~/code/purec/FC/C8$ cat /etc/issue | sed '{s/\\n//}'
Ubuntu 13.04  \l

Trusty@HN:~/code/purec/FC/C8$ cat /etc/issue | sed '{s/\\n//; s/\\l//;}'
Ubuntu 13.04  

Trusty@HN:~/code/purec/FC/C8$ cat /etc/issue | sed '{s/\\n//; s/\\l//;/^$/d}'
Ubuntu 13.04  

```
3. awk way:    

```sh awk.sh
Trusty@HN:~/code/purec/FC/C8$ cat /etc/issue | awk '/\\n/ {print $1,$2}'
Ubuntu 13.04

```
First find any line which have '\n' in it, then print this line's $1 and $2.    
4. Further reading    
http://fullcirclemagazine.org/issue-21-shell-script/    
Sed -http://www.grymoire.com/Unix/Sed.html    
awk -http://www.linuxjournal.com/article/8913 or http://www.linuxfocus.org/English/September1999/article103.html    
cut -http://learnlinux.tsf.org.za/courses/build/shell-scripting/ch03s04.html    
###C&C 9 
This part introduced the ffmpeg and imagick.     
Since the internet is not OK, I cannot install the package, try them later.    
###C&C 10
This part is very useful, it shows some system administration tools.    
1. bootchart, install via "sudo apt-get install bootchart", then in /var/log/bootchart/ you will see the correct image.    
2. sudo lshw will list all of the hw info, sudo lshw -C Network will list all of the infos on networking.     
3. Further reading: http://www.troubleshooters.com/tpromag/200007/200007.htm    



