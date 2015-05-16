---
layout: post
title: "Install OpenVPN in RaspberryPI"
date: 2014-10-21 20:35
comments: true
categories: Linux
---
### Packages
Raspberry PI runs ArchLinux, first install related packages.   

```
$ sudo pacman -S openvpn
$ sudo pacman -S easy-rsa
$ sudo pacman -S dnsmasq

```
openvpn is the OpenVPN's Kernel.    
easy-rsa is used for manage the keys.    
dnsmasq will acts like the domain name server.   
### Configuration
First Make the directory and copy the easy-rsa's files:   

```
# mkdir /etc/openvpn/easy-rsa
[root@alarmpi ~]#  cp -r /usr/share/easy-rsa/* /etc/openvpn/easy-rsa
[root@alarmpi ~]# ls /etc/openvpn/easy-rsa/
build-ca	build-key-pkcs12  inherit-inter      sign-req
build-dh	build-key-server  list-crl	     vars
build-inter	build-req	  openssl-1.0.0.cnf  whichopensslcnf
build-key	build-req-pass	  pkitool
build-key-pass	clean-all	  revoke-full

```
Now go and run easy-rsa:    

```
[root@alarmpi ~]# cd /etc/openvpn/easy-rsa/
[root@alarmpi easy-rsa]# source vars
NOTE: If you run ./clean-all, I will be doing a rm -rf on /etc/openvpn/easy-rsa/keys
[root@alarmpi easy-rsa]# ./clean-all 
[root@alarmpi easy-rsa]# ./build-ca


```

### Generate the keys and certifications
My name is `Trusty_delta`.    

```
[root@alarmpi easy-rsa]# sh build-key-server Trusty_delta
[root@alarmpi easy-rsa]# ls keys/Trusty_*
keys/Trusty_delta.crt  keys/Trusty_delta.csr  keys/Trusty_delta.key

```
### Diffie-Hellman Parameters
This may takes extremely long time, especially on RaspberryPI, OMG.......

```
[root@alarmpi easy-rsa]# sh build-dh 
# cd keys
# cp ca.crt delta.crt delta.key dh2048.pem /etc/openvpn
# cd ..

```
### Generate the private key

```
# source vars
NOTE:If you run ./clean-all, I will be doing a rm -rf on /etc/openvpn/easy-rsa/keys
root@delta:/etc/openvpn/easy-rsa# ./build-key laptop
Generating a 1024 bit RSA private key

```
The private key called "laptop" then we could make a directory for holding private keys and copy them into that directory.    

```
# mkdir ~/ovpn-client
# cp ca.crt laptop.crt laptop.key ~/ovpn-client

```
If you develier these 3 files to client, client could use them for connecting your VPN server.    
### OpenVPN Server
Copy the server.conf file into /etc/openvpn/:    

```
# cd /usr/share/openvpn/examples/
# cp server.conf /etc/openvpn/Trusty_delta.conf
# vim Trusty_delta.conf
cert delta.crt
key delta.key
dh dh2048.pem
push "redirect-gateway def1"
push "dhcp-option DNS 172.8.0.1"

```

Make service start automatically:    

```
# systemctl start openvpn@Trusty_delta.conf
# systemctl enable openvpn@Trusty_delta.conf

```
Then we could test the vpn in other linux servers, using modified client.conf file.    
### Check service
Use netstat for check the status of openvpn server:    

```
netstat -anp| grep openvpn

```

Following is directly copy from the ubuntu related. 
### DNS Server
Edit the dnsmasq.conf:   

```
listen-address = 127.0.0.1, 172.8.0.1
bind-interfaces

```
Then restart the dnsmasq.  
 
