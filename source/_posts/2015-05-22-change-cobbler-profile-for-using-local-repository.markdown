---
layout: post
title: "Change Cobbler Profile For Using Local Repository"
date: 2015-05-22 14:12:58 +0800
comments: true
categories: Virtualization
---
### Cobbler Profiles
For getting the profiles and get the detailed information of the profile.    

```
# cobbler profile list
   ubuntu1404-x86_64
# cobbler profile help
usage
=====
cobbler profile add
cobbler profile copy
cobbler profile dumpvars
cobbler profile edit
cobbler profile find
cobbler profile getks
cobbler profile list
cobbler profile remove
cobbler profile rename
cobbler profile report
# cobbler profile report ubuntu1404-x86_64
......
Kickstart                      : /var/lib/cobbler/kickstarts/sample.seed
......

```

### Use Local Repository
For adding the repository via following command, you could use your local repository:    

```
$ sudo cobbler repo add --name=local-trusty --breed=apt --arch=x86_64 --mirror=http://xxxxxxxxxxxxxx/ubuntu --apt-components=main,restricted,universe,multiverse --apt-dists=trusty,trusty-updates,trusty-security
$ sudo cobbler repo sync
```
After syncing, the folder will contains all of the packages:    

```
# pwd
/var/www/cobbler/ks_mirror/ubuntu1404-x86_64
# ls
boot  dists  doc  EFI  install  isolinux  md5sum.txt  pics  pool  preseed  README.diskdefines  ubuntu
```

Edit the sample seed via:     

```
# cp /var/lib/cobbler/kickstarts/sample.seed /var/lib/cobbler/kickstarts/local.seed
# vim /var/lib/cobbler/kickstarts/local.seed

    d-i mirror/http/hostname string $http_server
    # d-i mirror/http/directory string $install_source_directory
    d-i mirror/http/directory string /cobbler/ks_mirror/ubuntu1404-x86_64/ubuntu/
    d-i mirror/http/proxy string 
    d-i apt-setup/security_host string $http_server
    d-i apt-setup/security_path string /cobbler/ks_mirror/Ubuntu-14.04-x86_64/ubuntu
    d-i apt-setup/services-select multiselect none

```

Then Modify the profile's kickstart via:    

```
#  cobbler profile edit --name=ubuntu1404-x86_64 --kickstart=/var/lib/cobbler/kickstarts/local.seed
```

After modification, next time if you re-install the compute, it will directly get the packages from the local repository.    


