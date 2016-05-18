---
layout: post
title: "Working Tips on Ansible-cobbler(3)"
date: 2016-05-18 21:15:10 +0800
comments: true
categories: Linux
---
### APT Packages
The downloaded deb files should be under `/var/cache/apt`, use following command for copying to
another position:    

```
$ find . | grep -i deb$ | xargs % cp % ~/Dest_Folder
$ scp -r ~/Dest_Folder Your_Cobbler_Machine
```
### Repositories
Install `dpkg-dev` package, so we could generate the dpkg packages:    

```
$ sudo apt-get install -y dpkg-dev
```
Create a new repository:    

![/images/2016_05_18_21_28_37_717x452.jpg](/images/2016_05_18_21_28_37_717x452.jpg)    

Edit the advanced options:    

![/images/2016_05_18_21_30_04_508x314.jpg](/images/2016_05_18_21_30_04_508x314.jpg)    

Report the repository info via:    

```
root@cobbler-ubuntu:~# cobbler repo report --name=ubuntu1604Mate
Name                           : ubuntu1604Mate
Apt Components (apt only)      : ['main']
Apt Dist Names (apt only)      : ['stable']
Arch                           : x86_64
Breed                          : apt
Comment                        : Ubuntu 16.04 Repository For installing MATE
Createrepo Flags               : <<inherit>>
Environment Variables          : {}
Keep Updated                   : False
Mirror                         : 
Mirror locally                 : True
Owners                         : ['admin']
Priority                       : 99
External proxy URL             : 
RPM List                       : []
Yum Options                    : {}
```
Repository Structure Creation:    

```
$ mkdir /srv/www/cobbler/repo_mirror/ubuntu1604Mate
$ cd /srv/www/cobbler/repo_mirror/ubuntu1604Mate
$ mkdir -p pool/main dists/stable/main/binary-i386 dists/stable/main/binary-amd64
$ cp ~/apt/debs/*.deb ./pool/main/
```
Enable the `allow_unauthenticated` options in kickstart file:    

```
$ vim /var/lib/cobbler/kickstarts/sample.seed
 d-i debian-installer/allow_unauthenticated boolean true
```
Generate the gpg key:    

```
# gpg --gen-key
  gpg (GnuPG) 2.0.14; Copyright (C) 2009 Free Software Foundation, Inc.
  This is free software: you are free to change and redistribute it.
  There is NO WARRANTY, to the extent permitted by law.

  gpg: directory `/root/.gnupg' created
  gpg: new configuration file `/root/.gnupg/gpg.conf' created
  gpg: WARNING: options in `/root/.gnupg/gpg.conf' are not yet active during this run
  gpg: keyring `/root/.gnupg/secring.gpg' created
  gpg: keyring `/root/.gnupg/pubring.gpg' created
 Please select what kind of key you want:
    (1) RSA and RSA (default)
    (2) DSA and Elgamal
    (3) DSA (sign only)
    (4) RSA (sign only)
 Your selection? 1
 RSA keys may be between 1024 and 4096 bits long.
 What keysize do you want? (2048)
 Requested keysize is 2048 bits
 Please specify how long the key should be valid.
          0 = key does not expire
       <n>  = key expires in n days
       <n>w = key expires in n weeks
       <n>m = key expires in n months
       <n>y = key expires in n years
 Key is valid for? (0)
 Key does not expire at all
 Is this correct? (y/N) y
```
For generating the random key, install the `haveged` in system:    

```
$ sudo aptitude install haveged
```
List the keys via:    

```
# gpg --list-keys
/home/vagrant/.gnupg/pubring.gpg
--------------------------------
pub   2048R/16D87321 2016-05-18
uid                  xxxxx <xxxxxx@gmail.com>
sub   2048R/8C4A318A 2016-05-18
```
Generate the pgp signature via:     

```
# gpg --export -a 16D87321>~/junk.key
# gpg --no-default-keyring --keyring /srv/www/cobbler/repo_mirror/ubuntu1604Mate/public.pgp --import ~/junk.key
# rm -f ~/junk.key
# chmod a+r /srv/www/cobbler/repo_mirror/ubuntu1604Mate/public.pgp
```
Re-Generate the repository infos via:    

```
$ cd /srv/www/cobbler/repo_mirror/ubuntu1604Mate/
$ vim reindex_apt.sh
$ chmod 777 reindex_apt.sh 
$ ./reindex_apt.sh 
```

The content of `reindex_apt.sh` is listed as following:     

```
#!/bin/bash

