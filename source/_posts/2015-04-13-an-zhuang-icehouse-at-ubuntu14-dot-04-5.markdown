---
layout: post
title: "安装Icehouse@Ubuntu14.04(5)"
date: 2015-04-13 19:17
comments: true
categories: virtualization
---

### Neutron Database
Follow following steps for create the database:    

```
root@JunoController:~# mysql -u root -p
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 58
Server version: 5.5.41-MariaDB-1ubuntu0.14.04.1 (Ubuntu)

Copyright (c) 2000, 2014, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE DATABASE neutron;
Query OK, 1 row affected (0.00 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY 'xxxxx'
    -> ;
Query OK, 0 rows affected (0.01 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY 'xxxxx';
Query OK, 0 rows affected (0.00 sec)

MariaDB [(none)]> flush privileges;
Query OK, 0 rows affected (0.01 sec)

MariaDB [(none)]> quit
Bye

```
### Keystone items
创建用户:   

```
root@JunoController:~# source ~/openstack/admin-openrc.sh
root@JunoController:~# keystone user-create --name neutron --pass xxxxx
+----------+----------------------------------+
| Property |              Value               |
+----------+----------------------------------+
|  email   |                                  |
| enabled  |               True               |
|    id    | a4cbae42a2164c6e9a4c05c3f6835782 |
|   name   |             neutron              |
| username |             neutron              |
+----------+----------------------------------+

```
更改权限，服务为tenant, 角色是admin:    

```
root@JunoController:~# keystone user-role-add --user neutron --tenant service --role admin

```
创建服务：    

```
root@JunoController:~# keystone service-create --name neutron --type network --description "OpenStack Networking"
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
| description |       OpenStack Networking       |
|   enabled   |               True               |
|      id     | 1142b316e4e04061bb676b73d0cf6f68 |
|     name    |             neutron              |
|     type    |             network              |
+-------------+----------------------------------+

```
创建服务的end-point:    

```
root@JunoController:~# keystone endpoint-create --service-id $(keystone service-list | awk '/ network / {print $2}') --publicurl http://10.17.17.211:9696 --adminurl http://10.17.17.211:9696 --internalurl http://10.17.17.211:9696 --region regionOne
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
|   adminurl  |     http://10.17.17.211:9696     |
|      id     | 77bb946d42dc4d099875ecc377510937 |
| internalurl |     http://10.17.17.211:9696     |
|  publicurl  |     http://10.17.17.211:9696     |
|    region   |            regionOne             |
|  service_id | 1142b316e4e04061bb676b73d0cf6f68 |
+-------------+----------------------------------+

```
### 安装组件
在Controller端安装:    

```
root@JunoController:~#  apt-get -y install neutron-server neutron-plugin-ml2 python-neutronclient

```
取得tenant service id:     

```
root@JunoController:~# source ~/openstack/admin-openrc.sh
root@JunoController:~# keystone tenant-get service
+-------------+----------------------------------+
|   Property  |              Value               |
+-------------+----------------------------------+
| description |          Service Tenant          |
|   enabled   |               True               |
|      id     | 4b22bf4e6a68419aa91da6e0ffaca2dc |
|     name    |             service              |
+-------------+----------------------------------+

```
编辑nova配置文件，修改如下：    

```
root@JunoController:~# vim /etc/neutron/neutron.conf
[DEFAULT]
rpc_backend = neutron.openstack.common.rpc.impl_kombu
rabbit_host = 10.17.17.211
rabbit_password = xxxxx

notify_nova_on_port_status_changes = True
notify_nova_on_port_data_changes = True
nova_url = http://10.17.17.211:8774/v2
nova_admin_username = nova
nova_admin_tenant_id = 4b22bf4e6a68419aa91da6e0ffaca2dc
nova_admin_password = xxxxx
nova_admin_auth_url = http://10.17.17.211:35357/v2.0

core_plugin = ml2
service_plugins = router
allow_overlapping_ips = True

auth_strategy = keystone

[keystone_authtoken]
auth_uri = http://10.17.17.211:5000
auth_host = 10.17.17.211
auth_port = 35357
auth_protocol = http
admin_tenant_name = service
admin_user = neutron
admin_password = xxxxx
signing_dir = $state_path/keystone-signing
[database]
connection = mysql://neutron:xxxxx@10.17.17.211/neutron

```
编辑ML2(Modular Layer2)插件， 在控制节点上：    


