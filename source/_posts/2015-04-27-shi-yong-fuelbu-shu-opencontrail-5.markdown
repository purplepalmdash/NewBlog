---
layout: post
title: "使用Fuel部署OpenContrail(5)"
date: 2015-04-27 21:55
comments: true
categories: Virtualization
---
本节主要用于配置OpenStack使用OpenContrail作为其网络配置器，主要涉及到OpenStack Controller和OpenStack Compute上的配置.     
### OpenStack Controller配置
!!! 以下的所有操作，需要在每个OpenStack Controller节点上进行！！！
OpenStack Controller不需要使用Private 网络，所以我们可以删除ifcfg-eth0文件:     

```
# rm -f /etc/network/interface.d/ifcfg-eth4
# service networking restart

```
为了保险，最好重启更改完网络后的节点。    
配置/etc/nova/nova.conf文件中的以下字段:     

```
# vim /etc/nova/nova.conf
[DEFAULT]
network_api_class = nova.network.neutronv2.api.API
neutron_url = http://10.77.77.9:9696
neutron_admin_tenant_name = services
neutron_admin_username = neutron
neutron_admin_password = rVlaAKUs
neutron_url_timeout = 300
neutron_admin_auth_url = http://10.55.55.4:35357/v2.0/
firewall_driver = nova.virt.firewall.NoopFirewallDriver
enabled_apis = ec2,osapi_compute,metadata
security_group_api = neutron
service_neutron_metadata_proxy = True

```
neutron_admin_password的值还是我们以前取得的admin token.   
更改完上述配置后，重启以下服务:     

```
# service nova-api restart
# service nova-scheduler restart
# service nova-conductor restart

``` 
在任一OpenStack Controller节点上，使用以下命令，在数据库中删除nova-network服务的定义。     

```
# source ~/openrc
# for i in $(nova service-list|grep nova-network|awk '{print $2}'); \
do nova service-delete $i;done

```
### Compute(计算)节点配置
!!! 以下操作，都应该在每个计算节点上运行 !!!!
在每个计算节点上，配置仓库:     

```
#  echo 'deb http://10.20.0.2:8080/contrail/ /' >/etc/apt/sources.list.d/contrail.list
# echo -e "Package: *\nPin: release l=Ubuntu\nPin-Priority: 100" > /etc/apt/preferences
# >/etc/apt/sources.list
# apt-get update

```
Contrail是不需要OpenVSwitch(OVS)的，所以我们要把它删除:     

```
# apt-get purge -y openvswitch-common openvswitch-datapath-lts-saucy-dkms \
openvswitch-switch nova-network nova-api

```
验证openvswitch是否被彻底删除(应该输出空行才对):     

```
# aptitude search -F '%p' '~i' | grep openvswitch

```
删除OVS的内核模块:     

```
# lsmod | grep openvswitch && rmmod openvswitch

```
移除virbr0端口:     

```
# virsh net-destroy default
# virsh net-undefine default

```
确保在所有节点的/etc/network/interface.d/下，只包括了ifcfg-eth0, ifcfg-eth4, 其他都需要被删除。     
重启所有OpenStack Compute节点，以删除所有openvswitch和nova-network相关的iptables规则、接口等。    

```
# reboot 

```
重启以后，以下面的命令确保没有NAT规则存在:     

```
# iptables -L -t nat

```
在所有的Compute节点上，安装Contrail vrouter 组件:    

```
# apt-get install -y contrail-openstack-vrouter

```
所有节点上，配置vhost0和ifcfg-eth4:     

```
root@node-18:~# vim /etc/network/interfaces.d/ifcfg-vhost0 
auto vhost0
iface vhost0 inet static
    netmask 255.255.255.0
    network_name application
    address 10.77.77.15
    gateway 10.77.77.1
    mtu 1300
root@node-18:~# vim /etc/network/interfaces.d/ifcfg-eth4 
auto eth4
iface eth4 inet manual

up ip l set eth4 up
down ip l set eth4 down

post-up  ethtool  -K  eth4  gso off  gro off || true

```
创建agent_param文件:    

```
# mv /etc/contrail/agent_param.tmpl /etc/contrail/agent_param
# vim /etc/contrail/agent_param
dev=eth4

```
设置vroute-agent配置:      

