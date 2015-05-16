---
layout: post
title: "My Translator in ArchLinux+Awesome"
date: 2013-10-19 11:23
comments: true
categories: Linux Bash
---
###BackGround
My requirement is quite simple:  I read many english content based website everyday, this means I always encounter many unkown words. My solution is use a translatio software or directly refer them in [translate.google.com](http://translate.google.com "translate.google.com"). But all of these ways were time-consuming process: you have to switch to other software, or you have to open new tabs in your web brower. So do we have a more sufficient way for doing these steps? I used a whole morning of my saturday and finished this procedure.  
###Preparation
You have to install google translator for CLI in ArchLinux's yaourt, you can choose git version or standard version , I choose git version:  

```
	$ yaourt -S google-translate-cli-git
```

After the installation, you can refer to [http://www.soimort.org/google-translate-cli/](http://www.soimort.org/google-translate-cli/ "http://www.soimort.org/google-translate-cli/") for more detailed usage for this tool. For example:  

```
	[Trusty@DashArch ~]$ trs {=zh} "Hello, world"
	你好，世界
```

###Using Notification under awesome
Yes we can use "notify-send" to directly display something on the screen, but notify-send is not convinient for us to control its behavior, 

```
	notify-send $title $result --icon=dialog-information
```

So we will use awesome's own notification module, name naughty. But first we have to add a new globle variable in rc.lua which under your own configuration directory, mine is under:
{% codeblock rc.lua -rc.lua %}
[Trusty@DashArch ~]$ cat /home/Trusty/.config/awesome/rc.lua | more
-- Standard awesome library
-- Notification library
local naughty = require("naughty")
naughty1 = require("naughty")
{% endcodeblock %}
If we directly using rc.lua's local variable "naughty",  awesome will complaint it cannot find the variable thus cannot display notification.  
The method for displaying notification via naughty is as:
	echo 'naughty1.notify({title = "testing", text = "naughty"})' | awesome-client -
Notice naughty1 is the newly added variable in our configuration file.  
###Our own bash script
{% codeblock mytran.sh -mytrans.sh %}
#!/bin/bash
# check parameters
EXPECTED_ARGS=1
if [ $# -lt $EXPECTED_ARGS ]
then
	echo "Usage: `basename $0` Your_Tranlate_Word"
	notify-send "null" "null" --icon=dialog-information
	exit -1
fi
title=$@
declare -a result1
result1=`trs {=zh} "$@"`
result=""
for var in ${result1[@]};do
	result=$result' '$var
done
echo "naughty1.notify({title = \"$title\", text = \"$result\", timeout = 5, height = 100, font = \"Verdana 20\", bg = \"BB68D9\", timeout=5})" | awesome-client -
{% endcodeblock %}
###Result
The script is called via:  
when you are browsing the webpage, if you encounter the words, simply press mod4+r, it will call the 'run' window, input mytrans.sh "Your words" then you will get the notification window at the top right of your monitor. This window will last for 5 seconds, then vanished.  the image is like following:  
![/images/notify.jpg](/images/notify.jpg "notify picture") 
 
Finally we can enjoy the non-blocking thinking reading now. 
