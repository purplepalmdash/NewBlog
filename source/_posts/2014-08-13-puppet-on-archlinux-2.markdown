---
layout: post
title: "Puppet on ArchLinux(2)"
date: 2014-08-13 16:24
comments: true
categories: puppet
---
### Add Arch 
step1, add the hosts into /etc/hosts:   

```
# Puppet 
10.0.0.88	puppet
10.0.0.89	client

```
step2, edit the /etc/puppet/puppet.conf:     

```
[agent]
    # add server
    [agent]
    server = puppet

```
Restart the puppet.service:   

```
systemctl restart puppet.service
systemctl enable puppet.service

```
step3, in 10.0.0.88(server), add the ssl certification of archlinux:    

```
root@Ubuntu88:/home/Trusty# !44
puppet cert --list
Warning: Setting templatedir is deprecated. See http://links.puppetlabs.com/env-settings-deprecations
   (at /usr/lib/ruby/vendor_ruby/puppet/settings.rb:1095:in `block in issue_deprecations')
  "XXXyyy.lan" (SHA256) 8XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
root@Ubuntu88:/home/Trusty# puppet cert --sign XXXyyy.lan
Warning: Setting templatedir is deprecated. See http://links.puppetlabs.com/env-settings-deprecations
   (at /usr/lib/ruby/vendor_ruby/puppet/settings.rb:1095:in `block in issue_deprecations')
Notice: Signed certificate request for XXXyyy.lan
Notice: Removing file Puppet::SSL::CertificateRequest XXXyyy.lan at '/var/lib/puppet/ssl/ca/requests/XXXyyy.lan.pem'

```
Now check the /tmp, we will see our test file in last chapter.    

For test pupose, we will disable archLinux's puppet via:    

```
[root@TrustyArch tmp]# systemctl stop puppet.service
[root@TrustyArch tmp]# systemctl disable puppet.service
Removed symlink /etc/systemd/system/multi-user.target.wants/puppet.service.

```

### Install package
Add following lines into 10.0.0.88, /etc/puppet/manifests/site.pp:    

```
package {
    'xplot':
        ensure => installed
}

```
Then restart the puppetmaster, in 10.0.0.89, the package xplot will be installed.    
