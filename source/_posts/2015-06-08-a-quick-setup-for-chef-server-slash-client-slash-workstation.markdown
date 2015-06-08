---
layout: post
title: "A Quick Setup For Chef Server/Client/Workstation"
date: 2015-06-08 20:39:17 +0800
comments: true
categories: Chef
---
### Machine Preparation
QuickServer: 172.16.0.11, QuickClient: 172.16.0.12        

QuickServer Machine:    

```
xxx@QuickServer:~$ cat /etc/hostname
QuickServer
xxx@QuickServer:~$ cat /etc/hosts
127.0.0.1       localhost
127.0.1.1       QuickServer
172.16.0.11     QuickServer
172.16.0.12     QuickClient

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
xxx@QuickServer:~$ cat /etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet static
address 172.16.0.11
netmask 255.255.255.0
gateway 172.16.0.1
dns-nameservers 114.114.114.114

```

QuickClient Machine:    

```
xxx@QuickClient:~$ cat /etc/hosts
127.0.0.1       localhost
127.0.1.1       QuickClient
172.16.0.12     QuickClient
172.16.0.11     QuickServer


# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
xxx@QuickClient:~$ cat /etc/hostname 
QuickClient
xxx@QuickClient:~$ cat /etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet static
address 172.16.0.12
netmask 255.255.255.0
gateway 172.16.0.1
dns-nameservers 114.114.114.114
```

### QuickServer Installation
You should have following packges in this server/management node:   

```
$ ls
chefdk_0.6.0-1_amd64.deb  chef-server-core_12.0.8-1_amd64.deb  opscode-manage_1.13.0-1_amd64.deb
```

Install and configuration:    

```
$ sudo dpkg -i chef-server-core_12.0.8-1_amd64.deb
$ sudo chef-server-ctl reconfigure
```

Now configure the chefserver via following command:    

```
$ sudo chef-server-ctl user-create twocloud cloud Yang twocloud@gmail.com engine --filename ~/twocloud.pem
$ sudo chef-server-ctl org-create twocloud OneCloud Software, Inc. --association_user twocloud --filename ~/twocloud_org.pem
$ ls ~/*.pem
/home/xxxx/twocloud_org.pem  /home/xxxx/twocloud.pem
```

Install opscode:    

```
$ sudo dpkg -i opscode-manage_1.13.0-1_amd64.deb
$ sudo opscode-manage-ctl reconfigure
```
Also install the chefdk via:    

```
$ sudo dpkg -i chefdk_0.6.0-1_amd64.deb
```

Install the git and configure the chef-repo:    

```
$ sudo apt-get install git
$ git config --global user.name "purplepalm"
$ git config --global user.email "purplepalm@gmail.com"
$ git clone https://github.com/opscode/chef-repo.git
$ mkdir .chef
$ cd .chef/
$ scp xxxx@127.0.0.1:/home/xxxx/*.pem ./
```

Now under the .chef directory, create the knife.rb for letting knife using:    

```
$ cat ~/chef-repo/.chef/knife.rb
current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "twocloud"
client_key               "#{current_dir}/twocloud.pem"
validation_client_name   "twocloud"
validation_key           "#{current_dir}/twocloud_org.pem"
chef_server_url          "https://QuickServer/organizations/twocloud"
syntax_check_cache_path  "#{ENV['HOME']}/.chef/syntaxcache"
cookbook_path            ["#{current_dir}/../cookbooks"]
```

Verify ssl via:    

```
$ knife ssl fetch
WARNING: Certificates from QuickServer will be fetched and placed in your trusted_cert
directory (/home/xxxx/chef-repo/.chef/trusted_certs).

Knife has no means to verify these are the correct certificates. You should
verify the authenticity of these certificates after downloading.

Adding certificate for QuickServer in /home/xxxx/chef-repo/.chef/trusted_certs/QuickServer.crt

$ knife ssl check
Connecting to host QuickServer:443
Successfully verified certificates from `QuickServer'
$ knife client list
twocloud-validator

```

Next, configure the QuickClient and add it to the Chef.     

### QuickClient
Install the client deb file via:    

```
$ ls
chef_12.3.0-1_amd64.deb
$ sudo dpkg -i chef_12.3.0-1_amd64.deb 
```

Now,On !!! QuickServer !!! , bootstrap the QuickClient via:    

```
$ cd ~/chef-repo/
$ knife bootstrap 172.16.0.12 -x xxxx -P xxxxxxxx --sudo
Doing old-style registration with the validation key at /home/xxxx/chef-repo/.chef/twocloud_org.pem...
Delete your validation key in order to use your user credentials instead

Connecting to 172.16.0.12
172.16.0.12 Starting first Chef Client run...
172.16.0.12 Starting Chef Client, version 12.3.0
172.16.0.12 Creating a new client identity for QuickClient using the validator key.
172.16.0.12 
172.16.0.12 ================================================================================
172.16.0.12 Chef encountered an error attempting to create the client "QuickClient"
172.16.0.12 ================================================================================

```

Yes, you will meet an error, Now go back to !!! QuickClient !!! and solve it.     

First retrieve the pem file under your own home directory:     

```
$ scp xxxx@172.16.0.11:/home/xxxx/*.pem ./
Password: 
twocloud_org.pem                                                                                             100% 1674     1.6KB/s   00:00 
twocloud.pem                                                                                                 100% 1674     1.6KB/s   00:00
```
Then fetch back the ssl via:     

```
$ sudo knife ssl fetch --config /etc/chef/client.rb
WARNING: Certificates from QuickServer will be fetched and placed in your trusted_cert
directory (/etc/chef/trusted_certs).

Knife has no means to verify these are the correct certificates. You should
verify the authenticity of these certificates after downloading.

Adding certificate for QuickServer in /etc/chef/trusted_certs/QuickServer.crt
```

Now manually use the `/home/xxxx/twocloud.pem` for ssl checking.    

```
$ sudo chef-client -l debug -S https://QuickServer/organizations/twocloud -K /home/xxxx/twocloud.pem 2>&1
```

Your terminal may encounter Garbled codes, simply quit it, and go back to !!! QuickServer !!!, Bootstrap again via:    

```
$ knife bootstrap 172.16.0.12 -x xxxx -P xxxxxxxx --sudo
Doing old-style registration with the validation key at /home/xxxx/chef-repo/.chef/twocloud_org.pem...
Delete your validation key in order to use your user credentials instead

Connecting to 172.16.0.12
172.16.0.12 Starting first Chef Client run...
172.16.0.12 Starting Chef Client, version 12.3.0
172.16.0.12 resolving cookbooks for run list: []
172.16.0.12 Synchronizing Cookbooks:
172.16.0.12 Compiling Cookbooks...
172.16.0.12 [2015-06-08T09:12:09-04:00] WARN: Node QuickClient has an empty run list.
172.16.0.12 Converging 0 resources
172.16.0.12 
172.16.0.12 Running handlers:
172.16.0.12 Running handlers complete
172.16.0.12 Chef Client finished, 0/0 resources updated in 1.179038534 seconds

```

Now you could list all of the client under your workstation directory:    

```
$ knife client list
QuickClient
twocloud-validator
```

QuickClient is the node we just added.     

Here provides a good start-point for following operations, next step you could do more magics on newly added nodes, also you could add more nodes for deployment.     
