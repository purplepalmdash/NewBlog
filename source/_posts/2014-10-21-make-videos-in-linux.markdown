---
layout: post
title: "Make Videos in Linux"
date: 2014-10-21 16:03
comments: true
categories: Linux
---
### Capture Window
Sometimes we want to record the window operation, we could use `gtk-recordMyDesktop` for doing this. 
Open the gtk-recordMyDesktop then select the window, start and it will automatically capture all of your input, and save it to ogg file.    
### Add Background Music
use Mencoder to add a mp3 file as the background of the captured video:    

```
$ mencoder output.ogv -o video_final.ogv -ovc copy -oac copy -audiofile xxx.mp3

```
### Convert Video Formats
Using mencoder for convert the ogv to mp4 file:    

```
$ ffmpeg -i output.ogv -vcodec libx264 -strict -2  output.mp4 

```
### 7z for split
Install 7zip, and use following command for split the big file into several 10M-size small files:    

```
$ 7z a -v10M output.7z output.mp4

```