GPG_NAME=16D87321
REPONAME=stable
VERSION=1.0

for bindir in `find dists/${REPONAME} -type d -name "binary*"`; do
    arch=`echo $bindir|cut -d"-" -f 2`
    echo "Processing ${bindir} with arch ${arch}"

    overrides_file=/tmp/overrides
    package_file=$bindir/Packages
    release_file=$bindir/Release

    # Create simple overrides file to stop warnings
    cat /dev/null > $overrides_file
    for pkg in `ls pool/main/ | grep -E "(all|${arch})\.deb"`; do
        pkg_name=`/usr/bin/dpkg-deb -f pool/main/${pkg} Package`
        echo "${pkg_name} Priority extra" >> $overrides_file
    done

    # Index of packages is written to Packages which is also zipped
    dpkg-scanpackages -a ${arch} pool/main $overrides_file > $package_file
    # The line above is also commonly written as:
    # dpkg-scanpackages -a ${arch} pool/main /dev/null > $package_file
    gzip -9c $package_file > ${package_file}.gz
    bzip2 -c $package_file > ${package_file}.bz2

    # Cleanup
    rm $overrides_file
done

# Release info goes into Release & Release.gpg which includes an md5 & sha1 hash of Packages.*
# Generate & sign release file
cd dists/${REPONAME}
cat > Release <<ENDRELEASE
Suite: ${REPONAME}
Version: ${VERSION}
Component: main
Origin: somewhere
Label: ubuntu1604Mate
Architecture: i386 amd64
Date: `date`
ENDRELEASE

# Generate hashes
echo "MD5Sum:" >> Release
for hashme in `find main -type f`; do
    md5=`openssl dgst -md5 ${hashme}|cut -d" " -f 2`
    size=`stat -c %s ${hashme}`
    echo " ${md5} ${size} ${hashme}" >> Release
done
echo "SHA1:" >> Release
for hashme in `find main -type f`; do
    sha1=`openssl dgst -sha1 ${hashme}|cut -d" " -f 2`
    size=`stat -c %s ${hashme}`
    echo " ${sha1} ${size} ${hashme}" >> Release
done

# Sign!
gpg --yes -u $GPG_NAME --sign -bao Release.gpg Release
cd -
```
Now continue to modify the kickstart file for using the generated gpgs:     

```
# pwd
/var/lib/cobbler/snippets
# cp preseed_apt_repo_config preseed_apt_repo_config_pgpkey
```

The `preseed_apt_repo_config_pgpkey` should be listed as following:    

```
# Additional repositories, local[0-9] available
#set $cur=1
#set $repo_data = $getVar("repo_data",[])
#for $repo in $repo_data
 #for $dist in $repo.apt_dists
 #set $comps = " ".join($repo.apt_components)
d-i apt-setup/local${cur}/repository string \
 #if $repo.mirror_locally
      http://$http_server/cblr/repo_mirror/${repo.name} $dist $comps
 #else
      ${repo.mirror} $dist $comps
 #end if
 #if $repo.comment != ""
d-i apt-setup/local${cur}/comment string ${repo.comment}
 #end if
 #if $repo.breed == "src"
# Enable deb-src lines
d-i apt-setup/local${cur}/source boolean false
 #end if
+++ # Add repo pgp pub key
+++ d-i apt-setup/local${cur}/key string \
+++       http://$http_server/cblr/repo_mirror/${repo.name}/public.pgp
 #set $cur=$cur+1
 #end for
