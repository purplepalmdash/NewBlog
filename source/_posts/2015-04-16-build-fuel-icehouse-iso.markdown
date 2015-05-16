---
layout: post
title: "Build fuel icehouse iso"
date: 2015-04-16 15:26
comments: true
categories: virtualization
---
Fuel6.0 didn't support icdhouse by default, so we have to build it manually, the steps are listed as following:     

```
apt-get install git
mkdir ~/fuel
cd ~/fuel
git clone https://github.com/stackforge/fuel-main.git
cd fuel-main
 ./prepare-build-env.sh
export MIRROR_BASE=http://mirror.fuel-infra.org/fwm/6.0-icehouse
make iso

```
After making the iso which have icehouse will be available.    

### TroubleShooting
Some modifications should be made before we make them:     

```
Trusty@ubuntu1204:~/code/fuel6.0/fuel-main$ git checkout stable/6.0
Branch stable/6.0 set up to track remote branch stable/6.0 from origin.
Switched to a new branch 'stable/6.0'
Trusty@ubuntu1204:~/code/fuel6.0/fuel-main$ git branch
  master
* stable/6.0

```