```
root@JunoController:~# vim /etc/neutron/plugins/ml2/ml2_conf.ini | more
[ml2]
type_drivers = gre
tenant_network_types = gre
mechanism_drivers = openvswitch

[ml2_type_gre]
tunnel_id_ranges = 1:1000


[securitygroup]
# Controls if neutron security group is enabled or not.
# It should be false when you use nova security group.
# enable_security_group = True
firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
enable_security_group = True

```
调整Compute Service使用Neutron服务:    

```
# vim /etc/nova/nova.conf
network_api_class = nova.network.neutronv2.api.API
neutron_url = http://10.17.17.211:9696
neutron_auth_strategy = keystone
neutron_admin_tenant_name = service
neutron_admin_username = neutron
neutron_admin_password = xxxxx
neutron_admin_auth_url = http://10.17.17.211:35357/v2.0
linuxnet_interface_driver = nova.network.linux_net.LinuxOVSInterfaceDriver
firewall_driver = nova.virt.firewall.NoopFirewallDriver
security_group_api = neutron


```
重启服务:    

```
# service nova-api restart
# service nova-scheduler restart
# service nova-conductor restart

```
重启网络服务:    

```
# service neutron-server restart

```
检查是否完成的命令:    

```
root@JunoController:~# neutron ext-list
+-----------------------+-----------------------------------------------+
| alias                 | name                                          |
+-----------------------+-----------------------------------------------+
| security-group        | security-group                                |
| l3_agent_scheduler    | L3 Agent Scheduler                            |
| ext-gw-mode           | Neutron L3 Configurable external gateway mode |
| binding               | Port Binding                                  |
| provider              | Provider Network                              |
| agent                 | agent                                         |
| quotas                | Quota management support                      |
| dhcp_agent_scheduler  | DHCP Agent Scheduler                          |
| multi-provider        | Multi Provider Network                        |
| external-net          | Neutron external network                      |
| router                | Neutron L3 Router                             |
| allowed-address-pairs | Allowed Address Pairs                         |
| extra_dhcp_opt        | Neutron Extra DHCP opts                       |
| extraroute            | Neutron Extra Route                           |
+-----------------------+-----------------------------------------------+

```
###配置网络节点
激活以下选项:    

```
root@JunoNetwork:~# vim /etc/sysctl.conf
net.ipv4.ip_forward=1
net.ipv4.conf.all.rp_filter=0
net.ipv4.conf.default.rp_filter=0
net.bridge.bridge-nf-call-arptables=1
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1

```
提交更改(这里有错误):    

```
root@JunoNetwork:~# sysctl -p
net.ipv4.ip_forward = 1
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
sysctl: cannot stat /proc/sys/net/bridge/bridge-nf-call-arptables: No such file or directory
sysctl: cannot stat /proc/sys/net/bridge/bridge-nf-call-iptables: No such file or directory
sysctl: cannot stat /proc/sys/net/bridge/bridge-nf-call-ip6tables: No such file or directory

```
安装网络组件:    

```
root@JunoNetwork:~# apt-get install neutron-plugin-ml2 neutron-plugin-openvswitch-agent neutron-l3-agent neutron-dhcp-agent

```
配置通用组件:    

```
# vim /etc/neutron/neutron.conf
[DEFAULT]
rpc_backend = neutron.openstack.common.rpc.impl_kombu
rabbit_host = 10.17.17.211
rabbit_password = xxxxx
core_plugin = ml2
service_plugins = router
allow_overlapping_ips = True
verbose = True
auth_strategy = keystone

[keystone_authtoken]
auth_uri = http://10.17.17.211:5000
auth_host = 10.17.17.211
auth_port = 35357
auth_protocol = http
admin_tenant_name = service
admin_user = neutron
admin_password = xxxxx

```
编辑L3 agent:    

