---
layout: post
title: "Glusterfs Howto"
date: 2015-04-17 14:18
comments: true
categories: storage
---
I want to expand my storage size on DigitalOcean, the droplet I have on DO one have 11G, and the other have 15G size, so if I could combine them together, I could do much more development on it. Following is how-to.     
### Glusterfs Setup
Install it under Ubuntu via:    

```
# apt-get install glusterfs-server

```
In both node, install the same software, and then add following lines into your /etc/hosts:    

```
10.17.17.195    Gluster2
10.17.17.194    Gluster1

```
In Gluster1, probe Gluster2:    

```
root@Gluster1:~# gluster peer probe Gluster2
peer probe: success

```
Then view the gluster peer status:    

```
root@Gluster1:~# gluster peer status
Number of Peers: 1

Hostname: Gluster2
Port: 24007
Uuid: 881dedb8-6cd4-4127-8c96-223daef081f5
State: Peer in Cluster (Connected)

```
Create the volumn via:    

```
root@Gluster1:~# gluster volume create vol_replica transport tcp Gluster2:/home/glustervms Gluster1:/home/glustervms force
volume create: vol_replica: success: please start the volume to access data

```
Start the created vol:    

```
root@Gluster1:~# gluster volume start vol_replica
volume start: vol_replica: success

```
View volumn info:    

```
root@Gluster1:~# gluster volume info 
 
Volume Name: vol_replica
Type: Distribute
Volume ID: 953456f3-0c46-4d07-ac41-591d1e398be6
Status: Started
Number of Bricks: 2
Transport-type: tcp
Bricks:
Brick1: Gluster2:/home/glustervms
Brick2: Gluster1:/home/glustervms

```
Now create the folder and mount the glusterfs via:    

```
root@Gluster1:/home# mkdir glustervmsmnt
root@Gluster1:/home# mount -t glusterfs Gluster1:/vol_replica /home/glustervmsmnt/

```
View the disk filesystem info:    

```
Gluster1:/vol_replica   39G  4.7G   32G  13% /home/glustervmsmnt

```
### Glusterfs Volumn deletion
The replica is not the one we want, for combine two partitions, I need the Distributed stripped mode, which is the one described in:     
[http://www.gluster.org/community/documentation/index.php/Gluster_3.2:_Creating_Distributed_Striped_Volumes](http://www.gluster.org/community/documentation/index.php/Gluster_3.2:_Creating_Distributed_Striped_Volumes)      
So first I have to delete the one I've created in the above part.   
First umount the one I've created:    

```
root@Gluster1:/home/glustervms# umount /home/glustervmsmnt 

```
checked via `mount` or `df -h` we could see the one we have mounted has been umounted.     

Second, stop the volumes we've created:    

```
root@Gluster1:/home/glustervms# gluster volume stop vol_replica
Stopping volume will make its data inaccessible. Do you want to continue? (y/n) y
volume stop: vol_replica: success

```
Third, delete volumn:    

```
root@Gluster1:/home/glustervms# gluster volume delete vol_replica
Deleting volume will erase all information about the volume. Do you want to continue? (y/n) y
volume delete: vol_replica: success

```
Check the volume status:     

```
root@Gluster1:/home/glustervms# gluster volume info
No volumes present

```
### Create the distributed stripped volume
Create the bigvolume:    

```	
root@Gluster1:/home/glustervms# gluster volume create bigvolume transport tcp Gluster2:/home/glustervms Gluster1:/home/glustervms force

```
Start the volume:     

```
root@Gluster1:/home/glustervms# gluster volume start bigvolume
volume start: bigvolume: success

```
View the status of the volume:     

```
root@Gluster1:/home/glustervmsmnt# gluster volume info 
 
Volume Name: bigvolume
Type: Distribute
Volume ID: 3e09f074-4675-46d3-873f-f00ef13fb509
Status: Started
Number of Bricks: 2
Transport-type: tcp
Bricks:
Brick1: Gluster2:/home/glustervms
Brick2: Gluster1:/home/glustervms

```
Mount it via following command:     

```
# mount -t glusterfs Gluster1:/bigvolume /home/glustervmsmnt/

```

### Trouble-Shooting

```
root@Gluster1:/home/glustervms# gluster volume create bigvolume transport tcp Gluster2:/home/glustervms Gluster1:/home/glustervms force
volume create: bigvolume: failed: /home/glustervms or a prefix of it is already part of a volume

```
Resolve it via:     

```
#  apt-get install attr
#  setfattr -x trusted.glusterfs.volume-id /home/glustervms
#  setfattr -x trusted.gfid /home/glustervms
#  rm -rf /home/glustervms/.glusterfs/

```
Re-run the gluster volome create command it will create the volume which combines two folders.    

### Digital Ocean Scenario
My DO droplet runs Ubuntu and CentOS, their version is Trusty(14.04) and CentOS7, so do following:    

```
CentOS # wget -P /etc/yum.repos.d http://download.gluster.org/pub/gluster/glusterfs/LATEST/CentOS/glusterfs-epel.repo
CentOS # yum -y install glusterfs glusterfs-fuse glusterfs-server
CentOS # systemctl start glusterd
CentOS # systemctl enable glusterd
Trusty # apt-get install glusterfs-server

```
Add each other's name and ip address into /etc/hosts, make sure they could ping each other and get responsible:    

```
1xx.xx.xxx.xxx	CentOS
1xx.xx.xxx.xx	Trusty

```
Use Trusty as the server, so on the Trusty machine, detect the CentOS's glusterd configuration as:     

```
Trusty # gluster peer probe CentOS
peer probe: success

```
Check the status:    

```
Trusty # gluster peer status
Number of Peers: 1

Hostname: CentOS
Port: 24007
Uuid: xxxxxxxx
State: Peer in Cluster (Connected)

```
Create the bigvolume, and mount it into your own directory via:     

```
Trusty # gluster volume create bigvolume transport tcp CentOS:/home/glustervms Trusty:/home/glustervms force
volume create: bigvolume: success: please start the volume to access data
Trusty # gluster volume start bigvolume
volume start: bigvolume: success
Trusty # gluster volume info
 
Volume Name: bigvolume
Type: Distribute
Volume ID: xxxxxxxxxxxxxxxxxxxxx
Status: Started
Number of Bricks: 2
Transport-type: tcp
Bricks:
Brick1: CentOS:/home/glustervms
Brick2: Trusty:/home/glustervms
Trusty # mkdir /home/glustervmsmnt/
Trusty # mount -t glusterfs Trusty:/bigvolume /home/glustervmsmnt/
Trusty # df -h
Filesystem              Size  Used Avail Use% Mounted on
/dev/vda1                20G  9.4G  9.2G  51% /
none                    4.0K     0  4.0K   0% /sys/fs/cgroup
udev                    235M  8.0K  235M   1% /dev
tmpfs                    50M  396K   49M   1% /run
none                    5.0M     0  5.0M   0% /run/lock
none                    246M  1.1M  244M   1% /run/shm
none                    100M     0  100M   0% /run/user
Trusty:/bigvolume       40G   14G   24G  37% /home/glustervmsmnt

```
Now you could operate under the /home/glustervmsmnt and you have 24G size partion of the disk. Enjoy them!!! 
### Trouble-Shooting 1
If you met `File change as we read it` in tar something, do following things:    

```
Trusty # gluster volume set bigvolume performance.stat-prefetch off
volume set: success

```
