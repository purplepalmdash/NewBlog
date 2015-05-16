---
layout: post
title: "Fuel Build Issues"
date: 2015-04-15 14:07
comments: true
categories: virtualization
---
I started to deploy OpenContrail use fuel, so following are some tips for building the plugins.     
### Fule-Plugin-Builder
I encounter following errors when building the plugins of the contrail:    

```
# fuel-plugin-builder --build ./
Unexpected error
Wrong package version "2.0.0"

```
This is because the FPB on PyPI is too old for building the 2.0.0 version of the fuel-plugins.    
Work-around is we manually create the fpb via following steps:    

```
# git clone https://github.com/stackforge/fuel-plugins
# cd fuel-plugins/fuel_plugin_builder
# python setup.py sdist
# pip install dist/fuel-plugin-builder-2.0.0.dev.tar.gz

```
Now your fpb could build 2.0.0 version of the packages.      
### Build Fuel Contrail plugin
First we install following packages on Ubuntu.    

```
# sudo apt-get install createrepo rpm dpkg-dev
# easy_install pip
# pip install fuel-plugin-builder

```
But notice the fuel-plugin-builder is too old in pip repository, so use the git version instead.     
Or in CentOS, you could install fuel-plugin-build via:    

```
# yum install createrepo rpm dpkg-devel
# pip install fuel-plugin-builder

```
Retrive the source code and build it via:    

```
# git clone https://github.com/stackforge/fuel-plugin-contrail
# cd fuel-plugin-contrail/
# fpb --build . --debug
[root:/home/juju/Code/fuel-plugin-contrail]# ls
contrail-1.0-1.0.0-0.noarch.rpm  LICENSE         repositories
deployment_scripts               metadata.yaml   specs
environment_config.yaml          pre_build_hook  tasks.yaml
install.sh                       README.md

```
Once the contrail-1.0xxxx.rpm is available it indicates the plugin is available for fuel to use.     
Notice this plugin should be compatible for Mirantis Fuel 6.1 and Juniper Contrail 2.01.    
