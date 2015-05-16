---
layout: post
title: "Build Specified Version Of OpenContrail"
date: 2015-01-29 20:50
comments: true
categories: Virtualization
---
Since the default building of OpenContrail is master branch, while the installation deb file named like `contrail-install-packages_1.21-74~havana_all.deb`, this gap need to be filled via building.    
### View Different Branches
Repo hold all of the versions locally, simply view them via:    

```
# pwd
/root/Code/OpenContrail/.repo/manifests
# git branch -a | cut -d / -f 3
* default
master -> origin
R1.04
R1.05
R1.06
R1.06c1
R1.10
R1.30
R2.0
R2.1
gh-pages
master
opserver
rajreddy_doc_update
rajreddy_doc_update2
rajreddy_webui_third

```
While these branches doesn't contains `1.21`, why?    
### Specify Different Tag
In git admined project, tag is frequently be used, thus we could fetch the code via specified tag.    
Repo need to run following command to enable all of the sub-project syncs to specified tag, following I use `v1.21` tag for syncing.    

```
$ repo forall -c 'git checkout v1.21`
$ repo sync
$ python third_party/fetch_package.py && scons && make -f packages.make

```
Need a long time for checking the generated packages.      
Problem:    

```
dpkg-source: error: syntax error in contrail/debian/control at line 33: block
lacks the 'Package' field
dpkg-buildpackage: error: dpkg-source --before-build contrail gave error exit
status 25

```
when running `make -f packages.make`, it will failed, just remove the line before `packages` it will be OK.   
### Specify Different Branch
Specify the branch of:   

```
repo init -b android-2.3_r1 ; repo sync
repo init -b R2.20


```
