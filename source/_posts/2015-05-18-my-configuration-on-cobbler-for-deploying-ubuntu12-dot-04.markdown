---
layout: post
title: "My Configuration On Cobbler For Deploying Ubuntu12.04"
date: 2015-05-18 18:15:47 +0800
comments: true
categories: Virtualization
---
Configuration file for preseed, put it under: /var/lib/cobbler/kickstarts/autoinstall.seed:     

```
# BASIC
d-i  debian-installer/locale    string en_US.UTF-8
d-i  debian-installer/splash    boolean false
d-i  console-setup/ask_detect   boolean false
d-i  console-setup/layoutcode   string us
d-i  console-setup/variantcode  string
d-i  clock-setup/utc            boolean true
d-i  clock-setup/ntp            boolean true

# DISKPART
d-i  partman-auto/method                string regular
d-i  partman-lvm/device_remove_lvm      boolean true
d-i  partman-lvm/confirm                boolean true
d-i  partman/confirm_write_new_label    boolean true
d-i  partman/choose_partition           select Finish partitioning and write changes to disk
d-i  partman/confirm                    boolean true
d-i  partman/confirm_nooverwrite        boolean true
d-i  partman/default_filesystem         string ext3

# SOFTWARE
# /var/www/cobbler/ks_mirror/Ubuntu12.04-x86_64/ubuntu/
d-i  mirror/country             string manual
d-i  mirror/http/hostname       string $http_server
d-i  mirror/http/directory      string /cobbler/ks_mirror/Ubuntu12.04-x86_64/ubuntu
d-i  mirror/http/proxy          string
d-i  apt-setup/security_host    string $http_server
d-i  apt-setup/security_path    string /cobbler/ks_mirror/Ubuntu12.04-x86_64/ubuntu
d-i  apt-setup/services-select  multiselect none
d-i  pkgsel/upgrade             select none
d-i  pkgsel/language-packs      multiselect
d-i  pkgsel/update-policy       select none
d-i  pkgsel/updatedb            boolean true
d-i  pkgsel/include             string openssh-server

# USER
d-i  passwd/root-login                  boolean true
d-i  passwd/make-user                   boolean false
d-i  passwd/root-password               password root
d-i  passwd/root-password-again         password root
d-i  user-setup/allow-password-weak     boolean true

# FINISH
d-i  grub-installer/skip                boolean false
d-i  lilo-installer/skip                boolean false
d-i  grub-installer/only_debian         boolean true
d-i  grub-installer/with_other_os       boolean true
d-i  finish-install/keep-consoles       boolean false
d-i  finish-install/reboot_in_progress  note
d-i  cdrom-detect/eject                 boolean true
d-i  debian-installer/exit/halt         boolean false
d-i  debian-installer/exit/poweroff     boolean false

# EXTRA
d-i  preseed/late_command       string echo "UseDNS no" >> /target/etc/ssh/sshd_config

```
Edit the profile via:    

```
$ cobbler profile list
$ cobbler profile edit --name=Ubuntu12.04-x86_64 --kickstart=/var/lib/cobbler/kickstarts/autoinstall.seed 
```

Now select the installation, your installation will use local repository.    