#end for
```
Using the new preseed file, and changint the `preseed_apt_repo_config_pgpkey`:    

```
# pwd
/var/lib/cobbler/kickstarts
# cp sample.seed ubuntu1604.seed
# vim ubuntu1604.seed
-  $SNIPPET('preseed_apt_repo_config')
+  $SNIPPET('preseed_apt_repo_config_pgpkey')
```
Changing the seed in the `cobbler_web`:    

![/images/2016_05_18_22_25_48_732x294.jpg](/images/2016_05_18_22_25_48_732x294.jpg)    

Use `cobbler sync` for syncing the configuration.    

### Use the Repository
Add the `ubuntu1604Mate` into the Repos:    

![/images/2016_05_18_22_31_42_731x486.jpg](/images/2016_05_18_22_31_42_731x486.jpg)    

After added, the configuration should be:    

![/images/2016_05_18_22_33_00_471x149.jpg](/images/2016_05_18_22_33_00_471x149.jpg)    

Now `cobbler sync` for syncing the configuration.     

Bug: you should move the `preseed_apt_repo_config` and  then `cobbler sync` then your deployment will be OK:    

```
$ mv /var/lib/cobbler/snippets/preseed_apt_repo_config /root/
$ cobbler sync
```

### Added Mate Installation
Configure the preseed late:    

```
# cp /var/lib/cobbler/scripts/preseed_late_default /var/lib/cobbler/scripts/preseed_late_default_mate
# vim /var/lib/cobbler/scripts/preseed_late_default_mate
# vim preseed_late_default_mate 
$SNIPPET('post_install_network_config_deb')
$SNIPPET('late_apt_repo_config')
$SNIPPET('post_run_deb')
$SNIPPET('download_config_files')
+ $SNIPPET('ubuntumate')
$SNIPPET('kickstart_done')
```
Now add the snippet of `ubuntumate`:    

```
# cat ../snippets/ubuntumate 
echo "debconf debconf/frontend select noninteractive" | sudo debconf-set-selections
apt-get --allow-unauthenticated update -y
apt-get --allow-unauthenticated upgrade -y
apt-get --allow-unauthenticated install -y build-essential
### apt-get --allow-unauthenticated install -y ubuntu-mate-desktop
apt-get --allow-unauthenticated install -y vim
### apt-get --allow-unauthenticated install -y chromium-browser
### apt-get --allow-unauthenticated install -y meld vim-gtk
### apt-get --allow-unauthenticated install -y evince
### sudo apt-get --allow-unauthenticated install -y language-pack-zh-hans language-pack-zh-hans-base language-pack-gnome-zh-hans language-pack-gnome-zh-hans-base
### sudo apt-get --allow-unauthenticated install -y `check-language-support -l zh`
### sudo localectl set-locale LANG=zh_CN.UTF-8
### # TW/HK language support
### sudo apt-get --allow-unauthenticated install -y language-pack-zh-hant language-pack-zh-hant-base language-pack-gnome-zh-hant language-pack-gnome-zh-hant-base
### sudo apt-get --allow-unauthenticated install -y `check-language-support -l zh`
### apt-get --allow-unauthenticated install -y fcitx
### apt-get --allow-unauthenticated install -y fcitx-table-wubi fcitx-table-wubi-large
### apt-get --allow-unauthenticated install -y fcitx-googlepinyin
### apt-get --allow-unauthenticated install -y gimp
### apt-get --allow-unauthenticated install -y ibus-pinyin 
### apt-get --allow-unauthenticated install -y thunderbird-locale-en-us mythes-en-au hunspell-en-gb thunderbird-locale-en-gb fonts-arphic-ukai wbritish fcitx-sunpinyin openoffice.org-hyphenation language-pack-gnome-en hunspell-en-za fcitx-chewing fcitx-table-cangjie gimp-help-en language-pack-en mythes-en-us thunderbird-locale-en fcitx-module-cloudpinyin libreoffice-help-en-us firefox-locale-en libreoffice-help-en-gb fonts-arphic-uming hyphen-en-gb libreoffice-l10n-en-za fcitx-ui-qimpanel hunspell-en-au libreoffice-l10n-en-gb hyphen-en-us hunspell-en-ca 
### apt-get --allow-unauthenticated install -y zsh
### apt-get --allow-unauthenticated install -y fonts-wqy-zenhei fonts-wqy-microhei ttf-wqy-microhei  ttf-wqy-zenhei  xfonts-wqy
### apt-get --allow-unauthenticated install -y eclipse
### apt-get --allow-unauthenticated install -y gpicview
### apt-get --allow-unauthenticated install -y scrot
### apt-get --allow-unauthenticated install -y byobu
### apt-get --allow-unauthenticated install -y subversion git
### apt-get --allow-unauthenticated install -y kdiff3
### apt-get --allow-unauthenticated install -y docker

```
Use `cobbler sync`, and now you could deploy mate desktop via cobbler.    
