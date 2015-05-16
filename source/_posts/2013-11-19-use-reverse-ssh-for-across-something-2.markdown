---
layout: post
title: "Use Reverse SSH for Across Something(2)"
date: 2013-11-19 14:03
comments: true
categories: Linux ssh
---
###ssh command 
Take following command for detailed example of using ssh:

```
	alias mydaili='ssh -qTfnN -D '
	-q Quite Mode
	-T Disable pseudo-tty allocation
	-f background the ssh
	-n redirect the stdin from /dev/null
	-N Don't execute a remote command
	-D Bind address

```
###Using rsh
rsh could be used for executing the command remotely, thus in my family's debian machine I could write following script:

```bash remoteON.sh
	cat /bin/remoteON 
	#!/bin/sh
	rsh -l root localhost -p 4381  ssh -qTfnN -L 1XX.XXX.XXX.XXX:9004:1XX.XXX.XXX.XXX:8000 USERNAME@remoteserver.com &
	chmod 777 /bin/remoteON

```
For killing the remote machines's running ssh tunnel process, write another script:

```bash remoteOFF.sh
	!#/bin/sh
	#Fetch the ssh id
	sshid=`rsh -l root localhost -p 4381 ps | grep "ssh -qTfnN" | awk '{print $1}'`
	#Kill the selected process
	rsh -l root localhost -p 4381 kill $sshid
	$ chmod 777 /bin/remoteOFF

```
###Write the local script
Local Scripts is for calling the remoteON and remoteOFF.     
Script for starting the proxy

```bash startproxy.sh
#!/bin/sh
#Start the openWRT Tunnel
rsh -l root 10.0.0.111 /bin/remoteON &
#Sleep 3 seconds
sleep 3
#Start the Debian Tunnel
rsh -l root 10.0.0.111 ssh -qTfnN -L 10.0.0.111:9001:1XX.XXX.XXX.XXX:9004 root@localhost -p 4381 &


```
Script for stopping the proxy

```bash stopproxy.sh
#!/bin/sh
# Stop the openWRT Tunnel:
rsh -l root 10.0.0.111 /bin/remoteOFF &
# Sleep 3 seconds
sleep 3
# Stop the Debian Tunnel
sshid=`rsh -l root 10.0.0.111 ps -ef | grep "ssh -qTfnN" | awk '{print $2}'`
rsh -l root 10.0.0.111 kill $sshid &

```
###How to use it?
If you want to use proxy, simply ./startproxy.sh.     
After using the proxy, you can ./stopproxy.sh for totally release the connection and release the resources.   
