---
layout: post
title: "Tips On Cloud-Init And CloudStack"
date: 2015-10-13 16:22:16 +0800
comments: true
categories: Virtualization
---
### CloudStack VR VM
For accessing the VR VM and view the user-data and meta-data, like following, on the
instance ssh, you could get the user-data and meta-data:    

```
[root@testfuck ~]# curl http://10.1.1.1/latest/user-data
[root@testfuck ~]# curl http://10.1.1.1/latest/meta-data
service-offering
availability-zone
local-ipv4
local-hostname
public-ipv4
public-hostname
instance-id
vm-id
public-keys
cloud-identifier
# curl http://10.1.1.1/latest/meta-data/vm-id
c6e1165e-f19a-4c77-9d96-dfd48f8ce944
```

user-data could not be fetched directly, you could only manage it via cloud-monkey when
deploying the VMs.    

### user-data Simple Example
Before user-data injected:    

```
Login Using password:   

root@r-9-VM:~# ssh root@10.1.1.162
root@10.1.1.162's password: 

[root@testfuck etc]# date +%Z
BST
[root@testfuck etc]# cat /etc/sysconfig/clock 
ZONE="Europe/London"
```

But We want to change! First let VR VM could directly login to the instance, second, we
change the timezone into Asia/Chongqing.    

Generate the user-data:    

```
$ cat hello_world.sh
#!/bin/bash
echo "hello world!" >> /root/test
$ cat my-user-data
#cloud-config
growpart:
  mode: auto
chpasswd: { expire: False }
ssh_pwauth: True

ssh_authorized_keys:
 - ssh-rsa xxxxxxxxxxxxxxxxxxxxxxxx

timezone: Asia/Chongqing
$ $ write-mime-multipart --output=combined-userdata.txt \ 
hello_world.sh:text/x-shellscript my-user-data
$ ls -l -h combined-userdata.txt 
-rw-rw-r-- 1 dash dash 1.1K Oct 13 17:14 combined-userdata.txt
$ cat combined-userdata.txt | base64
```

Deploy via:    

