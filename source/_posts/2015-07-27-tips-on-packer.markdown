---
layout: post
title: "Tips On Packer"
date: 2015-07-27 12:18:46 +0800
comments: true
categories: Virtualization
---
### Installation
Install Packer via:    

```
$ wget https://dl.bintray.com/mitchellh/packer/packer_0.8.2_linux_amd64.zip
$ unzip packer_0.8.2_linux_amd64.zip
$ mv packer* ~/bin
$ export PATH=~/bin:$PATH
```

### KVM Based Image Build
Fetch the kickstart configuration file.  

```
$ mkdir ~/Code/packer
$ wget https://gist.githubusercontent.com/mitchellh/7328271/raw/9035b8e26d001f14a2a960d3cec65eceb0e716ea/centos6-ks.cfg
# vim centos6-ks.cfg
	### Replace your own repository URL
```

Create the json definition file for the packer build:   

```
$  packer validate first.json
Template validated successfully.
$ cat first.json
{
  "builders":
  [
    {
      "type": "qemu",
      "iso_url": "/media/opensuse/dash/iso/CentOS-6.6-x86_64-bin-DVD1.iso",
      "iso_checksum": "7b1fb1a11499b31271ded79da6af8584",
      "iso_checksum_type": "md5",
      "output_directory": "output_centos_tdhtest",
      "ssh_wait_timeout": "30s",
      "shutdown_command": "shutdown -P now",
      "disk_size": 5000,
      "format": "qcow2",
      "headless": false,
      "accelerator": "kvm",
      "http_directory": "httpdir",
      "http_port_min": 10082,
      "http_port_max": 10089,
      "ssh_host_port_min": 2222,
      "ssh_host_port_max": 2229,
      "ssh_username": "root",
      "ssh_password": "YourPassword",
      "ssh_port": 22,
      "ssh_wait_timeout": "90m",
      "vm_name": "tdhtest",
      "net_device": "virtio-net",
      "disk_interface": "virtio",
      "boot_wait": "5s",
      "boot_command":
      [
        "<tab> text ks=http://192.168.1.79/centos6-cdrom.cfg<enter><wait>"
      ]
    }
  ]
}
$  packer validate first.json
Template validated successfully.
```

Now start build via:   

```
packer build first.json
```

### KickStart File
An Template:    

```
[root:/var/www/html]# cat centos6-cdrom.cfg
#platform=x86, AMD64, or Intel EM64T
#version=DEVEL
# Firewall configuration
firewall --enabled --ssh --service=ssh
# Install OS instead of upgrade
install
# Use CDROM installation media
cdrom

rootpw  YourPassword
authconfig --enableshadow --passalgo=sha512

# System keyboard
keyboard uk
# System language
lang en_GB
# SELinux configuration
selinux --enforcing
# Do not configure the X Window System
skipx
# Installation logging level
logging --level=info

# Reboot after installation
reboot

# System timezone
timezone --isUtc Asia/Shanghai
# Network information
network  --bootproto=dhcp --device=eth0 --onboot=on
# System bootloader configuration
bootloader --append="crashkernel=auto rhgb quiet" --location=mbr --driveorder="vda"

# Partition clearing information
zerombr
clearpart --all  --drives=vda

# Disk partitioning information
part /boot --fstype="ext4" --size=500
part pv.008002 --grow --size=1
volgroup vg_centos --pesize=4096 pv.008002
logvol / --fstype=ext4 --name=lv_root --vgname=vg_centos --grow --size=1024
--maxsize=51200
logvol swap --name=lv_swap --vgname=vg_centos --grow --size=1024 --maxsize=1024

%packages --nobase
@core
at
acpid
cronie-noanacron
crontabs
logrotate
mailx
mlocate
openssh-clients
openssh-server
rsync
sendmail
tmpwatch
vixie-cron
which
wget
yum
-biosdevname
-postfix
-prelink
%end
```

### Build And Output

```
$ packer  build second.json
qemu output will be in this color.

==> qemu: Downloading or copying ISO
    qemu: Downloading or copying:
file:///media/opensuse/dash/iso/CentOS-6.6-x86_64-bin-DVD1.iso
==> qemu: Creating hard drive...
==> qemu: Starting HTTP server on port 10088
==> qemu: Found port for SSH: 2224.
==> qemu: Looking for available port between 5900 and 6000
==> qemu: Found available VNC port: 5947
==> qemu: Starting VM, booting from CD-ROM
==> qemu: Waiting 5s for boot...
==> qemu: Connecting to VM via VNC
==> qemu: Typing the boot command over VNC...
==> qemu: Waiting for SSH to become available...
==> qemu: Connected to SSH!
==> qemu: Gracefully halting virtual machine...
Build 'qemu' finished.

==> Builds finished. The artifacts of successful builds are:
--> qemu: VM files in directory: output_centos_tdhtest
$ ls
output_centos_tdhtest  packer_cache  second.json
$ ls -l output_centos_tdhtest 
total 1411208
-rw-r--r-- 1 dash dash 1445134336 Jul 27 16:11 tdhtest
```

