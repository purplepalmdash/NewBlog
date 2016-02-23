---
layout: post
title: "Playing e-Buddy"
date: 2016-02-23 09:36:58 +0800
comments: true
categories: Embedded
---
### Python Library
Clone the repository from google Code to github, then clone it to local:    
This library could makes the ebuddy dance and sing.   

```
$ git clone git@github.com:purplepalmdash/pybuddy-dx.git
```

### Environment
Since ArchLinux runs python3, we need to create a virtualenv for running python2.7    

```
$ virtualenv2 venv2 --python=python2.7
 ✗ . ~/venv2/bin/activate
(venv2) ➜  _posts git:(master) ✗ python
Python 2.7.11 (default, Dec  6 2015, 15:43:46) 
[GCC 5.2.0] on linux2
$ pip install pyusb
```

### Modification
Modify the source code, mainly change the following lines:    

```
    #except NoBuddyException, e:
    except NoBuddyException:
```

Start the ebuddy via:    

```
$ python pybuddyDX1.py
2016-02-23 15:51:39,242 INFO     Searching e-buddy...
2016-02-23 15:51:39,399 INFO     DX e-buddy found!
2016-02-23 15:51:39,962 INFO     Starting daemon...
```

Let buddy runs via:    

```
# echo 03 | nc -q0 -u 127.0.0.1 8888
# echo 04 | nc -q0 -u 127.0.0.1 8888
.....
```

