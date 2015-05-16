---
layout: post
title: "安装Icehouse@Ubuntu14.04(7)"
date: 2015-04-14 12:11
comments: true
categories: virtualization
---
接下来在OpenStack Icehouse的基础上，部署OpenContrail, OpenContrail能提供更为强大的网络功能。    
首先从Juniper的官网上下载安装文件:     

```
	contrail-install-packages_2.10-39~ubuntu-14-04icehouse_all.deb

```
Contrail可以被安装到已经部署好的OpenStack环境中，只要在安装Contrail的时候，根据已有的OpenStack组件的部署情况作相应的调整就可以。    
### Hook
Contrail用到的钩子(Hook)有：    
`core_plugin` -- 它被用在neutron的配置中，用于指向ContrailPlugin组件。    
`libvirt_vif_driver` -- 它被用在nova计算节点配置中，用来指向Contrail的VRouterVIFDriver.    
`MQ broker IP and Port` -- 如果现有的OpenStack提供RabbitMQ那么将相应的IP和端口在neutron和nova的配置中指过去。    
### Contrial部署涉及组建
列举如下，对应的文件需要做修改，或者创建。    

```
api_service.conf - This file needs to be edited to provide details of existing OpenStack keystone.
plugin.ini - This file needs proper keystone URL, token and credentials.
neutron.conf - This file needs auth_host credentials to connect OpenStack keystone.
config.global.js - This file contains IP and PORT for image (glance), compute (nova), identity (keystone), storage (cinder)
OpenStack controller nova config to point to Contrail neutron
OpenStack controller neuron service endpoint to point to contrail neutron.

```
为了让来之不易的OpenStack不至于被毁掉，建议先做好备份。因为接下来就要对已经部署好的节点做各种操作了。
### 干掉OVS

