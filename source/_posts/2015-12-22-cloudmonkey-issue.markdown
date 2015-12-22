---
layout: post
title: "CloudMonkey Issue"
date: 2015-12-22 21:18:21 +0800
comments: true
categories: virtualization
---
### Could not start cloudmonkey

After installing cloudstack, cloudmonkey couldnot be used, the reason is
listed as following:     

```
% cloudmonkey
Traceback (most recent call last):
  File "/usr/local/bin/cloudmonkey", line 5, in <module>
    from pkg_resources import load_entry_point
  File "/System/Library/Frameworks/Python.framework/Versions/2.7/Extras/lib/python/pkg_resources.py", line 2603, in <module>
    working_set.require(__requires__)
  File "/System/Library/Frameworks/Python.framework/Versions/2.7/Extras/lib/python/pkg_resources.py", line 666, in require
    needed = self.resolve(parse_requirements(requirements))
  File "/System/Library/Frameworks/Python.framework/Versions/2.7/Extras/lib/python/pkg_resources.py", line 565, in resolve
    raise DistributionNotFound(req)  # XXX put more info here
pkg_resources.DistributionNotFound: requests
```

The solution is via:    

```
# easy_install --upgrade pip
# pip install --upgrade setuptools
# pip install --upgrade distribute
# wget https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py -O - | python
```

So Now you could use cloudstack.    

### Use Ansible Together With Cloudmonkey

I think because my cloudstack agent didn't use a bridge, so the cloudmonkey runs failed.   
