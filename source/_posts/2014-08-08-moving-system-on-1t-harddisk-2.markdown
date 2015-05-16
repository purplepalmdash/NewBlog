---
layout: post
title: "Moving System on 1T Harddisk(2)"
date: 2014-08-08 20:47
comments: true
categories: Linux
---
### Tips
Here are some tips for customize the existing system.     
1\. Add octopress directory to heroku repository.     
Install heroku client tools:     

```
$ yaourt -S heroku-client
$ heroku keys:add
Found existing public key: /home/Trusty/.ssh/id_rsa.pub
Uploading SSH public key /home/Trusty/.ssh/id_rsa.pub... done

```
Now in the copied octopress directory we could use git push command for pushing our website onto herokuapp.    

2\. MTP Device

```
sudo pacman -S libmtp


``` 

3\. libvirt    

```
sudo pacman -S libvirt

```

4\. virtualbox-ext-oracle    
By installing this you can use USB2.0.     

```
yaourt -S virtualbox-ext-oracle

```
Download Virtualbox Guest ISO.    
Set Proxy in virtualbox global.    

add user "Trusty" to "vboxusers":    

```
$ gpasswd -a Trusty vboxusers
$ usermod -a -G vboxusers Trusty

```
Now the virtualbox could use usb. And be sure to run following at suitable place:    

```
$ modprobe vboxdrv vboxnetflt vboxnetadp
$ modprobe vboxnetflt
$ modprobe vboxnetadp

```

4\. Lumia On ArchLinux    
I don't have good options, but connect it into virtualbox and use it.     
Install the corresponding driver. and browser your phone content in Windows 7.    

5\. lampp adjustment    
Since the public directory is not available in my system, so I have to change the default directory from the octopress public to /opt/public.    
Then, in Rakefile, add this line:    

```
#######################
# Working with Jekyll #
#######################

desc "Generate jekyll site"
task :generate do
  raise "### You haven't set anything up yet. First run `rake install` to set up an Octopress theme." unless File.directory?(source_dir)
  puts "## Generating Site with Jekyll"
  system "compass compile --css-dir #{source_dir}/stylesheets"
  system "jekyll"
  # Copy the content to the public directory
  system "sudo cp -r /home/Trusty/code/octo/heroku/Tomcat/public /opt"
end

```

6\. gedit

```
sudo pacman -S gedit 

```

7\. Remmina    
I use remmina for connecting to my own Surface pro, because it will automatically "shrink" my Desktop for the right resolution. Install it via:     

```
sudo pacman -S remmina

```
For Surface pro, because it has resolution as 1920x1080,so use toggle mode could get better effects.    

8\. aurget    
This is a simple client for aur repository packages, install via yaourt    

```
yaourt -S aurget

```

9\. acpi    
Using acpi for viewing the battery status:    

```
sudo pacman -S acpi

```

10\. Recordmydesktop    
For recording specified screen and output to ogv or other format:   

```
sudo pacman -S gtk-recordmydesktop recordmydesktop

```

11\. Rss Reader    
I installed liferea for view RSS.     

```
sudo pacman -S liferea

```

12\. Rstudio    
RStudio is used for generate pdf from md(markdown) file.    

```
sudo yaourt -S rstudio

```

13\. pdflatex    
Need it for compiling pdf out:    

```
yaourt -S pdflatex.sh

```

14\. you-get-git     
For downloading videos from youtube/CNTV, etc..     

```
yaourt you-get-git

```

15\. git under proxy    
The detailed configuration steps should be changed via:    

```
git config --global core.gitproxy /usr/bin/myproxy

```

16\. pandoc    
Install pandoc via yaourt:   

```
yaourt pandoc

```

17\. wkhtmltopdf    
Install wkhtmltopdf via pacman:    

```
sudo pacman -S wkhtmltopdf
wkhtmltopdf -s A4  -B 10 -T 10 ./Output/CV_Chinese.html ./Output/CV_Chinese.pdf

```
-B Bottom Margin, -T Top Margin.    

18\. expect    
For automatically login and doing processing.    