Make sure to remove existing OpenStack OVS installed modules and config.
首先，在DashBoard里干掉所有的网络配置(网络/路由等）。    
#### Network节点移除OpenVSwitch
更改Network节点的网络配置，取消br-ex的配置：    

```
root@JunoNetwork:~# vim /etc/network/interfaces
auto eth2
iface eth2 inet static
address 10.22.22.212
netmask 255.255.255.0

#iface eth2 inet manual
#iface br-ex inet static
#address 10.22.22.212
#netmask 255.255.255.0
## gateway 10.22.22.1
#bridge_ports eth2
#bridge_stp off
#auto br-ex

```
移除br-ex设备，并重启Network节点:     

```
root@JunoNetwork:~# ovs-vsctl del-port br-ex eth2
root@JunoNetwork:~# ovs-vsctl del-br br-ex
root@JunoNetwork:~# reboot

```
注释掉关于ML2服务配置并重新启动服务：    

```
root@JunoNetwork:~# cat /etc/neutron/plugins/ml2/ml2_conf.ini| grep -i "^###"
### type_drivers = flat,gre
### tenant_network_types = gre
### mechanism_drivers = openvswitch
### tunnel_id_ranges = 1:1000
### enable_security_group = True
### firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
### enable_security_group = True
### [ovs]
### local_ip = 10.19.19.212
### tunnel_type = gre
### enable_tunneling = True
root@JunoNetwork:~# service openvswitch-switch restart

```
注释掉关于metadata的相关配置：    

```
root@JunoNetwork:~# cat /etc/neutron/metadata_agent.ini | grep -i "^###"
### auth_url = http://10.17.17.211:5000/v2.0
### auth_region = regionOne
### admin_tenant_name = service
### admin_user = neutron
### admin_password = engine
### nova_metadata_ip = 10.17.17.211
### metadata_proxy_shared_secret = engine

```
回到Controller节点，同样注释掉metadata的配置:    

```
root@JunoController:~# cat /etc/nova/nova.conf | grep -i "^###"
### service_neutron_metadata_proxy = true
### metadata_proxy_shared_secret = engine
### neutron_metadata_proxy_shared_secret = engine

```
移除DHCP相关配置：    

```
root@JunoNetwork:~# cat /etc/neutron/dhcp_agent.ini | grep -i "^###"
### interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver
### dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq
### use_namespaces = True
### dnsmasq_config_file = /etc/neutron/dnsmasq-neutron.conf
root@JunoNetwork:~# cat /etc/neutron/dnsmasp-neutron.conf | grep -i "^###"
### dhcp-option-force=26,1454

```
移除L3 agent:    

```
root@JunoNetwork:~# cat /etc/neutron/l3_agent.ini | grep -i "^###"
### interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver
### use_namespaces = True
### verbose = True

```
移除neutron通用组件的支持:    

```
root@JunoNetwork:~# cat /etc/neutron/neutron.conf | grep -i "^###"
### rpc_backend = neutron.openstack.common.rpc.impl_kombu
### rabbit_host = 10.17.17.211
### rabbit_password = engine
### core_plugin = ml2
### service_plugins = router
### allow_overlapping_ips = True
### verbose = True
### auth_strategy = keystone
### auth_uri = http://10.17.17.211:5000
### auth_host = 10.17.17.211
### auth_port = 35357
### auth_protocol = http
### admin_tenant_name = service
### admin_user = neutron
### admin_password = engine

```
移除已经安装的vswitch相关的包:    

```
root@JunoNetwork:~# apt-get purge neutron-plugin-ml2 neutron-plugin-openvswitch-agent neutron-l3-agent neutron-dhcp-agent
root@JunoCompute:~# apt-get purge openvswitch-common openvswitch-switch
root@JunoCompute:~# reboot

```
#### Compute节点移除OpenVSwitch
Compute节点的服务移除：    

```
root@JunoCompute:~# cat /etc/neutron/neutron.conf | grep -i "^###"
[DEFAULT]
###auth_strategy = keystone
###rpc_backend = neutron.openstack.common.rpc.impl_kombu
###rabbit_host = 10.17.17.211
###rabbit_password = engine
###core_plugin = ml2
###service_plugins = router
###allow_overlapping_ips = True
###verbose = True
[keystone_authtoken]
### auth_uri = http://10.17.17.211:5000
### auth_host = 10.17.17.211
### auth_port = 35357
### auth_protocol = http
### admin_tenant_name = service
### admin_user = neutron
### admin_password = engine
### signing_dir = $state_path/keystone-signing
root@JunoCompute:~# cat /etc/neutron/plugins/ml2/ml2_conf.ini | grep -i "^###"
### type_drivers = gre
### tenant_network_types = gre
### mechanism_drivers = openvswitch
### tunnel_id_ranges = 1:1000
### firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
### enable_security_group = True
### [ovs]
### local_ip = 10.19.19.213
### tunnel_type = gre
### enable_tunneling = True

```
注释完毕后，重新启动服务:    

```
root@JunoCompute:~# service nova-compute restart
root@JunoCompute:~# service neutron-plugin-openvswitch-agent restart
root@JunoCompute:~# service openvswitch-switch restart

```
Compute节点上的nova不再使用neutron作为网络管理器:     

```
root@JunoCompute:~# cat /etc/nova/nova.conf | grep -i "^###"
### network_api_class = nova.network.neutronv2.api.API
### neutron_url = http://10.17.17.211:9696
### neutron_auth_strategy = keystone
### neutron_admin_tenant_name = service
### neutron_admin_username = neutron
### neutron_admin_password = engine
### neutron_admin_auth_url = http://10.17.17.211:35357/v2.0
### linuxnet_interface_driver = nova.network.linux_net.LinuxOVSInterfaceDriver
### firewall_driver = nova.virt.firewall.NoopFirewallDriver
### security_group_api = neutron
root@JunoCompute:~# service nova-compute restart

```
在Compute节点上,移除已经安装的openvswitch的包:    

```
root@JunoCompute:~# apt-get purge neutron-plugin-ml2 neutron-plugin-openvswitch-agent openvswitch-datapath-dkms
root@JunoCompute:~# apt-get purge openvswitch-common openvswitch-switch
root@JunoCompute:~# reboot

```
检查状态,确保服务已经被移除:    

```
root@JunoCompute:~# service openvswitch-switch status
openvswitch-switch: unrecognized service
root@JunoCompute:~# service neutron-plugin-openvswitch-agent status
neutron-plugin-openvswitch-agent: unrecognized service

```
#### Controller节点上移除OpenVSwitch
移除nova配置中关于neutron的条目：    

```
root@JunoController:~# cat /etc/nova/nova.conf | grep -i "^###"
### service_neutron_metadata_proxy = true
### metadata_proxy_shared_secret = engine
### neutron_metadata_proxy_shared_secret = engine
### network_api_class = nova.network.neutronv2.api.API
### neutron_url = http://10.17.17.211:9696
### neutron_auth_strategy = keystone
### neutron_admin_tenant_name = service
### neutron_admin_username = neutron
### neutron_admin_password = engine
### neutron_admin_auth_url = http://10.17.17.211:35357/v2.0
### linuxnet_interface_driver = nova.network.linux_net.LinuxOVSInterfaceDriver
### firewall_driver = nova.virt.firewall.NoopFirewallDriver
### security_group_api = neutron

```
移除对于ML2插件的支持:    

```
root@JunoController:~# cat /etc/neutron/plugins/ml2/ml2_conf.ini | grep -i "^###"
### type_drivers = flat,gre
### tenant_network_types = gre
### mechanism_drivers = openvswitch
### tunnel_id_ranges = 1:1000
### firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
### enable_security_group = True

```
移除neutron中配置:    

```
root@JunoController:~# cat /etc/neutron/neutron.conf | grep -i "^###"
### rpc_backend = neutron.openstack.common.rpc.impl_kombu
### rabbit_host = 10.17.17.211
### rabbit_password = engine
### notify_nova_on_port_status_changes = True
### notify_nova_on_port_data_changes = True
### nova_url = http://10.17.17.211:8774/v2
### nova_admin_username = nova
### nova_admin_tenant_id = 4b22bf4e6a68419aa91da6e0ffaca2dc
### nova_admin_password = engine
### nova_admin_auth_url = http://10.17.17.211:35357/v2.0
### nova_region_name = regionOne
### core_plugin = ml2
### service_plugins = router
### allow_overlapping_ips = True
### auth_strategy = keystone
### auth_uri = http://10.17.17.211:5000
### auth_host = 10.17.17.211
### auth_port = 35357
### auth_protocol = http
### admin_tenant_name = service
### admin_user = neutron
### admin_password = engine
### connection = mysql://neutron:engine@10.17.17.211/neutron

```
删除ml2插件:    

```
root@JunoController:~# apt-get purge neutron-plugin-ml2

```
测试，由于连验证都没法通过，所以会返回错误，当然你的DashBoard也会有错误,暂时没办法访问了。:     

```
root@JunoController:~#  neutron agent-list
Authentication required

```
### Contrail
#### 创建机器
4G内存，2核CPU，同时连接到所有网络(10.17.17.0/24, 10.19.19.0/24, 10.22.22.0/24):     

```
[root:/home/juju/img/OpenStack]# qemu-img create -f qcow2 -b ./UbuntuBase1404.qcow2  JunoContrail.qcow2

```
配置网络接口, hosts, hostname等:     

```
root@JunoContrail:~# cat /etc/hostname 
JunoContrail
root@JunoContrail:~# cat /etc/hosts
10.17.17.211    JunoController
10.17.17.212    JunoNetwork
10.17.17.213    JunoCompute
10.17.17.214    JunoContrail
root@JunoContrail:~# cat /etc/network/interfaces
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet static
address 10.17.17.214
netmask 255.255.255.0
gateway 10.17.17.1
dns-nameservers 114.114.114.114

# Network, have the tunnel, which locates at the 10.19.19.0/24
auto eth1
iface eth1 inet static
address 10.19.19.214
netmask 255.255.255.0
up route add -net 10.19.19.0/24 dev eth1

auto eth2
iface eth2 inet static
address 10.22.22.214
netmask 255.255.255.0

```
得到包，并且安装之:    

```
root@JunoContrail:~# wget http://xxxxxxxxxxxxxx/contrail-install-packages_2.10-39~ubuntu-14-04icehouse_all.deb 
root@JunoContrail:~# dpkg -i contrail-install-packages_2.10-39~ubuntu-14-04icehouse_all.deb 


```
直接安装会出错，为了避免，直接手动安装build-essential和python-pip:    

```
root@JunoContrail:~# apt-get install build-essential python-pip

```
而后手动开始安装contrail:     

```
root@JunoContrail:/opt/contrail/contrail_packages# ./setup.sh 

```
使用模板生成testbed.py文件:    

```
root@JunoContrail:/opt/contrail# cp /opt/contrail/utils/fabfile/testbeds/testbed_multibox_example.py /opt/contrail/utils/fabfile/testbeds/testbed.py

```
需要配置ntp，加入到本地的NTP网络里:     

```
root@JunoContrail:/opt/contrail/utils# apt-get -y install ntp
root@JunoContrail:/opt/contrail/utils# vim /etc/ntp.conf 
server 10.17.17.211 iburst
root@JunoContrail:/opt/contrail/utils# service ntp restart
 * Stopping NTP server ntpd
   ...done.
ntpq * Starting NTP server ntpd
   ...done.
root@JunoContrail:/opt/contrail/utils# ntpq -c peers
     remote           refid      st t when poll reach   delay   offset  jitter
==============================================================================
 JunoController  202.112.29.82    3 u    1   64    1    0.312   33.463   0.000

```
配置testbed.py文件，更改后的例子如下：     

```
TBD........

```
安装的时候，出现问题，需要切换到最旧的原始安装的Ubuntu1404. 切换前，记下已有的步骤:    

```
$ cd /opt/contrail/utils/
$ fab install_pkg_all:/root/contrail-install-packages_2.10-39~ubuntu-14-04icehouse_all.deb 
$ fab -c fabrc install_without_openstack:no

```
切换:    

```
[root:/home/juju/img/OpenStack]# mv JunoContrail.qcow2 JunoContrail.qcow2_Deploy_Failed_Too_new


```

