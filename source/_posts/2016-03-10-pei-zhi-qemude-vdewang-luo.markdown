---
layout: post
title: "配置Qemu的VDE网络"
date: 2016-03-10 14:18:43 +0800
comments: true
categories: Linux
---
为了快速验证镜像，配置出一个在本机上的tap0端口，虚拟机则通过VDE虚拟交换机连接到此端口后
，DHCP获得IP地址，从而得到网络连接， 以下是步骤。    
### 安装VDE
ArchLinux下安装命令为`sudo pacman -S vde2`.    

### 配置
贴出配置文件如下, 摘录自ArchLinux的Wiki. 值得注意的是，在Systemd的配置文件中，需要先把
tun驱动装载上，才能使得VDE启动成功。    

配置qemu网络环境配置脚本:    

```sh
$ vim /etc/systemd/scripts/qemu-network-env 
#!/bin/sh
# QEMU/VDE network environment preparation script

# The IP configuration for the tap device that will be used for
# the virtual machine network:

TAP_DEV=tap0
TAP_IP=10.33.34.254
TAP_MASK=24
TAP_NETWORK=10.33.34.0

# Host interface
NIC=enp2s0

case "$1" in
  start)
        echo -n "Starting VDE network for QEMU: "

        # If you want tun kernel module to be loaded by script uncomment here
        modprobe tun 2>/dev/null
        # Wait for the module to be loaded
        while ! lsmod | grep -q "^tun"; do echo "Waiting for tun device"; sleep 1; done

        # Start tap switch
        vde_switch -tap "$TAP_DEV" -daemon -mod 660 -group users

        # Bring tap interface up
        ip address add "$TAP_IP"/"$TAP_MASK" dev "$TAP_DEV"
        ip link set "$TAP_DEV" up

        # Start IP Forwarding
        echo "1" > /proc/sys/net/ipv4/ip_forward
        iptables -t nat -A POSTROUTING -s "$TAP_NETWORK"/"$TAP_MASK" -o "$NIC" -j MASQUERADE
        ;;
  stop)
        echo -n "Stopping VDE network for QEMU: "
        # Delete the NAT rules
        iptables -t nat -D POSTROUTING "$TAP_NETWORK"/"$TAP_MASK" -o "$NIC" -j MASQUERADE

        # Bring tap interface down
        ip link set "$TAP_DEV" down

        # Kill VDE switch
        pgrep -f vde_switch | xargs kill -TERM
        ;;
  restart|reload)
        $0 stop
        sleep 1
        $0 start
        ;;
  *)
        echo "Usage: $0 {start|stop|restart|reload}"
        exit 1
esac
exit 0
``` 
配置symtemd服务:    

```sh
$ vim /etc/systemd/system/qemu-network-env.service
[Unit]
Description=Manage VDE Switch

[Service]
Type=oneshot
ExecStart=/etc/systemd/scripts/qemu-network-env start
ExecStop=/etc/systemd/scripts/qemu-network-env stop
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

使能服务，并重新启动机器:     

```
$ sudo systemctl enable qemu-network-env.service
```

### 配置DHCPD
需要配置dhcpd以使得在`10.33.34.0/24`网段提供DHCP服务：     

```
$ sudo vim /etc/dhcpd.conf

subnet
10.33.34.0 netmask 255.255.255.0 {
# --- default gateway
option routers
10.33.34.254;
# --- Netmask
option subnet-mask
255.255.255.0;
# --- Broadcast Address
option broadcast-address
10.33.34.255;
# --- Domain name servers, tells the clients which DNS servers to use.
option domain-name-servers
223.5.5.5,180.76.76.76;
option time-offset 0;
range 10.33.34.2 10.33.34.253;
default-lease-time 1209600;
max-lease-time 1814400;
}
```
修改完dhcpd的配置后， 重新启动dhcpd服务:     

```
$ sudo systemctl restart dhcpd4
```

### 启动虚拟机
启动虚拟机，并使其使用我们刚才添加的vde网络:     

```
$ sudo qemu-system-x86_64 -net nic -net vde -hda ./test1.qcow2 -m 2048 --enable-kvm
```
启动的虚拟机将获得10.33.34.2~10.33.33.253之间的地址。      
如果使用普通用户，会出错， To be solved.     