```
# vim /etc/neutron/l3_agent.ini
[DEFAULT]
interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver
use_namespaces = True
verbose = True

```
编辑DHCP插件:     

```
# vim /etc/neutron/dhcp_agent.ini
 [DEFAULT]
interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver
dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq
use_namespaces = True

```
配置DHCP：     

```
root@JunoNetwork:~# vim /etc/neutron/dhcp_agent.ini
[DEFAULT]
...
dnsmasq_config_file = /etc/neutron/dnsmasq-neutron.conf
root@JunoNetwork:~# vim /etc/neutron/dnsmasp-neutron.conf
dhcp-option-force=26,1454

```
配置metadata agent:     

```
root@JunoNetwork:~# vim /etc/neutron/metadata_agent.ini
[DEFAULT]
auth_url = http://10.17.17.211:5000/v2.0
auth_region = regionOne
admin_tenant_name = service
admin_user = neutron
admin_password = xxxxx
nova_metadata_ip = 10.17.17.211
metadata_proxy_shared_secret = xxxxx

```
回到controller节点，编辑:     

```
# vim /etc/nova/nova.conf
[DEFAULT]
...
service_neutron_metadata_proxy = true
neutron_metadata_proxy_shared_secret = xxxxx

```
重启compute api服务:    

```
# service nva-api restart

```
配置 ml2:    

```
root@JunoNetwork:~# vim /etc/neutron/plugins/ml2/ml2_conf.ini 
[ml2]
type_drivers = gre
tenant_network_types = gre
mechanism_drivers = openvswitch
[ml2_type_gre]
tunnel_id_ranges = 1:1000
[ovs]
local_ip = 10.19.19.212
tunnel_type = gre
enable_tunneling = True
[securitygroup]
firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
enable_security_group = True

```
重启openvswitch 服务:    

```
root@JunoNetwork:~# service openvswitch-switch restart

```
增加bridge配置：     

```
root@JunoNetwork:~# ovs-vsctl add-br br-ex
root@JunoNetwork:~# cat /etc/network/interfaces
auto eth2
iface eth2 inet manual

iface br-ex inet static
address 10.22.22.212
netmask 255.255.255.0
gateway 10.22.22.1
bridge_ports eth2
bridge_stp off
auto br-ex

```
增加桥接端口，并且重启机器:     

```
root@JunoNetwork:~# ovs-vsctl add-port br-ex eth2
root@JunoNetwork:~# reboot

```
###计算节点配置
更改sysctl配置:     

```
root@JunoCompute:~# vim /etc/sysctl.conf
net.ipv4.conf.all.rp_filter=0
net.ipv4.conf.default.rp_filter=0
net.bridge.bridge-nf-call-arptables=1
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
root@JunoCompute:~# sysctl -p 
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
net.bridge.bridge-nf-call-arptables = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1

```
安装下列包:     

```
# apt-get install neutron-common neutron-plugin-ml2 neutron-plugin-openvswitch-agent openvswitch-datapath-dkms

```
配置compute节点上的网络通用组件:     

```
root@JunoCompute:~# vim /etc/neutron/neutron.conf
    [DEFAULT]
    auth_strategy = keystone
    rpc_backend = neutron.openstack.common.rpc.impl_kombu
    rabbit_host = controller
    rabbit_password = xxxx
    core_plugin = ml2
    service_plugins = router
    allow_overlapping_ips = True
    verbose = True
    [keystone_authtoken]
    auth_uri = http://10.17.17.211:5000
    auth_host = 10.17.17.211
    auth_port = 35357
    auth_protocol = http
    admin_tenant_name = service
    admin_user = neutron
    admin_password = xxxx
    signing_dir = $state_path/keystone-signing
    [database]
root@JunoCompute:~# vim /etc/neutron/plugins/ml2/ml2_conf.ini 
    [DEFAULT]
    ...
    core_plugin = ml2
    service_plugins = router
    allow_overlapping_ips = True
    [ml2]
    ...
    type_drivers = gre
    tenant_network_types = gre
    mechanism_drivers = openvswitch
    [ml2_type_gre]
    ...
    tunnel_id_ranges = 1:1000
    [ovs]
    ...
    local_ip = 10.19.19.213
    tunnel_type = gre
    enable_tunneling = True
    [securitygroup]
    ...
    firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
    enable_security_group = True
root@JunoCompute:~# service openvswitch-switch restart
root@JunoCompute:~# service nova-compute restart
root@JunoCompute:~# service neutron-plugin-openvswitch-agent restart

```
接下来我们配置Compute节点上的nova,让它使用neutron作为网络管理器.     