```
cloudmonkey deploy virtualmachine
serviceofferingid=683f31f8-a939-468e-b4de-4512a8ccff8e
templateid=13fb2961-533e-4a7d-80f9-21d860269aad
zoneid=78509dc3-c828-429c-8154-9fffbc09384c
networkids=7c6e7e6b-6aa2-4f95-a835-8d18bf930061 name=testuserdata
userdata='Q29udGVudC1UeXBlOiBtdWx0aXBhcnQvbWl4ZWQ7IGJvdW5kYXJ5PSI9PT09PT09PT09PT09PT0xOTk5MDU5OTcyMjA5ODg1MjY2PT0iCk1JTUUtVmVyc2lvbjogMS4wCgotLT09PT09PT09PT09PT09PTE5OTkwNTk5NzIyMDk4ODUyNjY9PQpDb250ZW50LVR5cGU6IHRleHQveC1zaGVsbHNjcmlwdDsgY2hhcnNldD0idXMtYXNjaWkiCk1JTUUtVmVyc2lvbjogMS4wCkNvbnRlbnQtVHJhbnNmZXItRW5jb2Rpbmc6IDdiaXQKQ29udGVudC1EaXNwb3NpdGlvbjogYXR0YWNobWVudDsgZmlsZW5hbWU9ImhlbGxvX3dvcmxkLnNoIgoKIyEvYmluL2Jhc2gKZWNobyAiaGVsbG8gd29ybGQhIiA+PiAvcm9vdC90ZXN0CgotLT09PT09PT09PT09PT09PTE5OTkwNTk5NzIyMDk4ODUyNjY9PQpDb250ZW50LVR5cGU6IHRleHQvY2xvdWQtY29uZmlnOyBjaGFyc2V0PSJ1cy1hc2NpaSIKTUlNRS1WZXJzaW9uOiAxLjAKQ29udGVudC1UcmFuc2Zlci1FbmNvZGluZzogN2JpdApDb250ZW50LURpc3Bvc2l0aW9uOiBhdHRhY2htZW50OyBmaWxlbmFtZT0ibXktdXNlci1kYXRhIgoKI2Nsb3VkLWNvbmZpZwpncm93cGFydDoKICBtb2RlOiBhdXRvCmNocGFzc3dkOiB7IGV4cGlyZTogRmFsc2UgfQpzc2hfcHdhdXRoOiBUcnVlCgpzc2hfYXV0aG9yaXplZF9rZXlzOgogLSBzc2gtcnNhIEFBQUFCM056YUMxeWMyRUFBQUFEQVFBQkFBQUJBUUNzMFA4aFNCM05qN2tmd2lRT01PQ0Z2RXVqd3JLZjVuUFdmdzdzbmplVzd3TnhCYi9pTHhqbGxIK0tJdjdpS0dRaGI5WGtpZ3dXelhjdktSRk9OQTF0UU5CUHBsUE9RQXhHYUpoYzcxYlhZTVRabWsxcmZ5L0U4bUZIQmJ3U0trdm04Z3oxaFVqQWFITHdiZ21iaUE3eUNDUkVXbVR1SWpudm1FZnJXYU92WERRZFFPb2RkSzFhZThKM3BnRUNtQ21mRldrQmR3Y1JaN05jTUxBSkVkYTNpYWtJbWdaR2NqTWNCc1hjUUNOcjN1RGlKbERvc1V6Mjg4L3grTnZteTlzcHZnc2x4RXVUV0VQWFRGY1l5eVBrUHdkTnlpQm5TaWFoZTExcUdUZkk0Z2IyWllEb3JDZU5Ca1QxdkVaY0psL1JqT3NKRUFXT04rbno3Nm16MmdhZCByb290QHItOS1WTSAKCnRpbWV6b25lOiBBc2lhL0Nob25ncWluZwoKLS09PT09PT09PT09PT09PT0xOTk5MDU5OTcyMjA5ODg1MjY2PT0tLQo='
```

### Cloudmonkey
Get the Key Steps:    

![/images/2015_10_14_09_54_16_704x205.jpg](/images/2015_10_14_09_54_16_704x205.jpg)    

Click "Admin", and Click "View User":    

![/images/2015_10_14_10_02_28_706x328.jpg](/images/2015_10_14_10_02_28_706x328.jpg)    

Generate the keys:   

![/images/2015_10_14_10_05_07_676x341.jpg](/images/2015_10_14_10_05_07_676x341.jpg)    

View the generated keys:    

![/images/2015_10_14_10_08_43_408x419.jpg](/images/2015_10_14_10_08_43_408x419.jpg)    

Configure the Cloudmonkey:   

```
(local) mycloudmonkey> set history_file /usr/share/cloudmonkey_history
(local) mycloudmonkey> set log_file /var/log/cloudmonkey               
(local) mycloudmonkey> set host 10.100.168.2                           
This option has been deprecated, please set 'url' instead              
This server url will be used: http://10.100.168.2:8080/client/api      
(local) mycloudmonkey> set url http://localhost:8080/client/api     
(local) mycloudmonkey> set apikey
fIcD-UNUmfJG_B0oFOiVLNitFJxC7UM3ZyjlOdDUijJ4mJEgjjNQjULMQHhm69QP9IKUOiIX41-B2p1ebxhHdA                      
(local) mycloudmonkey> set secretkey
s4rubpT6rR3sjMDs9LALe21puxO0GxG5-KKsLoHLy3sn7uQDiUs01BGbS4cT6BZ3FtKVPRey5ersJ4iXH7saag                   
(local) mycloudmonkey> set prompt mycloudmonkey
(local) mycloudmonkey> sync
```

Now run the deploy command, you could get the VM runs as the cloud-init will enlarge
the partition into the largest amount.   

