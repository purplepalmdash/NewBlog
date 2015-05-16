---
layout: post
title: "Python call system command"
date: 2014-10-24 09:49
comments: true
categories: python
---
### Use Popen for running ls
We could use following python scripts for running the bash command `ls -l`:    

```
>>> from subprocess import *
>>> from subprocess import call
>>> from subprocess import Popen
>>> import subprocess
>>> ls_child = Popen(['ls', '-l'], stdout=subprocess.PIPE, stderr = subprocess.PIPE)
>>> ls_result = ls_child.communicate()
>>> print ls_result
.......

```
The command I want to call is:    

```
sed -n 1~2p File_Name

```
This command will get the half of the file contents.    


### Popen Wrapping
The commands for canling sed is:    

```
>>> sed_child = Popen(['sed', '-n', '1~2p', '/home/Trusty/code/mybash/rtp02_2014_10_23_03_23_36.txt'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
>>> sed_content = sed_child.communicate()

```
Judge the parameters:    

```
>>> command_line=raw_input()
 sed -n 1~2p /home/Trusty/code/mybash/rtp02_2014_10_23_03_23_36.txt 
>>> args=shlex.split(command_line)
>>> print args

```

Write the result into the file(half size as the origin input file), notice we remove the first 16 characters:    

```
>>> f_half = open("./half_result.txt", "w+")
>>> for line in sed_content:
>>>     f_half.write(line.replace(line[:16],''))
>>> f_half.close()

```
Then the file contains all of the content.    

If we want to write into sorted result, then do following:    

```
>>> lines=[]
>>> for line in sed_content:
>>>     lines.append(line.replace(line[:16], ''))
>>> lines.sort()
>>> f_half = open("./half_result.txt", "w+")
>>> for line in lines:
>>>     f_half.write(line)
>>> f_half.close()

```

### Remote Acticom machine script

