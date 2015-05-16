---
layout: post
title: "Quickly play puppet"
date: 2015-04-16 16:09
comments: true
categories: puppet
---
### Server and Client
In server, install following packages:    

```
$ sudo apt-get install puppet puppetmaster

```
In client, only install puppet is enough.     
After installation, added the each other's name into `/etc/hosts`, let them ping each other via name rather than via ip address.    
### Sign
In client, do following:     

```
$ clouder@pc121:/etc/puppet$ puppet agent --test --server=pc119
Exiting; no certificate found and waitforcert is disabled

```
Then in server, listed all of the certification request:    

```
root@pc119:~/Code/herokublog# sudo puppet cert list
  "pc121" (SHA256) 28:23:36:3C:E4:8B:3A:15:D2:B0:8C:A2:BC:E9:A1:E5:6A:6F:76:0E:40:73:29:1F:8F:8C:D4:83:1F:92:4F:C7

```
sign the cert:    

```
root@pc119:~/Code/herokublog# sudo puppet cert sign pc121
Notice: Signed certificate request for pc121
Notice: Removing file Puppet::SSL::CertificateRequest pc121 at '/var/lib/puppet/ssl/ca/requests/pc121.pem'

```
Verify it in the client:    

```
clouder@pc121:/etc/puppet$ puppet agent --test
Warning: Unable to fetch my node definition, but the agent run will continue:
Warning: getaddrinfo: Name or service not known
Info: Retrieving plugin
Error: /File[/home/clouder/.puppet/var/lib]: Failed to generate additional resources using 'eval_generate': getaddrinfo: Name or service not known

```
### Configuration
TBD
