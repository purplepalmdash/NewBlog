---
layout: post
title: "Write Local ntp sync server"
date: 2014-02-11 19:36
comments: true
categories: ntp
---
Due to frequently query the ntp webserver, the website is banned by the administrator, thus I have to think about another way for updating the local machine's time on OpenWRT.    
First, install the coreutils-date:
	opkg install coreutils-date
Add the no-login for local server:
	cat id_rsa.pub | ssh ddddd@1xx.xxx.xxx.xxx 'cat >.ssh/authorized_keys'
Now you can directly call remote command via:
	ssh ddddd@1xx.xxx.xxx.xxx ls 
OK, we update the time.sh

```sh time.sh
#!/bin/sh
#echo $http_proxy
#echo $https_proxy
#date $(wget -O - "http://www.timeapi.org/utc/in+eight+hours" 2>/dev/null | sed s/[-T:+]/\ /g | awk '{print $2,$3,$4,$5,".",$6}' | tr -d " " )
timestring=`ssh ddddd@1xx.xxx.xxx.xxx date`
echo $timestring
/usr/bin/date -s "$timestring"

```
Add the following line into the crontab
	* */3 * * * /bin/time.sh
Now you can enjoy the local server updated time. 
