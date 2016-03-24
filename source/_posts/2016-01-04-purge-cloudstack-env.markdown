---
layout: post
title: "Purge CloudStack Env"
date: 2016-01-04 16:26:30 +0800
comments: true
categories: Virtualization
---
For totally reset the configured cloudstack environment, do following commands:    

```
# service cloudstack-management stop
# mysql -pengine123 -e 'drop database cloud'
# mysql -pengine123 -e 'drop database cloud_usage'
# cloudstack-setup-databases cloud:engine123@localhost --deploy-as=root:engine123
# rm -rf /var/log/cloud/management/*
# cloudstack-setup-management 
# service cloudstack-management start
```

