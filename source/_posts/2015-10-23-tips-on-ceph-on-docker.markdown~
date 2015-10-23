---
layout: post
title: "Tips On Ceph On Docker"
date: 2015-10-23 22:32:17 +0800
comments: true
categories: Virtualization
---
### Installation
Pull the docker image via:    

```
$ sudo docker pull ceph/demo
```

### Run Ceph
Run the container via:   

```
# sudo docker run -d --net=host -e MON_IP=192.168.10.190 -e CEPH_NETWORK=192.168.10.0/24
ceph/demo
```

View the docker instance via:    

```
# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
cbe567594adb        ceph/demo           "/entrypoint.sh"    About an hour ago   Up About an hour                        furious_hopper 
# docker exec -it cbe567594adb
```

### Ceph Operation
View the ceph processes:    

```
root@monitor:/# ps -ef | grep "ceph"                                                                                                                                 
root         1     0  0 13:16 ?        00:00:00 /usr/bin/python /usr/bin/ceph -w
root        32     1  0 13:16 ?        00:00:01 ceph-mon -i monitor --public-addr 192.168.10.190:6789
root       201     1  0 13:16 ?        00:00:06 ceph-osd -i 0 -k /var/lib/ceph/osd/ceph-0/keyring
root       412     1  0 13:16 ?        00:00:01 ceph-mds --cluster=ceph -i 0
root       470     1  0 13:16 ?        00:00:03 radosgw -c /etc/ceph/ceph.conf -n client.radosgw.gateway -k /var/lib/ceph/radosgw/monitor/keyring --rgw-socket-path= --rgw-frontends=civetweb port=80
root       473     1  0 13:16 ?        00:00:01 /usr/bin/python /usr/bin/ceph-rest-api -n client.admin
root      1703  1557  0 14:37 ?        00:00:00 grep --color=auto ceph
```

View Ceph Status:    

```
root@monitor:/# ceph -s
    cluster c3470b36-8d03-4dbb-8af4-d4353ea54973
     health HEALTH_OK
     monmap e1: 1 mons at {monitor=192.168.10.190:6789/0}
            election epoch 2, quorum 0 monitor
     mdsmap e5: 1/1/1 up {0=0=up:active}
     osdmap e22: 1 osds: 1 up, 1 in
      pgmap v75: 144 pgs, 11 pools, 6796 bytes data, 70 objects
            3789 MB used, 287 GB / 291 GB avail
                 144 active+clean
```

Create a new user:    

```
# radosgw-admin user create --uid="xxxx" --display-name="XXXX YYYY" --email=xxxyyy@gmail.com
```

Remember the output of the `access_key` and `secret_key`.    

###  Configure Ceph
Install softwares:    

```
# apt-get update -y
# apt-get install -y python
# apt-get install -y python-pip
# pip install boto
# pip install ipython
# pip install s3cmd
# apt-get install -y vim
```

Use the `list_buckets.py` file:    

```
# cat list_buckets.py
import boto
import boto.s3.connection

access_key =  '5S5YPYC46EVYG9MF0RSR'
secret_key = 'hEcgOMoNOp6jmYnt3G6qqJiT7mV5A8zBR9g6o38Z'

conn = boto.connect_s3(
        aws_access_key_id = access_key,
        aws_secret_access_key = secret_key,
        host = 'localhost',
        is_secure=False,
        calling_format = boto.s3.connection.OrdinaryCallingFormat(),
        )
```

In ipython, use following commands for create a new bucket:    

```
In [8]: conn.create_bucket("fuck")                                        
Out[8]: <Bucket: fuck>

In [9]: conn.get_all_buckets()                                                 
Out[9]: [<Bucket: fuck>]
```

Download the s3cfg file from :    

[https://github.com/tobegit3hub/.s3cfg/blob/master/.s3cfg](https://github.com/tobegit3hub/.s3cfg/blob/master/.s3cfg)    

Also configure its `access_key` and `secret_key`, save it in your root
directory, run following commands, you will see the buckets:    

```
# s3cmd ls                                                                                                                                             
2015-10-23 13:25  s3://fuck
```

### Mount Ceph In Linux
In Ubuntu machine, install ceph:    

```
$ sudo apt-get install ceph
```

Get the admin's password(In Ceph Container):    

```
# ceph-authtool --print-key /etc/ceph/ceph.client.admin.keyring 
AQAmMypWs06BGxAAQ1rQyFqFJ25xaDye4c9kyQ==
```

Now mount it via:    

```
$ sudo mount -t ceph 192.168.10.190:/ /mnt -o name=admin,secret=AQAmMypWs06BGxAAQ1rQyFqFJ25xaDye4c9kyQ==
$ sudo touch /mnt/abc
```

Via `ceph -s` we could see the `pgmap v86` changes, which indicates the data
has been written into the ceph.   
