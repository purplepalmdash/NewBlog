---
layout: post
title: "Automatically Filter SpamBot on DigitalOcean"
date: 2014-11-06 15:41
comments: true
categories: linux
---
### Setup iptables
Install iptables-persistent, so that the iptables rules will be saved even reboot the machine:    

```
# apt-get update
# apt-get install iptables-persistent

```
### Script for manually add iptables
Use following scritp for manually add iptables items:     

``` sh
#!/bin/sh
# This script runs once per hour, Directly remove the ips which post comments
# more than 4 times per hour. And who comments less than 3 times we should sent
# its ip to old ips file. The old ips files will be used for analyse once per day
# The run frequency is controlled by  crontab.   

######################################################
# Before Start, empty the deathSentence
######################################################
>/var/log/apache2/deathSentence

######################################################
# First cat the file and try to found the bot ip list
######################################################
# Pipe 1: The one who called POST method should be monitored
# Pipe 2: Get the ip address who called POST method.
# Pipe 3: Sort the ip addresses. 
# Pipe 4: Calculate the repeated times. First column, times; Second column, ip address.
# Pipe 5: Sort via first column(times) numerically(Not textly!) .
# Pipe 6: If the Call POST time bigger than 4 in one hour, catch it!
# Pipe 7: Yes we caught this thief! Get its ipaddr.
# Write these thieves into the death sentence
cat /var/log/apache2/other_vhosts_access.log | grep "POST" | awk '{print $2}' | sort | uniq --count | sort -n | awk '$1>4' | awk {'print $2'}>/var/log/apache2/deathSentence
# Those who comments but equal or more than 4 times will be append to wishList
cat /var/log/apache2/other_vhosts_access.log | grep "POST" | awk '{print $2}' | sort | uniq --count | sort -n | awk '$1<5' | awk {'print $2'}>>/var/log/apache2/wishList

######################################################
# Second we add this bot ip list into the netfilter
######################################################
for i in `cat /var/log/apache2/deathSentence`
do
	#echo $i
	iptables -A INPUT -s $i -j DROP
done

######################################################
# Finally empty the other_vhosts_access.log
######################################################
>/var/log/apache2/other_vhosts_access.log

```
Oh, also add myself into the blacklist, so un-lock me:    

```
$ iptables -A INPUT -s 1xx.x.x.x -j ACCEPT

```

Since those wishList should also be cared, wrote following scripts for judge, every 4 hours will be make a decision.     

```sh 
#!/bin/sh
# This script runs once 4 hours, used for processing the /var/log/apache2/wishList
# ip address lists. Those bad guys who were in wishList, if their total appear times
# bigger than 4 times, will be added to iptable's drop rules.
>/var/log/apache2/deathSentence_4hour

######################################################
# Read the ip list and store those bad guys into deathSentence_4hour
######################################################
cat /var/log/apache2/wishList | sort | uniq --count | sort -n | awk '$1>4' | awk {'$print $2'}>/var/log/apache2/deathSentence_4hour

######################################################
# Now you got the bad guys, add them into iptables
######################################################
for i in `cat /var/log/apache2/deathSentence_4hour`
do
        #echo $i
        iptables -A INPUT -s $i -j DROP
done

######################################################
# Finally empty the wishList
######################################################
>/var/log/apache2/wishList

```
### Crontab It!
Run `auto_add_bot_ip.sh` at every minute 0 of 1 hour, then run `auto_judge_wishlist.sh` at every minute 10 of every 4 hours.    

```
# m h  dom mon dow   command
0 */1 * * * /root/code/auto_add_bot_ip.sh
10 */4 * * * /root/code/auto_judge_wishlist.sh

```