```
sudo pacman -S expect

```

19\. Minicom    
Minicom is a serial port terminal tool for minitoring serial ports.    

```
sudo pacman -S minicom

```

20\. Multilib Support    
Uncomment following 2 lines in /etc/pacman.conf:    

```
[multilib]
Include = /etc/pacman.d/mirrorlist

```

30\. lib32-glibc    
For using 32-bit applications:    

```
sudo pacman -S lib32-glibc

```

31\. ghex   
For viewing the binary file under Linux:    

```
sudo pacman -S ghex

```

32\. lib32-gtk2    
Install this for compatable for CodeSourcery's toolchain installation:    

```
sudo pacman -S lib32-gtk2

```

33\. lib32 others:    
Install following packages for CodeSourcery:    

```
sudo pacman -S xulrunner lib32-xcb-util lib32-gtk-engines lib32-ncurses

```

34\. fbreader:     
fbreader is for opening the epub files:     

```
sudo pacman -S fbreader

```

35\. Auto update the dkms:    
For building the virtualbox modules:    

```
 sudo systemctl enable dkms.service

```

36\. Fakeroot    
For building some embedded systems.    

```
sudo pacman -S fakeroot

```

37\. dosfstools    
Install it for obtains mkfs.vfat:     

```
sudo pacman -S dosfstools

```

38\. tsocks    
For acrossing the company firewall:    

```
sudo pacman -S tsocks

```
Then edit the configuration file:    

```
$ cat /etc/tsocks.conf 
server = 127.0.0.1
server_type = 5
server_port = 1394

```
You can run `tsocks gnome-terminal` for getting a totally free terminal.    

39\. For building Android    
Install required packages:    

```
$ sudo pacman -S gcc-multilib lib32-zlib lib32-ncurses lib32-readline

```
Notice this will remove the gcc and gcc-libs, for gcc-libs-multilib and gcc-multilib will be conficted with the origin installed gcc and gcc-lib version.    

Use Sun/Oracle JDK for compiling:    

```
$ set2383
$ yaourt jdk6-compat
$ export JAVA_HOMNE=/opt/java6

```
For using virtualenv2 you have to install:    

```
$ sudo pacman -S python2-virtualenv
$ virtualenv2 venv
New python executable in venv/bin/python2
Also creating executable in venv/bin/python
Installing setuptools, pip...done.
$ ln -s /usr/lib/python2.7/* /media/y/embedded/Android/ubuntu/venv/python2.7/
$ repo sync
$ /bin/bash
$ source venv/bin/activate

```
Install make 3.81 for building:    

```
$ sudo yaourt make 3.81
$ make-3.81 -j4

```
Lacking flex, install it via:    

```
$ sudo pacman -S flex

```
Lacking gperf, install it via:    

```
$ sudo pacman -S gperf

```
Install perl related(first configure as automatic, then install switch):    

```
$ cpan App::cpanminus
$ cpanm Switch

```
Then install gcc44 from yaourt:    

```
$ yaourt -S gcc44

```
Build with gcc44:    

```
$ make-3.81 CC=gcc-4.4 CXX=g++-4.4 -j4

```
Met build error:        

```
  error: aggregate ‘setrlimitsFromArray(ArrayObject*)::rlimit rlim’ has incomplete type and cannot be defined struct rlimit rlim; ^ 

```
Solution is simply to add #include <sys/resource.h> to dalvik/vm/native/dalvik_system_Zygote.cpp. 
When you met compatible, install gcc44-multilib:    

```
yaourt -S gcc44-multilib 

```

39\. pavucontrol     
pavucontrol is A GTK volume control for PulseAudio, install it for redirecting the sound into the bluetooth device.    

```
$ sudo pacman -S pavucontrol

```

40\. nfs    
For embedded Linux development, we have to use nfs(Network FileSystem) so we install it via:    

```
sudo pacman -S nfs-utils

```
To be configured, because the parameters is complicated.    

41\. xclip    
For using clipboard under X, we have to install this tool.     

```
sudo pacman -S xclip

```

