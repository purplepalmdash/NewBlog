---
layout: post
title: "Add Ubuntu Agent into SpaceWalk"
date: 2015-08-10 14:53:28 +0800
comments: true
categories: virtualization
---
Install via:   

```
$ sudo apt-get install debhelper build-essential gcc devscripts git intltool quilt \
automake python-all-dev libnl-route-3-dev asciidoc pkg-config libxml2-utils \
docbook-xml xsltproc sgml-data docbook-xs
$ sudo apt-get install apt-transport-spacewalk rhnsd
```

Fix the bug of XMLRPCLib:    

```
--- /usr/lib/python2.7/xmlrpclib.py 2013-05-28 20:44:38.000000000 +0200
+++ new/xmlrpclib.py 2013-05-28 20:44:24.000000000 +0200
@@ -654,8 +654,8 @@
f(self, value, write)

def dump_nil (self, value, write):
- if not self.allow_none:
- raise TypeError, "cannot marshal None unless allow_none is enabled"
+# if not self.allow_none:
+# raise TypeError, "cannot marshal None unless allow_none is enabled"
write("<value><nil/></value>")
dispatch[NoneType] = dump_nil
```

Create a key for managing trusty clients:    
![/images/2015_08_10_15_18_26_629x476.jpg](/images/2015_08_10_15_18_26_629x476.jpg)     

Register with SpaceWalk Server:    

```
$ sudo mkdir /var/lock/subsys
$ sudo rhnreg_ks --activationkey=1-TrustyKey --serverUrl=http://10.9.10.13/XMLRPC
Warning: unable to enable rhnsd with chkconfig
```
Seeing the warning doesn't matter. Now your computer is registered into the SpaceWalker
Root Node.   

Make sure the subscribed software are listed as following:    

![/images/2015_08_10_16_00_26_795x557.jpg](/images/2015_08_10_16_00_26_795x557.jpg)        

Now change the apt configuration of the registed nodes:    

```
# echo 'deb spacewalk://10.9.10.13/XMLRPC channels: trusty-main trusty-updates trusty-backports trusty-security'> /etc/apt/sources.list.d/spacewalk.list
# mv /etc/apt/sources.list /etc/apt/sources.list.bak
# apt-get update
```
After updating, the repo will be refresed as:     

```
# cat /etc/apt/sources.list.d/spacewalk.list 
deb spacewalk://10.9.10.13 channels: main trusty-backports trusty-updates trusty-security
```


Seems something error happened, syncing the repository, tomorrow will use precise for
verification.    


### Use Precise
Manually build the package and install the generated packages.    

```
# apt-get install debhelper build-essential gcc devscripts git intltool quilt automake  python-all-dev libnl-route-3-dev asciidoc pkg-config libxml2-utils docbook-xml xsltproc  sgml-data docbook-xsl
# apt-get -f install

# git clone git://anonscm.debian.org/collab-maint/spacewalk/rhnlib.git
# git clone git://anonscm.debian.org/collab-maint/spacewalk/rhn-client-tools.git  rhn-client-tools
# git clone git://anonscm.debian.org/collab-maint/spacewalk/python-ethtool.git  python-ethtool
# git clone git://anonscm.debian.org/collab-maint/spacewalk/rhnsd.git rhnsd
# git clone git://anonscm.debian.org/collab-maint/spacewalk/apt-spacewalk.git

# debuild -i -us -uc -b
# dpkg -i *.deb
# apt-get -f install
```
Change the code for bug-fix:     

```
--- /usr/lib/python2.7/xmlrpclib.py 2013-05-28 20:44:38.000000000 +0200
+++ new/xmlrpclib.py 2013-05-28 20:44:24.000000000 +0200
@@ -654,8 +654,8 @@
f(self, value, write)

def dump_nil (self, value, write):
- if not self.allow_none:
- raise TypeError, "cannot marshal None unless allow_none is enabled"
+# if not self.allow_none:
+# raise TypeError, "cannot marshal None unless allow_none is enabled"
write("<value><nil/></value>")
dispatch[NoneType] = dump_nil
```

Register to Server:    

```
# apt-get install python-libxml2
# mkdir /var/lock/subsys
# rhnreg_ks --activationkey=1-precise --serverUrl=http://10.9.10.13/XMLRPC
```
Use Spacewalk for install the packages:    

```
# cat /etc/apt/sources.list.d/spacewalk.list 
deb spacewalk://10.9.10.13 channels: main precise-backports precise-updates precise-security
# mv /etc/apt/sources.list /etc/apt/sources.list.back
# apt-get update
```

Now your repositories are managed by SpaceWalk.    

