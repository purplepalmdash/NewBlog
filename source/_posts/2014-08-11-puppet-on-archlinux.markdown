---
layout: post
title: "Puppet On ArchLinux"
date: 2014-08-11 17:22
comments: true
categories: puppet
---
### Installation
Install via;   

```
sudo pacman -S puppet

```
Configurate this machine into server mode. 

### Install new Virtual Machine
Install a new ubuntu14.04 using qemu, and install puppet in it.     
Generate the configuration file for mirror.list of Ubuntu.    

Finally use the vdi file in the Ubuntu.    

Install puppet in Ubuntu14.04:    
[http://linuxconfig.org/puppet-installation-on-linux-ubuntu-14-04-trusty-tahr](http://linuxconfig.org/puppet-installation-on-linux-ubuntu-14-04-trusty-tahr)    

Make Ubuntu use a fixed IP.     

```
$ cat  /etc/network/interface
# s file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback
auto eth0
	iface eth0 inet static
	address 10.0.0.88
	netmask 255.255.255.0
	gateway 10.0.0.1

```

And Copy the virtual disk, and change the UUID of the disk:    

```
$ VBoxManage internalcommands sethduuid ./Ubuntu.vdi 
UUID changed to: d1xxxxxxxxxxxxxxxxxxxxxxxxxx

```
Be sure to change the ip address to 10.0.0.89.  

Now we have 2 machines.    

No password enter for ssh login:    

```
$ cat ~/.ssh/id_rsa.pub| ssh Trusty@10.0.0.88 'cat>>~/.ssh/authorized_keys'
$ cat ~/.ssh/id_rsa.pub| ssh Trusty@10.0.0.89 'cat>>~/.ssh/authorized_keys'

```
### Server and Client
Install Server side in 10.0.0.88:    

```
sudo apt-get install puppetmaster

```

In 10.0.0.88, edit /etc/hosts:    

```
10.0.0.89	client

```
While in 10.0.0.89, edit /etc/hosts:     

```
10.0.0.88	puppet

```
In client(10.0.0.89), start the service of puppet:    

```
$ sudo service puppet start
 * Starting puppet agent                                                                                
puppet not configured to start, please edit /etc/default/puppet to enable
                                                                                                 [ OK ]

```
In server(10.0.0.88), start the service of puppet master:    
Add following lines in to /etc/puppet/puppet.conf:    

```
dns_alt_names = puppet, master.local, puppet.terokarvinen.com

```
Then remove all of the generated ssl :    

```
rm -rf /var/lib/puppet/ssl

```
Now restart the puppetmaster via:   

```
# service puppetmaster restart 

```

Change the hostname of 10.0.0.88 to Ubuntu88, 10.0.0.89 to Ubuntu89, and then restart the computer.    
Now change the Ubuntu88's configuration
Add following lines in 10.0.0.88(Server): 
In /etc/puppet/puppet.conf, [master] heading:    

```
dns_alt_names = puppet, master.local, puppet.terokarvinen.com

```

On 10.0.0.89(Client), change the following line in /etc/default/puppet:   

```
START=yes

```
Then in /etc/puppet/puppet.conf,  add following:    

```
[agent]
server = puppet

```
Restart the puppet service. 

Now on server, use following command to list the cert and add signed cert.    

```
Trusty@Ubuntu88:~$ sudo puppet cert --list
sudo: unable to resolve host Ubuntu88
Warning: Setting templatedir is deprecated. See http://links.puppetlabs.com/env-settings-deprecations
   (at /usr/lib/ruby/vendor_ruby/puppet/settings.rb:1095:in `block in issue_deprecations')
  "ubuntu89" (SHA256) xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Trusty@Ubuntu88:~$ sudo puppet cert --sign ubuntu89
sudo: unable to resolve host Ubuntu88
Warning: Setting templatedir is deprecated. See http://links.puppetlabs.com/env-settings-deprecations
   (at /usr/lib/ruby/vendor_ruby/puppet/settings.rb:1095:in `block in issue_deprecations')
Notice: Signed certificate request for ubuntu89
Notice: Removing file Puppet::SSL::CertificateRequest ubuntu89 at '/var/lib/puppet/ssl/ca/requests/ubuntu89.pem'

```
### Create the Site Manifest and a Module
Go to /etc/puppet, run following command:    

```
Trusty@Ubuntu88:/etc/puppet$ sudo mkdir -p manifests/ modules/helloworld/manifests

```
Edit following file:   

```
Trusty@Ubuntu88:/etc/puppet$ cat manifests/site.pp 
include helloworld

```
Create the file:   

```
Trusty@Ubuntu88:/etc/puppet$ sudo cat modules/helloworld/manifests/init.pp
class helloworld {
        file { '/tmp/helloFromMaster':
                content => "See you at http://terokarvinen.com/tag/puppet\n"
        }
}

```

And Now in client, restart the puppet service:    

```
Trusty@Ubuntu89:~$ sudo service puppet restart
sudo: unable to resolve host Ubuntu89
[sudo] password for Trusty: 
no talloc stackframe at ../source3/param/loadparm.c:4864, leaking memory
 * Restarting puppet agent                                               [ OK ] 
Trusty@Ubuntu89:~$ cat /tmp/helloFromMaster 
See you at http://terokarvinen.com/tag/puppet

```

Now the basic configuration is OK. 
