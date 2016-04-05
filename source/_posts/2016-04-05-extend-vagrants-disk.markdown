---
layout: post
title: "Extend Vagrant's Disk"
date: 2016-04-05 15:30:35 +0800
comments: true
categories: Virtualization
---
In Vagrantfile, edit the following definition:    

```
  config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
    vb.memory = "1024"
    file_to_disk = File.realpath( "." ).to_s + "/disk.vdi"
    if ARGV[0] == "up" && ! File.exist?(file_to_disk) 
      puts "Creating 5GB disk #{file_to_disk}."
      vb.customize [
        'createhd', 
        '--filename', file_to_disk, 
        '--format', 'VDI', 
        '--size', 5000 * 1024 # 5 GB
        ] 
      vb.customize [
        'storageattach', :id, 
        '--storagectl', 'SATA', 
        '--port', 1, '--device', 0, 
        '--type', 'hdd', '--medium', 
        file_to_disk
        ]
    end
    #config.vm.provision "shell", path: "scripts/add_new_disk.sh"
  end
  config.vm.provision "shell", path: "scripts/add_new_disk.sh"
```
The `add_new_disk.sh` should be written like following:    

```
set -e
set -x

if [ -f /etc/disk_added_date ]
then
   echo "disk already added so exiting."
   exit 0
fi


sudo fdisk -u /dev/sdb <<EOF
n
p
1


t
8e
w
EOF

pvcreate /dev/sdb1
vgextend VolGroup /dev/sdb1
lvextend /dev/VolGroup/lv_root
resize2fs /dev/VolGroup/lv_root

date > /etc/disk_added_date
```

Notice: this won't fit for Ubuntu Snappy Core.    