```
root@JunoCompute:~# vim /etc/nova/nova.conf 
[DEFAULT]
network_api_class = nova.network.neutronv2.api.API
neutron_url = http://10.17.17.211:9696
neutron_auth_strategy = keystone
neutron_admin_tenant_name = service
neutron_admin_username = neutron
neutron_admin_password = xxxx
neutron_admin_auth_url = http://10.17.17.211:35357/v2.0
linuxnet_interface_driver = nova.network.linux_net.LinuxOVSInterfaceDriver
firewall_driver = nova.virt.firewall.NoopFirewallDriver
security_group_api = neutron

```
修改完毕后，重启Compute节点上的服务:     

```
root@JunoCompute:~# service nova-compute restart
nova-compute stop/waiting
nova-compute start/running, process 2266
root@JunoCompute:~# service neutron-plugin-openvswitch-agent restart
stop: Unknown instance: 
neutron-plugin-openvswitch-agent start/running, process 2303

```
配置Network节点的网络，因为我们需要br-ex作为对外网络的接口。    
配置网络如下：    

```
# ovs-vsctl add-br br-ex
# ovs-vsctl add-port br-ex eth2
# cat /etc/network/interfaces
# 
auto eth2
iface eth2 inet manual

iface br-ex inet static
address 10.22.22.212
netmask 255.255.255.0
gateway 10.22.22.1
bridge_ports eth2
bridge_stp off
auto br-ex
# reboot

```
增加ext-net:     

```
root@JunoController:~# neutron net-create ext-net --shared --router:external=True
Created a new network:
+---------------------------+--------------------------------------+
| Field                     | Value                                |
+---------------------------+--------------------------------------+
| admin_state_up            | True                                 |
| id                        | d879d5b1-f16e-4e28-beda-eb2b433e1f39 |
| name                      | ext-net                              |
| provider:network_type     | gre                                  |
| provider:physical_network |                                      |
| provider:segmentation_id  | 1                                    |
| router:external           | True                                 |
| shared                    | True                                 |
| status                    | ACTIVE                               |
| subnets                   |                                      |
| tenant_id                 | ea1f0a6b15dc4796958f087c38756ed1     |
+---------------------------+--------------------------------------+

```
外部子网：    

```
root@JunoController:~# neutron subnet-create ext-net --name ext-subnet --allocation-pool start=10.22.22.10,end=10.22.22.50 --disable-dhcp --gateway 10.22.22.1 --gateway 10.22.22.1 10.22.22.10/24
Created a new subnet:
+------------------+------------------------------------------------+
| Field            | Value                                          |
+------------------+------------------------------------------------+
| allocation_pools | {"start": "10.22.22.10", "end": "10.22.22.50"} |
| cidr             | 10.22.22.0/24                                  |
| dns_nameservers  |                                                |
| enable_dhcp      | False                                          |
| gateway_ip       | 10.22.22.1                                     |
| host_routes      |                                                |
| id               | 3c7e2224-0979-4eb6-b95f-16401ecbfef0           |
| ip_version       | 4                                              |
| name             | ext-subnet                                     |
| network_id       | d879d5b1-f16e-4e28-beda-eb2b433e1f39           |
| tenant_id        | ea1f0a6b15dc4796958f087c38756ed1               |
+------------------+------------------------------------------------+


```

