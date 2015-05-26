---
layout: post
title: "Chef Setup"
date: 2015-05-26 16:17:14 +0800
comments: true
categories: Chef
---
For automatically deploying OpenStack, I use Chef for deployment, following records the steps for setting up the whole environment.     

### Machine Preparation
Chef Server: 2-Core, 3G Memory, IP address: xxx.xxx.10.211, Ubuntu14.04.    
Chef Workstation: 4-Core, 8G Memory, a physical machine, IP address: xxx.xxx.0.119, Ubuntu14.04.     


### Install Server
Install the chef-server package, which downloaded from chef.io website, after installation, simply reconfigure it, this finishes the installation and configuration.     

```
$ sudo dpkg -i chef-server-core_12.0.8-1_amd64.deb
$ sudo chef-server-ctl reconfigure
```

Configure the permit file, also create the user and organization for the chef:    

```
# sudo chef-server-ctl user-crate YourName FirstName LastName Email PassWord --filename YourPermitFileName
$ sudo chef-server-ctl user-create youname YYYXXX Man xxxxxxx@163.com YOURPASSWORD --filename ~/youname.pem
# sudo chef-server-ctl org-create YourOrgName Your Company Name  --association_user YourUser --filename  YourOrgnizationPermitFile
$ sudo chef-server-ctl org-create youname YYYXXX Software, Inc. --association_user youname --filename ~/youname_org.pem
```

Install opscode-manager and reconfigure it via following commands:    

```
$ sudo dpkg -i opscode-manage_1.13.0-1_amd64.deb 
$ sudo opscode-manage-ctl reconfigure
```

Now visit the webiste to see the Chef Server UI.   

[https://YourURL](https://YourURL)    

![/images/2015_05_26_16_44_58_610x297.jpg](/images/2015_05_26_16_44_58_610x297.jpg)    


### Chef Workstation
I use the physical machine for Chef Workstation.    

Install it via:    

```
$ sudo dpkg -i chef_12.3.0-1_amd64.deb
```

Fetch back the chef repository from github, configure it and add the ignore directory:    

```
$ git clone https://github.com/opscode/chef-repo.git
$ cd chef-repo 
$ mkdir .chef
$ echo ".chef">>~/chef-repo/.gitignore
$ git add .
$ git commit -m "Exclude the ./.chef directory from version control"
[master 64515ff] Exclude the ./.chef directory from version control
 1 file changed, 1 insertion(+)
```

Install the chefdk, and verify the chef, you should see all of the components OK, then you could continue for next step:     

```
$ sudo dpkg -i chefdk_0.6.0-1_amd64.deb 
$ chef verify
```

Transfer all of the pem file from the ChefServer to ChefWorkstation, and put them under the folder of ~/chef-repo/.chef:       

```
$ scp xxx@xxxxx:/home/xxx/*.pem xxxx@ChefWorkstation:/home/xxxx/chef-repo/.chef
```

Add following item under the Workstation's configuration:    

```
$ sudo vim /etc/hosts
XXX.xxx.xxx.xxx  ChefServer
```

Now configure the knife.rb and let your authentification be verified.    

```
$ vim ~/chef-repo/.chef/knife.rb
current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "xxxxxxxxx"
client_key               "#{current_dir}/xxxxxxxxx.pem"
validation_client_name   "xxxxxxxxx_org"
validation_key           "#{current_dir}/xxxxxxxxx_org.pem"
chef_server_url          "https://ChefServer/organizations/xxxxxxxxx"
syntax_check_cache_path  "#{ENV['HOME']}/.chef/syntaxcache"
cookbook_path            ["#{current_dir}/../cookbooks"]
$ knife ssl fetch
WARNING: Certificates from ChefServer will be fetched and placed in your trusted_cert
directory (/home/dash/chef-repo/.chef/trusted_certs).

Knife has no means to verify these are the correct certificates. You should
verify the authenticity of these certificates after downloading.

Adding certificate for ChefServer in /home/xxxx/chef-repo/.chef/trusted_certs/ChefServer.crt
$ knife ssl check
Connecting to host ChefServer:443
Successfully verified certificates from `ChefServer'
```
Check how many clients has been added into the ChefServer, currently only one,       

```
$ knife client list
xxxxxx-validator
```


### Added Nodes 

In Client1, Install the 

```
$ sudo dpkg -i chef_12.3.0-1_amd64.deb 
```