```
# vim /etc/contrail/contrail-vrouter-agent.conf
[DEFAULT]
headless_mode=true
[DISCOVERY]
server=10.77.77.9
max_control_nodes=2
[HYPERVISOR]
type=kvm
[NETWORKS]
control_network_ip=10.77.77.15
[VIRTUAL-HOST-INTERFACE]
name=vhost0
ip=10.77.77.15/24
gateway=10.77.77.1
physical_interface=eth4

```
在每个OpenStack Compute节点上，配置:     

```
# vim /etc/contrail/vrouter_nodemgr_param
DISCOVERY=10.77.77.9

```
配置nova-compute:     

```
 # openstack-config --set /etc/nova/nova.conf DEFAULT neutron_url http://10.77.77.9:9696
 # openstack-config --set /etc/nova/nova.conf DEFAULT neutron_admin_auth_url http://10.55.55.4:35357/v2.0/
 # openstack-config --set /etc/nova/nova.conf DEFAULT network_api_class nova_contrail_vif.contrailvif.ContrailNetworkAPI
 # openstack-config --set /etc/nova/nova.conf DEFAULT neutron_admin_tenant_name services
 # openstack-config --set /etc/nova/nova.conf DEFAULT neutron_admin_username neutron
 # openstack-config --set /etc/nova/nova.conf DEFAULT neutron_admin_password rVlaAKUs
 # openstack-config --set /etc/nova/nova.conf DEFAULT neutron_url_timeout 300
 # openstack-config --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver
 # openstack-config --set /etc/nova/nova.conf DEFAULT security_group_api neutron
 # service supervisor-vrouter restart

```
验证所有的vrouter服务都是active状态的:     

```
root@node-18:~# contrail-status 
== Contrail vRouter ==
supervisor-vrouter:           active
contrail-vrouter-agent        active              
contrail-vrouter-nodemgr      active              

```
更改/etc/libvirt/qemu.confg中的cgroup_device_acl部分:     

```
cgroup_device_acl = [
"/dev/null", "/dev/full", "/dev/zero",
"/dev/random", "/dev/urandom",
"/dev/ptmx", "/dev/kvm", "/dev/kqemu",
"/dev/rtc", "/dev/hpet","/dev/net/tun",
]

```
在每个OpenStack Compute节点上，添加iptables规则如下并保存:     

```
# iptables -I INPUT 1 -s 169.254.0.0/16 -i vhost0 -j ACCEPT -m comment --comment "metadata service"
# iptables -I INPUT 1 -p tcp -m multiport --destination-ports 2049,8085,9090,8102,33617,39704,44177,55970,60663 -j ACCEPT -m comment --comment "juniper contrail rules"
# iptables-save > /etc/iptables/rules.v4

```
重启libvirt-bin和nova-compute服务:     

```
# service libvirt-bin restart
# service nova-compute restart

```
更改vrouter的配置, ！！！注意，这是在Contrail Deploy的那个节点运行的！！！！ ：    

```
# python /opt/contrail/utils/provision_vrouter.py --host_name node-18 --host_ip 10.77.77.15 --api_server_ip 10.77.77.9 --admin_user neutron --admin_password rVlaAKUs --admin_tenant_name services --oper add

```
### VGW配置
OpenContrail支持多种配置，例如Juniper vSRX, Juniper MX, Cisco ASR等，但这些都需要专有硬件的支持（路由器），我们仅仅采用软件路由器Vrouter, 这里我们配置VGW:     

```
# export PYTHONPATH=/usr/lib/python2.7/dist-packages/contrail_vrouter_api/gen_py/instance_service
# python /opt/contrail/utils/provision_vgw_interface.py --oper create --interface vgw --subnets 10.88.88.0/24 --routes 0.0.0.0/0 --vrf default-domain:admin:ext:ext

```
更新/etc/contrail/contrail-vrouter-agent.con中的[GATEWAY-0]部分:      

```
[GATEWAY-0]
routing_instance=default-domain:admin:ext:ext
interface=vgw
ip_blocks=10.88.88.0/24
routes=0.0.0.0/0

```
重新启动supervisor-vrouter进程:     

```
# service supervisor-vrouter restart

```
重启其他所有的encapsulation方法，除了MPLS On UPD:    
![/images/2015_04_27_22_45_01_799x306.jpg](/images/2015_04_27_22_45_01_799x306.jpg)    

```


好了，这时候，Contrail已经集成到OpenStack环境里，你可以在Contrail的界面里，添加上网络，而后在OpenStack里使用它。Enjoy it !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