42\. avidemux    
For modify the videos under Linux:    

```
sudo pacman -S avidemux avidemux-gtk

```
It couldn't handle ogv format.    

43\. pitivi    
    Editor for audio/video projects using the GStreamer framework, we also add some plugins.       

```
$ sudo pacman -S pitivi
$ sudo pacman -S gst-libav gst-plugins-bad gst-plugins-ugly frei0r-plugins

```
But pitivi won't run on archlinux, for lacking the pycanberra, so I try the openshot.    

44\. openshot    

```
$ sudo pacman -S openshot

```

45\. Mencoder:   
For converting video format:    

```
$ sudo pacman -S mencoder
$ mencoder output.flv -o video_final.flv -ovc copy -oac copy -audiofile xxx.mp3

```

46\. ffmpeg:    
For converting video format:    

```
$ sudo pacman -S ffmpeg
$ ffmpeg -i out.ogv -vcodec libx264 -strict -2  output.mp4 

```

47\. p7zip   
p7zip is the linux version 7zip:    

```
$ sudo pacman -S p7zip

```

48\. Acrobat Reader    
Sometimes evince will crash when viewing some embedded picture pdf, we use Acrobat Reader for viewing such pdfs:    

```
$ sudo pacman -S acroread

```
Notice, acroread package only includes in archlinuxfr, so firstly you should add archlinuxfr in your pacman.conf.     

49\. Konsole    
Since the gnome-terminal will be not see input line when you enable the new tabs, I install konsole and use it as default terminal:     

```
$ sudo pacman -S kdebase-konsole

```
Change the default run command to zsh -l, this will enable the "run as login shell", then change the default shortcuts, also you should change the default fonts just like we used set in xfce4-terminal/gnome-terminal.     
Default font changes:    

```
$ cat ~/.kde4/share/apps/konsole/Shell.profile
[Appearance]
ColorScheme=DarkPastels
Font=YaHei Consolas Hybrid,13,-1,5,50,0,0,0,0,0

```
Now re-login your desktop environment(mine is awesome), you will found the font has been changed in the konsole terminal.   
Alter the startup window of konsole, and don't let it recovers to the last altered size:     
![/images/konsolesize.jpg](/images/konsolesize.jpg)        

50\. pip-shadowsocks
First you should install pip via:    

```
$ sudo pacman -S python-pip
$ sudo pacman -S python2-pip

```
Since shadownsocks only support python2, install python2 is the right way.     

```
$ sudo pip2 install shadowsocks

```

51\. DNSutils    
For querying the dns.    

```
sudo pacman -S dnsutils

```
Then you could use host/dig/nslookup, etc.     

52\. gdisk    
For format into gpt format's fdisk:    

```
sudo pacman -S gdisk

```

53\. pandoc-static     
For generating beautiful pdf and other formats of documentations.      

```
# yaourt -S pandoc-static --noconfirm

```

54\. ShadowSocks     
For crossing the GFW:     

```
sudo pacman -S shadowsocks

```

55\. mtools    
For using mcopy, etc:   

```
sudo pacman -S mtools

```

56\. lzop    
File compressor using lzo lib, for compiling some images:    

```
$ sudo pacman -S lzop

```

57\. vnstat      
For monitoring the network traffic:     

```
$ sudo pacman -S vnstat
$ sudo systemctl start vnstat.service
$ sudo systemctl enable vnstat.service
$ sudo vnstat -u -i enp0s25

```
Use following commands for querying the traffic statistics:    

```
$ vnstat -q

```

58\. htop    
For viewing the system performance, comparing to top, its display will be more clearly.     

```
$ sudo pacman -S htop

```

59\. virtualbox-ext-oracle      
For enable usb or other attached devices:    

```
yaourt -S virtualbox-ext-oracle

```

60\. lighthttpd    
For replacing the heavy xampp, use it for serving the static website:    

```
sudo pacman -S lighttpd

```

61\. Synergy     
For sharing the mouse and keyboard between different systems.      

```
sudo pacman -S synergy qsynergy

```

