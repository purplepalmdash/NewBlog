---
layout: post
title: "Auto Configure SpaceWalk Ubuntu Agent"
date: 2015-08-17 17:21:31 +0800
comments: true
categories: Spacewalk
---
### Create the Auto-Deployment Material
Directory structure is listed as following:   

```
adminubuntu@bee3:~/Code$ ls -F
deb/  deb_osad/  deb_remote/  first.sh*  second.sh*  sources.list  xmlrpclib.py
adminubuntu@bee3:~/Code$ ls *
autoChange.sh  autoChange.sh~  hostname  sources.list  xmlrpclib.py

deb:
apt-transport-spacewalk_1.0.6-4.1_all.deb  python-rhn_2.5.55-2_all.deb         rhnsd_5.0.4-3_i386.deb
python-ethtool_0.11-2_i386.deb             rhn-client-tools_1.8.26-4_i386.deb

deb_osad:
osad_5.11.27-1ubuntu1~precise5_all.deb  pyjabber_0.5.0-1.4ubuntu3~precise1_all.deb

deb_remote:
rhncfg_5.10.14-1ubuntu1~precise2_all.deb
```
The deb files in deb should be compiled manually:    

```
apt-get install debhelper build-essential gcc devscripts git intltool quilt automake python-all-dev libnl-route-3-dev asciidoc pkg-config libxml2-utils docbook-xml xsltproc sgml-data docbook-xsl
apt-get -f install

git clone git://anonscm.debian.org/collab-maint/spacewalk/rhnlib.git
git clone git://anonscm.debian.org/collab-maint/spacewalk/rhn-client-tools.git rhn-client-tools
git clone git://anonscm.debian.org/collab-maint/spacewalk/python-ethtool.git python-ethtool
git clone git://anonscm.debian.org/collab-maint/spacewalk/rhnsd.git rhnsd
git clone git://anonscm.debian.org/collab-maint/spacewalk/apt-spacewalk.git

# now in every of these directories do:
debuild -i -us -uc -b
```


### Automatically Registration
The first.sh listed as following:    

```
#!/bin/sh
### 1. TODO.
# You must be root, so input the root priviledge check here. 

### 2. Check Parameter to make sure you have inputs. 
if [ $# != 1 ]
then
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo "!!         Parameters error       !!"
  echo "!! Example: ./createvm.sh name    !!"
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  exit 1
fi

### 3. Change the hostname of the system
#echo $1
echo $1>/etc/hostname

### 4. Modify the hostname listed in /etc/hosts.
# The default name is always "packer-ubuntu-1204-server-i386", use sed for replacing it.
sed -i "s/packer-ubuntu-1204-server-i386/$1/g" /etc/hosts
echo "10.11.11.3 spacewalk">>/etc/hosts
reboot
```

The second.sh listed as following:    

```
### 5. Change the Repository, and install the packages. 
cp ./sources.list /etc/apt/
apt-get update
cd deb/
dpkg -i *.deb
apt-get -f install
cd ../

### 6. Apply the bug-fix for osad. 
cp ./xmlrpclib.py /usr/lib/python2.7/xmlrpclib.py

### 7. Registration of the system. 
mkdir /var/lock/subsys
apt-get install python-libxml2
rhnreg_ks --activationkey=1-precise-ia32 --serverUrl=http://spacewalk/XMLRPC

### 8. Update Repository for using SpaceWalk. 
echo 'deb spacewalk://spacewalk/XMLRPC channels: precise-main precise-updates' > /etc/apt/sources.list.d/spacewalk.list
mv /etc/apt/sources.list /etc/apt/sources.list.back
apt-get update && apt-get update

### 9. Enable "push" to registed client. 
# wget https://launchpad.net/~mj-casalogic/+archive/ubuntu/spacewalk-ubuntu/+files/pyjabber_0.5.0-1.4ubuntu3~precise1_all.deb
# wget https://launchpad.net/~mj-casalogic/+archive/ubuntu/spacewalk-ubuntu/+files/osad_5.11.27-1ubuntu1~precise5_all.deb
cd deb_osad/
dpkg -i *.deb
cd /usr/share/rhn
wget http://spacewalk/pub/RHN-ORG-TRUSTED-SSL-CERT
service osad start
update-rc.d osad defaults


### 10. Enable Remote Command
cd /home/adminubuntu/Code/deb_remote/
dpkg -i *.deb
# this is important and touches the file /etc/sysconfig/rhn/allowed-actions/script/run
rhn-actions-control --enable-all
# Now create the missing directory, the command script gets placed there temporarily
mkdir /var/spool/rhn/


### 99. Finally , reboot the system.
```
Run the scripts then you could easily got system registed into the spacewalk server.   
