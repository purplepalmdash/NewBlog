---
layout: post
title: "rip mp3 under ArchLinux"
date: 2014-02-25 19:06
comments: true
categories: Linux
---
First you have to install sound-juicer, by:

```
	sudo pacman -S sound-juicer

```
Run "sound-juicer" will call the sound-juicer out, remember the pulse-audio should be started before the sound-juicer is called.    

On start, sound juicer will automatically scan the CD-ROM, and retrieve back the track listing, this will take for a while.  Sorry, failed. ...    

goobox is only a CD Player    

grip is good, just use it for cd mp3 gripping.     


After gripping the sound-track, the generated mp3 file is listed under the directory that your specified, with a m3u file and the mp3 fils. Here comes a new problem, how to rename from the m3u file?     
Following is the bash script for doing this:

```sh - autorename.sh
#!/bin/bash
number=0
# Make the directory for processed result
mkdir -p ./changed
underscore="_"
for filename in `cat ./verschiedene_knstler-piano_piano.m3u`
do
	number=`expr $number + 1`
	# How to get the filename? 
	file_basename=`basename $filename`
	#echo $file_basename
	if [ $number -lt 10 ]
	then
		# Add 0 before the number,
		# and form the name like "01_abc"
		zeroprefixname="0$number$underscore$file_basename"
		echo $zeroprefixname
		cp $filename ./changed/$zeroprefixname
	else
		# The name needn't add 0
		prefixname=$number$underscore$file_basename
		echo $prefixname
		cp $filename ./changed/$prefixname
	fi
done

```

