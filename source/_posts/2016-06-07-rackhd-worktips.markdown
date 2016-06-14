---
layout: post
title: "RackHD Worktips"
date: 2016-06-07 17:05:19 +0800
comments: true
categories: Virtualization
---
### Vagrant Preparation
rackhd/rackhd vagrant box could be downloaded from following link:    

[https://atlas.hashicorp.com/rackhd/boxes/rackhd](https://atlas.hashicorp.com/rackhd/boxes/rackhd)    

Clone the repository from the github:    

```
$ pwd
/home/dash/Code/Jun13
$ git clone https://github.com/RackHD/RackHD
$ cd RackHD
```
Change into the directory example, create config and run the setup command:    

```
$ cd example
$ cp config/monorail_rack.cfg.example config/monorail_rack.cfg
```

Edits can be made to this new file to adjust the number of pxe clients created.    

```
$ bin/monorail_rack
```

The `monorail_rack` script will auto-start all of the services by default, but you can also run them manually if you prefer.

```
$ vagrant ssh
vagrant:~$ sudo nf start
```

Unfortunately, the vagrant machine won't work due to bad networking.    

### Customization Deployment
Use a trusty based vagrant box for creating the rackhd node.    

```
$ vagrant init trustyvirtualbox
$ vim Vagrantfile
```
Vagrantfile's configuration modification is listed as following:    

```
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Added more disks
+   file_to_disk = File.realpath( "." ).to_s + "/disk.vdi"

  # config.vm.network "private_network", ip: "192.168.33.10"
+   config.vm.network "private_network", ip: "172.31.128.1", virtualbox__intnet:  "closednet"

+  config.vm.provider "virtualbox" do |vb|
+    if ARGV[0] == "up" && ! File.exist?(file_to_disk) 
+      puts "Creating 5GB disk #{file_to_disk}."
+      vb.customize [
+        'createhd', 
+        '--filename', file_to_disk, 
+        '--format', 'VDI', 
+        '--size', 5000 * 1024 # 5 GB
+      ] 
+      vb.customize [
+        'storageattach', :id, 
+        '--storagectl', 'IDE Controller', 
+        '--port', 1, '--device', 0, 
+        '--type', 'hdd', '--medium', 
+        file_to_disk
+      ] 
+    end
+    vb.memory = "4096"
+    vb.cpus = 2
+    vb.customize ["modifyvm", :id, "--nicpromisc2", "allow-all", "--ioapic", "on"]
+  end
```

Then `vagrant up` for start up the machine.   

Notice: the controller of the disk should be noticed very carefully, you could choose
"IDE Controller" Or "SATA Controller", depending on your virtualbox configuration.    
Then follow the tips on:    

[http://purplepalmdash.github.io/blog/2016/06/01/use-rakehd-for-deploying-systems/](http://purplepalmdash.github.io/blog/2016/06/01/use-rakehd-for-deploying-systems/)    
Extend the root partition of vagrant disk via:    

```
$ sudo pvcreate /dev/sdb
$ sudo vgextend vagrant-vg /dev/sdb
$ sudo lvextend -l +100%FREE /dev/vagrant-vg/root
$ sudo resize2fs  /dev/vagrant-vg/root
```

### Adding Ubuntu Deployment
Install `apt-mirror` first, then using following mirror configuration file:    

```
$ vim /etc/apt/mirror.list
############# config ##################
#
# set base_path    /var/spool/apt-mirror
#
# set mirror_path  $base_path/mirror
# set skel_path    $base_path/skel
# set var_path     $base_path/var
# set cleanscript $var_path/clean.sh
# set defaultarch  <running host architecture>
# set postmirror_script $var_path/postmirror.sh
# set run_postmirror 0
set base_path	/var/mirrors/ubuntu/14.04
set nthreads     20
set _tilde 0
#
############# end config ##############

deb-amd64 http://mirrors.aliyun.com/ubuntu	trusty main main/debian-installers
deb http://mirrors.aliyun.com/ubuntu	trusty main/installer-amd64
deb-amd64 http://mirrors.aliyun.com/ubuntu	trusty-updates main
deb-amd64 http://mirrors.aliyun.com/ubuntu	trusty-security main
clean http://mirrors.aliyun.com/ubuntu
```
Also you have to create following script for downloading the debian-installer:    

```
$ vim /var/mirrors/ubuntu/14.04/var/postmirror.sh 
#!/bin/sh -x 
# the udebs script gets the actual files we need 
#/mnt/repo/apt-mirror/var/udebs.sh  
# A quick apt directory structure primer: 
# an apt server (e.g. archive.ubuntu.com) contains repositories (e.g. trusty-backports), 
# which contain archives (e.g. multiverse), which contain directories 
# a complete example - http://archive.ubuntu.com/ubuntu/dists/trusty-backports/multiverse/debian-installer/  
# With this in mind, we create bash 'arrays' of the structure: 
# server we're syncing against 
#MIRROR="cn.archive.ubuntu.com" 
MIRROR="archive.ubuntu.com" 
# repositories we're mirroring 
#REPOS="trusty trusty-updates trusty-security trusty-proposed trusty-backports" 
REPOS="trusty"
# archives in repositories 
#ARCHIVES="main multiverse restricted universe" 
ARCHIVES="main"
# installer location inside archive 
#DIRECTORIES="debian-installer dist-upgrader-all installer-amd64 installer-i386" 
DIRECTORIES="debian-installer installer-amd64"
#where we're storing it locally 
LOCALDIR="/var/mirrors/ubuntu/14.04/mirror/mirrors.aliyun.com"
#LOCALDIR="/mnt/repo/apt-mirror/mirror/archive.ubuntu.com"  
for REPO in $REPOS; do 
for ARCHIVE in $ARCHIVES; do 
for DIRECTORY in $DIRECTORIES;do 
# create directory structure 
if [ ! -e "$LOCALDIR/ubuntu/dists/$REPO/$ARCHIVE/$DIRECTORY" ]; then
mkdir -p "$LOCALDIR/ubuntu/dists/$REPO/$ARCHIVE/$DIRECTORY"
fi
# do the sync 
rsync --recursive --times --links --hard-links --delete --delete-after \
rsync://$MIRROR/ubuntu/dists/$REPO/$ARCHIVE/$DIRECTORY/ $LOCALDIR/ubuntu/dists/$REPO/$ARCHIVE/$DIRECTORY
done
done
done
```
Now run `sudo apt-mirror` for syncing the repository to local storage.  

Also create a shortcut to the repository in RackHD System:    

```
$ sudo ln -s /var/mirrors/ubuntu/14.04/mirror/mirrors.aliyun.com/ubuntu/ /opt/monorail/static/http/
``` 

Now restart the rackhd node, the ubuntu deployment is ready for use.     

### Ubuntu Deployment
Add the json file which holds the ubuntu deployment:    

```
$ pwd
/home/vagrant/RackHD/example
$ vim samples/ubuntu_boot.json 
{
    "name": "Graph.InstallUbuntu",
    "options": {
        "defaults": {
            "obmServiceName": "noop-obm-service"
        },
        "install-os": {
            "repo": "{{api.server}}/ubuntu",
            "rootPassword": "ubuntu",
            "profile": "install-trusty.ipxe",
            "completionUri": "renasar-ansible.pub"
        }
    }
}
```
In fact the `rootPassword` is not ready for use, the real password after deployment 
 is `RackHDRocks!`.   

Add one node(first you should make it pxed):    

```
$ curl -H "Content-Type: application/json" -X POST --data @samples/noop_body.json http://localhost:8080/api/1.1/nodes/575fce38d23ba028051b4711/obm
$ curl -H "Content-Type: application/json" -X POST --data @samples/ubuntu_boot.json http://localhost:8080/api/1.1/nodes/575fce38d23ba028051b4711/workflows
``` 

Then restart the machine, you will get it installing ubuntu.   