```
root@JunoController:~# source openstack/demo-openrc.sh 
root@JunoController:~# neutron net-create demo-net
Created a new network:
+----------------+--------------------------------------+
| Field          | Value                                |
+----------------+--------------------------------------+
| admin_state_up | True                                 |
| id             | 01c966ce-88cf-43a2-a7b7-2ebf6d6b6d60 |
| name           | demo-net                             |
| shared         | False                                |
| status         | ACTIVE                               |
| subnets        |                                      |
| tenant_id      | 2ac9cae777014d3d94458f521b013e94     |
+----------------+--------------------------------------+
root@JunoController:~# neutron subnet-create demo-net --name demo-subnet --gateway 10.44.44.1 10.44.44.0/24
Created a new subnet:
+------------------+------------------------------------------------+
| Field            | Value                                          |
+------------------+------------------------------------------------+
| allocation_pools | {"start": "10.44.44.2", "end": "10.44.44.254"} |
| cidr             | 10.44.44.0/24                                  |
| dns_nameservers  |                                                |
| enable_dhcp      | True                                           |
| gateway_ip       | 10.44.44.1                                     |
| host_routes      |                                                |
| id               | c6181123-f729-4ad2-bddc-93cfc761d0e1           |
| ip_version       | 4                                              |
| name             | demo-subnet                                    |
| network_id       | 01c966ce-88cf-43a2-a7b7-2ebf6d6b6d60           |
| tenant_id        | 2ac9cae777014d3d94458f521b013e94               |
+------------------+------------------------------------------------+

root@JunoController:~# neutron router-create demo-router
Created a new router:
+-----------------------+--------------------------------------+
| Field                 | Value                                |
+-----------------------+--------------------------------------+
| admin_state_up        | True                                 |
| external_gateway_info |                                      |
| id                    | e5a010ba-371c-43d2-b3fb-a30e0dc5302b |
| name                  | demo-router                          |
| status                | ACTIVE                               |
| tenant_id             | 2ac9cae777014d3d94458f521b013e94     |
+-----------------------+--------------------------------------+

root@JunoController:~# neutron router-interface-add demo-router demo-subnet
Added interface c862f772-a1ef-4401-9a3b-2bdf5444e41b to router demo-router.

root@JunoController:~# neutron router-gateway-set demo-router ext-net
Set gateway for router demo-router

```
检查，在外网上ping 10.22.22.10这个地址，因为路由器占用了一个地址，所以如果能ping通这个地址，说明我们创建的网络是好的。    

```
[root:~]# ping 10.22.22.212                                                                                                                    
PING 10.22.22.212 (10.22.22.212) 56(84) bytes of data.                                                                                         
64 bytes from 10.22.22.212: icmp_seq=1 ttl=64 time=0.152 ms                                                                                    
64 bytes from 10.22.22.212: icmp_seq=2 ttl=64 time=0.136 ms    

```
检查agent状态:     

```
root@JunoController:~# neutron agent-list
+--------------------------------------+--------------------+-------------+-------+----------------+
| id                                   | agent_type         | host        | alive | admin_state_up |
+--------------------------------------+--------------------+-------------+-------+----------------+
| 0b7191e1-ecd2-4808-b87a-f616d0a3bc7b | Metadata agent     | JunoNetwork | :-)   | True           |
| 34511134-8392-44a9-a889-0ff03d85a995 | Open vSwitch agent | JunoCompute | :-)   | True           |
| 474065d1-a50a-4d11-89d3-37c7a88e449c | DHCP agent         | JunoNetwork | :-)   | True           |
| 5569c590-df83-4ee1-a073-15c908ef8d20 | L3 agent           | JunoNetwork | :-)   | True           |
| a22c6e2a-7af0-4404-9e5b-46996b370672 | Open vSwitch agent | JunoNetwork | :-)   | True           |
+--------------------------------------+--------------------+-------------+-------+----------------+

```
在 Compute Node 上的 OVS agent出现后，才能代表我们的网络配置成功。    

