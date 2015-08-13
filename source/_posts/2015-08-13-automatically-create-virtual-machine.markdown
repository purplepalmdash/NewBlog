---
layout: post
title: "Automatically Create Virtual Machine"
date: 2015-08-13 16:21:23 +0800
comments: true
categories: Virtualization
---
Just record the whole scripts for create/define/start the vm machine.    

```
#!/bin/sh
# $1: The name of the virtual machine. 

### 1. Check Input Parameters. 
if [ $# != 1 ]
then
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo "!!         Parameters error       !!"
  echo "!! Example: ./createvm.sh name    !!"
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  exit 1
fi

### 2. Create the qcow2 file in local directory. 
echo $1
qemu-img create -f qcow2 -b /home/juju/img/WolfHunter/SpaceWalk/Base/packer-ubuntu-1204-server-i386 $1.qcow2

### 3. Generate Random MAC Address.
printf -v macaddr "52:54:%02x:%02x:%02x:%02x" $(( $RANDOM & 0xff)) $(( $RANDOM & 0xff )) $(( $RANDOM & 0xff)) $(( $RANDOM & 0xff ))
# echo $macaddr
### 3.1 Check whether this MAC Address is in the host's existing items. 
declare maclist

### 3.2 Get the MAC Address List
for vm in $(virsh list --all | tail -n +3 |  awk '{print $2}')
do
        # Multiple NIC need this. 
    for mac_item in $(virsh dumpxml $vm | grep "mac address" | awk -F "'" '{print $2}')
                do
                        # echo $mac_item
                        maclist+=($mac_item)
                done
done

# echo ${maclist[*]} 
# echo ${#maclist[@]}

### 3.3 Processing possible duplicated problem. 
### We don't hope the generate random mac address to be duplicated, so write whatever you want to see under the while loop for debugging
### Judge if the generated random mac address duplicated. 
while [[ ${maclist[*]} =~ ${macaddr} ]]
do
        echo "yes, you entered while for changing the mac address!"
        printf -v macaddr "52:54:%02x:%02x:%02x:%02x" $(( $RANDOM & 0xff)) $(( $RANDOM & 0xff )) $(( $RANDOM & 0xff)) $(( $RANDOM & 0xff ))
        echo $macaddr
done

### 3.4 Only for debugging purpose, view result
### For debugging purpose
### if [[ ${maclist[*]} =~ ${macaddr} ]]
### then
###     echo "Yes, it's in the existing mac list"
### else
###     echo "Congratulations, it's safe to use this mac!"
### fi
### echo $macaddr

### 4. Create new xml file and modify the xml file.
### 4.1 Create the file
mkdir -p xml
cp ./Template.xml ./xml/$1.xml
### 4.2 Remove the uuid(Virt-manager will automatically generate it)
sed -i '/uuid/d' ./xml/$1.xml
### 4.3 Replace the MAC Address
sed -i -r "s/(.*)([a-zA-Z0-9]{2}:[a-zA-Z0-9]{2}:[a-zA-Z0-9]{2}:[a-zA-Z0-9]{2}:[a-zA-Z0-9]{2}:[a-zA-Z0-9]{2})(.*)/\1$macaddr\3/g" ./xml/$1.xml 
### 4.4 Replace the virt disk file
imagepath=($PWD/$1.qcow2)
echo $imagepath
sed -i "s#<source file.*#<source file='$imagepath'/>#g"  ./xml/$1.xml

### 5. Change the VM Name
sed -i "s#<name.*#<name>$1</name>#g" ./xml/$1.xml

### 6. Define and Start VM Machine
virsh define $PWD/xml/$1.xml
virsh start $1

```

Steps for create the machine:    

```
# ./createvm.sh zz_bee1
```
