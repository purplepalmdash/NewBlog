---
layout: post
title: "Preseed Partition Configuration"
date: 2015-08-13 21:55:00 +0800
comments: true
categories: 
---
### Regular Partition

Use regular configuration of the partion:    

```
d-i partman-auto/disk string /dev/vda
d-i partman-auto/method string regular
d-i partman-auto/choose_recipe \
       select All files in one partition (recommended for new users)
d-i partman/confirm_write_new_label boolean true
#
d-i partman/choose_partition \
       select Finish partitioning and write changes to disk
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true

```

