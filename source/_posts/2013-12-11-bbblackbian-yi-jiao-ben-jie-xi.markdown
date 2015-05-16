---
layout: post
title: "BBBlack编译脚本解析"
date: 2013-12-11 19:14
comments: true
categories: Linux Embedded
---
###Preparation
Download the "linux-dev" repository from github:

```
	git clone git://github.com/RobertCNelson/linux-dev.git

```
View the downloaded packages:

```
	[Trusty@XXXyyy mykernel]$ du -hs linux-dev/
	19M	linux-dev/
	[Trusty@XXXyyy linux-dev]$ ls
	build_deb.sh  build_kernel.sh  build_mainline.sh  LICENSE  patches  patch.sh  README  repo_maintenance  scripts  system.sh.sample  tools  version.sh

```
Switch to the 3.12 Branch:

```
	git checkout origin/am33x-v3.12 -b tmp
	[Trusty@XXXyyy linux-dev]$ ls
	build_deb.sh  build_kernel.sh  LICENSE  patches  patch.sh  README  repo_maintenance  scripts  system.sh.sample  tools  version.sh

```
###Walk by lines
Since we call ./build_kernel.sh will initialize the building, we will first see what's in this file    
a. Create the deploy directory, Line 23-Line 25

```sh build_kernel.sh
	DIR=$PWD
	mkdir -p ${DIR}/deploy/

```
Then the code goes to line 189, since all of the code between 25-189 are functions. 

```sh build_kernel.sh
	/bin/sh -e ${DIR}/tools/host_det.sh || { exit 1 ; }

```
This line will call tools/host_det.sh to detect the host, the result is listed:

```
	[Trusty@XXXyyy linux-dev]$ tools/host_det.sh 
	which: no lsb_release in (/home/Trusty/.rvm/gems/ruby-1.9.3-p448/bin:/home/Trusty/.rvm/gems/ruby-1.9.3-p448@global/bin:/home/Trusty/.rvm/rubies/ruby-1.9.3-p448/bin:/home/Trusty/.rvm/bin:/media/y/embedded/cortex/gcc-arm-none-eabi-4_7-2013q3/bin:/home/Trusty/perl5/bin:/opt/cross/bin:/media/y/u-boot/4.3.2/bin/:/usr/local/sbin:/usr/local/bin:/usr/bin:/opt/android-sdk/platform-tools:/opt/android-sdk/tools:/usr/bin/site_perl:/usr/bin/core_perl)
	+ Detected build host []
	+ host: [x86_64]
	+ git HEAD commit: [858e7dbdedcb5d85d0e3b84323c5a6bfe6bd3b5e]
In host_det.sh, the code lines between 6~381 are all functions, till line 381. 
	if [ $(which lsb_release) ] ; then
	         info "Detected build host [`lsb_release -sd`]"
Following is the lsb_relase result, lsb_release is the linux standard base base package, which will provide enough infomations of the installed linux system. 
	$ lsb_release
	LSB Version:	:core-3.1-ia32:core-3.1-noarch:graphics-3.1-ia32:graphics-3.1-noarch
	[Tomcat@MisteryPlace:  [] /opt/home/Tomcat]                                                                                        $ lsb_release -sd
	"Scientific Linux SL release 5.5 (Boron)"
	[Tomcat@MisteryPlace:  [] /opt/home/Tomcat]                                                                                        $ uname -m
	i686

```
Testing the host and the git head commit

```
	info "host: [`uname -m`]"
	info "git HEAD commit: [`git rev-parse HEAD`]"

```
This script is for testing the known hosts which runs redhat/debian/suse, and verify if you have installed all of the package need to support kernel build.     

Copy the system.sh.sample to current directory

```
if [ ! -f ${DIR}/system.sh ] ; then
	cp ${DIR}/system.sh.sample ${DIR}/system.sh

```
Next lines from 199 to 218 is to detect if the branches.list and branch.expired exists, if exists then some testing will be done.

```
	if [ -f "${DIR}/branches.list" ] ; then
		echo "-----------------------------"
		echo "Please checkout one of the active branches:"
		echo "-----------------------------"
		cat ${DIR}/branches.list | grep -v INACTIVE
		echo "-----------------------------"
		exit
	fi

```
Then go to line 220 and 221, unset 2 system variable

```
	unset CC
	unset LINUX_GIT

```
Then run system.sh

```
	. ${DIR}/system.sh

```
Then we will prepare the gcc.

```
	/bin/sh -e "${DIR}/scripts/gcc.sh" || { exit 1 ; }
Switching to scripts/gcc.sh, the following lines will set the system variables, which will be used to choose the suitable linaro toolchain. 
	. ${DIR}/system.sh
	
	#For:
	#linaro_toolchain
	. ${DIR}/version.sh
Test the CC existence, if not then start building:
	if [ "x${CC}" = "x" ] && [ "x${ARCH}" != "xarmv7l" ] ; then
		gcc_linaro_toolchain
	fi

```
The code are funny, because echo x${CC} is actually x , so the gcc_linaro_toolchain will surely be called.     

```
	$ echo ${linaro_toolchain}
	cortex_gcc_4_8

```
The variable {linaro_toolchain} is set via . version.sh, then the corresponding code lines will be called

```sh gcc.sh
		cortex_gcc_4_8)
			#https://launchpad.net/linaro-toolchain-binaries/+download
			#https://launchpad.net/linaro-toolchain-binaries/trunk/2013.10/+download/gcc-linaro-arm-linux-gnueabihf-4.8-2013.10_linux.tar.xz
	
			gcc_version="4.8"
			release="2013.10"
			toolchain_name="gcc-linaro-arm-linux-gnueabihf"
			site="https://launchpad.net/linaro-toolchain-binaries"
			version="trunk/${release}"
			directory="${toolchain_name}-${gcc_version}-${release}_linux"
			filename="${directory}.tar.xz"
			datestamp="${release}-${toolchain_name}"
			untar="tar -xJf"
	
			binary="bin/arm-linux-gnueabihf-"
			;;
		*)
			echo "bug: maintainer forgot to set:"
			echo "linaro_toolchain=\"xzy\" in version.sh"
			exit 1
			;;

```	
dl_gcc_generic will be called. download the corresponding packages from the linaro website.    

After set the cross-compiler, we can get the kernel using git.sh, the git.sh is listed in scripts/git.sh

```
	/bin/sh -e "${DIR}/scripts/git.sh" || { exit 1 ; }

```
In git.sh, detect the user's email and user's name:

```sh git.sh
	unset git_config_user_email
	git_config_user_email=$(git config --get user.email || true)
	
	unset git_config_user_name
	git_config_user_name=$(git config --get user.name || true)

```
Then set using http or git, call git_kernel to git clone the corresponding resources from github.    
git_kernel will call check_and_or_clone() to get the source code from the github.     

```
	git clone ${torvalds_linux} ${DIR}/ignore/linux-src

```
and set the LINUX_GIT variable to 

```
	LINUX_GIT="${DIR}/ignore/linux-src"

```
The downloaded packages are so large, that it occupies 1.4G disk space. 

```
	[Trusty@XXXyyy ignore]$ du -hs *
	1.4G	linux-src

```