Next time we will investigate ubuntu installation.    

### Ubuntu
Ubuntu64.json:    

```
{
    "variables": {
        "ssh_name": "kappataumu",
        "ssh_pass": "kappataumu",
        "hostname": "packer-test"
    },

    "builders": [{
        "type": "virtualbox-iso",
        "guest_os_type": "Ubuntu_64",

        "vboxmanage": [
            ["modifyvm", "{{.Name}}", "--vram", "32"]
        ],

        "disk_size" : 10000,

        "iso_url": "http://192.168.0.79/ubuntu-12.04.3-server-amd64.iso",
        "iso_checksum": "2cbe868812a871242cdcdd8f2fd6feb9",
        "iso_checksum_type": "md5",

        "http_directory" : "ubuntu_64",
        "http_port_min" : 9001,
        "http_port_max" : 9001,

        "ssh_username": "{{user `ssh_name`}}",
        "ssh_password": "{{user `ssh_pass`}}",
        "ssh_wait_timeout": "20m",

        "shutdown_command": "echo {{user `ssh_pass`}} | sudo -S shutdown -P now",

        "boot_command" : [
            "<esc><esc><enter><wait>",
            "/install/vmlinuz noapic ",
            "preseed/url=http://192.168.0.79/ubuntu1204preseed.cfg ",
            "debian-installer=en_US auto locale=en_US kbd-chooser/method=us ",
            "hostname={{user `hostname`}} ",
            "fb=false debconf/frontend=noninteractive ",
            "keyboard-configuration/modelcode=SKIP keyboard-configuration/layout=USA ",
            "keyboard-configuration/variant=USA console-setup/ask_detect=false ",
            "initrd=/install/initrd.gz -- <enter>"
        ]
    }]
}

```

The Preseed File:    

```
# Some inspiration:
# *
https://github.com/chrisroberts/vagrant-boxes/blob/master/definitions/precise-64/preseed.cfg
# * https://github.com/cal/vagrant-ubuntu-precise-64/blob/master/preseed.cfg

# English plx
d-i debian-installer/language string en
d-i debian-installer/locale string en_US.UTF-8
d-i localechooser/preferred-locale string en_US.UTF-8
d-i localechooser/supported-locales en_US.UTF-8

# Including keyboards
d-i console-setup/ask_detect boolean false
d-i keyboard-configuration/layout select USA
d-i keyboard-configuration/variant select USA
d-i keyboard-configuration/modelcode string pc105


# Just roll with it
d-i netcfg/get_hostname string this-host
d-i netcfg/get_domain string this-host

d-i time/zone string UTC
d-i clock-setup/utc-auto boolean true
d-i clock-setup/utc boolean true


# Choices: Dialog, Readline, Gnome, Kde, Editor, Noninteractive
d-i debconf debconf/frontend select Noninteractive

d-i pkgsel/install-language-support boolean false
tasksel tasksel/first multiselect standard, ubuntu-server


# Stuck between a rock and a HDD place
d-i partman-auto/method string lvm
d-i partman-lvm/confirm boolean true
d-i partman-lvm/device_remove_lvm boolean true
d-i partman-auto/choose_recipe select atomic

d-i partman/confirm_write_new_label boolean true
d-i partman/confirm_nooverwrite boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true

# Write the changes to disks and configure LVM?
d-i partman-lvm/confirm boolean true
d-i partman-lvm/confirm_nooverwrite boolean true
d-i partman-auto-lvm/guided_size string max

# No proxy, plx
d-i mirror/http/proxy string

# Default user, change
d-i passwd/user-fullname string adminubuntu
d-i passwd/username string adminubuntu
d-i passwd/user-password password adminubuntu
d-i passwd/user-password-again password adminubuntu
d-i user-setup/encrypt-home boolean false
d-i user-setup/allow-password-weak boolean true

# No language support packages.
d-i pkgsel/install-language-support boolean false

# Individual additional packages to install
d-i pkgsel/include string build-essential ssh

#For the update
d-i pkgsel/update-policy select none

# Whether to upgrade packages after debootstrap.
# Allowed values: none, safe-upgrade, full-upgrade
d-i pkgsel/upgrade select safe-upgrade

# Go grub, go!
d-i grub-installer/only_debian boolean true

d-i finish-install/reboot_in_progress note
```
