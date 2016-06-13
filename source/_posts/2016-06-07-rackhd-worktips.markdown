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

