---
layout: post
title: "My Translator In ArchLinux(3)"
date: 2014-07-07 14:15
comments: true
categories: 
---
Using radis for cache the dictionary.     

```
    # In C, it's simple to use do...while(), but in python, we need to judge the input, 
    # Fortunately, the input is very simple, because get infos from RedisQue is blocking.
    # Forever Listening...
    while True:
        # Key in RedisQueue is 'dic', and we simply get its content:
        q = RedisQueue('dic')
        # cmdargs = q.get()
        # cmdargs = str(sys.argv) ## args
        to_be_refer_word = q.get()
        try:
            result = my_dict_reader.get_dict_by_word(str(to_be_refer_word))  ## Using args[1] for querying
            print result[0].values()[0]		## output result in terminal
            result_str = "\'<span color=\"green\" size=\"14000\">"+result[0].values()[0]+"</span>\'"	## Build the command line for notify-send
            call(["notify-send", to_be_refer_word, result_str])		## Call notify-send to print on screen, last for 5 seconds
        except Exception, e:
            print "Not Find!"

```

Then we write the query file named `refer.py`:    

```
#!/usr/bin/python2
# -*- coding: utf-8 -*-
# For using RedisQueue to fetch the refer words 
import sys
from RedisQueue import RedisQueue

q = RedisQueue('dic')
q.put(str(sys.argv[1]))


```

Add the following lines as `/usr/bin/mydic`:   

```
# Using redis
python2 /home/Trusty/code/python/mypython/stardict/refer.py $@


```
This will greatly improve the refer time, you could get the real-time result via `mydic New_Words`
