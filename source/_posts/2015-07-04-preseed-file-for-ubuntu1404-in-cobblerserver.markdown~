---
layout: post
title: "Preseed File For Ubuntu1404 In CobblerServer"
date: 2015-07-04 14:57:00 +0800
comments: true
categories: Virtualization
---
### Proseed File

```
d-i time/zone string Asia/Shanghai

# Setup the installation source
d-i mirror/country string manual
d-i mirror/http/hostname string $http_server
#d-i mirror/http/directory string $install_source_directory
d-i mirror/http/directory string /cobbler/ks_mirror/Ubuntu-14.04-x86_64/ubuntu
d-i mirror/http/proxy string
d-i apt-setup/security_host string $http_server
d-i apt-setup/security_path string /cobbler/ks_mirror/Ubuntu-14.04-x86_64/ubuntu
```

### Local Repository
In one installed machine, do following for getting the repository of all of the installed packages:    

```
$ sudo apt-get install dselect
$ dpkg --get-selections | grep -v deinstall>InstalledPackage.txt
$ awk {'print $1'} InstalledPackage.txt | xargs apt-get download
```

Use nginx for sharing the repository:    

```
$ sudo apt-get install -y nginx
$ sudo vim /etc/nginx/site-enabled/default
server {
        listen 80 default_server;
        listen [::]:80 default_server ipv6only=on;

        root /var/www/html;
        index index.html index.htm;

        # Make site accessible from http://localhost/
        server_name localhost;

        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                try_files $uri $uri/ =404;
                autoindex on;
                # Uncomment to enable naxsi on this location
$ sudo service nginx restart
```
Now generate the repository server:    

```
$ mkdir -p /var/www/html/amd64
$ mv /root/Code/*.deb /var/www/html/amd64
$ cd /var/www/html/
$ dpkg-scanpackages amd64/ | gzip -9c > amd64/Packages.gz
$ mv /root/Code/InstalledPackage.txt /var/www/html
```

### Use Local Repository
Change the repoisoty setting:    

```
root@Ubuntu-14:~# cat /etc/apt/sources.list
deb http://192.168.1.111 amd64/
root@Ubuntu-14:~# apt-get update &&  apt-get install -y dselect
root@Ubuntu-14:~# dselect update
root@Ubuntu-14:~# wget http://192.168.1.11/InstalledPackage.txt
root@Ubuntu-14:~# dpkg --set-selections < InstalledPackage.txt && apt-get -u dselect-upgrade 
```

After updating, you have the same system as your server.   
