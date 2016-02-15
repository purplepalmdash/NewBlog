---
layout: post
title: "Hacking SteelSeries Engine 3 USB Mouse Under Linux(2)"
date: 2016-02-15 18:11:54 +0800
comments: true
categories: DeviceDriver
---
### Interact with Mouse

Just some tips on newly-discovered items.    

The needed python modules should be get and compiled as following:     
[https://github.com/andrepl/rivalctl](https://github.com/andrepl/rivalctl)    

```
# git clone https://github.com/andrepl/rivalctl.git
# sudo python setup.py install
```

Be sure to make changes to the correct HID ID.    

Ipython scripts:   

```
# sudo ipython
Python 2.7.6 (default, Jun 22 2015, 17:58:13) 
Type "copyright", "credits" or "license" for more information.

IPython 1.2.1 -- An enhanced Interactive Python.
?         -> Introduction and overview of IPython's features.
%quickref -> Quick reference.
help      -> Python's own help system.
object?   -> Details about 'object', use 'object??' for extra details.

In [1]: RIVAL_HID_ID = '0003:00001038:00001386'

In [2]: cd /usr/local/lib/python2.7/dist-packages/rivalctl-0.1-py2.7.egg/rival/
/usr/local/lib/python2.7/dist-packages/rivalctl-0.1-py2.7.egg/rival

In [3]: import hidrawpure as hidraw

In [4]: import os

In [5]: 

In [5]: import yaml

In [6]: import pyudev

In [7]: import webcolors

In [8]: def find_device_path():
   ...:         """find the appropriate /dev/hidrawX device to control the mouse"""
   ...:         ctx = pyudev.Context()
   ...:         for dev in ctx.list_devices(HID_ID=RIVAL_HID_ID):
   ...:                 if dev.sequence_number == 0:
   ...:                         children = list(dev.children)
   ...:                         if children:
   ...:                                 child = children[0]
   ...:                                 if child.subsystem == 'hidraw':
   ...:                                         return child['DEVNAME']
   ...:                 

In [9]: dev_path = find_device_path()

In [10]: opened_device=hidraw.HIDRaw(open(dev_path, 'w+'))

In [11]: opened_device.getName()
*************In ioctl functionality!
<open file u'/dev/hidraw5', mode 'w+' at 0x7f0a00088150>
2181056516
<type 'int'>
<ctypes.c_char_Array_512 object at 0x7f0a00088560>
True
After ioctl functionality!
@@@@@@@@@@@@@@@@@@@@@@
2181056516
@@@@@@@@@@@@@@@@@@@@@@
Out[11]: u'SteelSeries The Sims 4 Gaming Mouse'
```

Whole source file:    

```
RIVAL_HID_ID = '0003:00001038:00001386'
cd /usr/local/lib/python2.7/dist-packages/rivalctl-0.1-py2.7.egg/rival/
import hidrawpure as hidraw
import os
import yaml
import pyudev
import webcolors

def find_device_path():
    """find the appropriate /dev/hidrawX device to control the mouse"""
    ctx = pyudev.Context()
    for dev in ctx.list_devices(HID_ID=RIVAL_HID_ID):
        if dev.sequence_number == 0:
            children = list(dev.children)
            if children:
                child = children[0]
                if child.subsystem == 'hidraw':
                    return child['DEVNAME']

dev_path = find_device_path()
opened_device=hidraw.HIDRaw(open(dev_path, 'w+'))
opened_device.getName()
```

### To Be Continue
To be investigated soon, the issue is I could not change the settings.    
