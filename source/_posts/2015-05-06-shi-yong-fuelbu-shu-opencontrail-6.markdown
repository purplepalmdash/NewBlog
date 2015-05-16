---
layout: post
title: "使用Fuel部署OpenContrail(6)"
date: 2015-05-06 15:27
comments: true
categories: Virtualization
---
前面在HA类型的Fuel OpenStack基础上集成了OpenContrail，然而在实际的开发和测试中，用HA类型比较浪费硬件资源，因此这次我把部署节点从7个压缩到3个，做多节点上非HA类型的OpenStack集成OpenContrail.     
### 先决条件
这次只用三台机器来做部署，分别为:    
2-Core, 3G内存, 100G硬盘, 用于安装OpenStack Controller.        
2-Core, 2G内存, 100G硬盘, 用于安装OpenStack Compute. 注意这台机器需要Copy Host CPU configuration, 以激活KVM。        
2-Core, 3G内存, 100G硬盘, 用于安装Contrail.    
创建出来的两个用于部署的OpenStack环境如下:    
![/images/2015_05_06_15_36_20_383x194.jpg](/images/2015_05_06_15_36_20_383x194.jpg)   
值得注意的是，在OpenStack的配置中，我们激活了Ceilometer，用于统计，所以需要额外增加一台2G内存大小的虚拟机。    
![/images/2015_05_06_09_40_34_608x385.jpg](/images/2015_05_06_09_40_34_608x385.jpg)     
### 安装
安装过程和HA的过程大同小异，配置好网络以后，现在I3OpenStack中部署好OpenStack，而后用provision的方式将I3Contrail中的Contrail部署节点机器安装为Ubuntu的格式。      
这里的具体配置过程可以参考《使用Fuel部署OpenContrail(1)》到《使用Fuel部署OpenContrail(3)》.    
一切就绪后，我们进入到配置过程.    
### 配置
详细配置如下:    
#### (Contrail) 配置Contrail部署节点
删除不用的网络端口, 并配置ifccfg-eth4后重启:    

```
# cd /etc/network/interfaces.d/
# rm -f ifcfg-eth1 
# rm -f ifcfg-eth2 
# rm -f ifcfg-eth3
# vim ifcfg-eth4
    auto eth4
    iface eth4 inet static
    
    address 10.77.77.100
    netmask 255.255.255.0
    gateway 10.77.77.1
    
    post-up  ethtool  -K  eth4  gso off  gro off || true
# reboot

```
确保在Contrail部署节点上，可以ping通OpenStack Controller的10.55.55.0/24网络。     
配置本地安装源:    

```
# echo 'deb http://10.20.0.2:8080/contrail/ /' > /etc/apt/sources.list.d/contrail.list
# echo -e "Package: *\nPin: release l=Ubuntu\nPin-Priority: 100" > /etc/apt/preferences
# >/etc/apt/sources.list
# apt-get update
# apt-get install -y python-paramiko contrail-fabric-utils contrail-setup
# pip install --upgrade --no-deps --index-url=”” /opt/contrail/python_packages/Fabric-1.7.0.tar.gz

```
开始配置用于部署的testbed.py文件，可以看到，比起HA部署方式来看，我们减少了一些节点定义，去掉了HA有关的配置:      

```
# vim  /opt/contrail/utils/fabfile/testbeds/testbed.py
    from fabric.api import env
    #Management ip addresses of hosts in the cluster
    #os_ctrl01 = 'root@10.55.55.6'
    #os_ctrl02 = 'root@10.55.55.7'
    #os_ctrl03 = 'root@10.55.55.8'
    os_ctrl01 = 'root@10.55.55.7'
    
    c_ctrl01 = 'root@10.77.77.100'
    #c_ctrl02 = 'root@10.77.77.11'
    #c_ctrl03 = 'root@10.77.77.12'
    c_db01 = 'root@10.77.77.100'
    #c_db02 = 'root@10.77.77.11'
    #c_db03 = 'root@10.77.77.12'
    #External routers
    # ext_routers = [('gateway01', '<Gateway_node1_LOOPBACK_ip>'), ('gateway02', '<Gateway_node2_LOOPBACK_ip>')]
    #Autonomous system number
    router_asn = 64512
    #Host from which the fab commands are triggered to install and provision
    deploy_node = 'root@10.77.77.100'
    #Role definition of the hosts.
    env.roledefs = {
    'all': [c_ctrl01, c_db01],
    'cfgm': [c_ctrl01],
    'openstack': [os_ctrl01],
    'control': [c_ctrl01],
    'compute': [],
    'collector': [c_ctrl01],
    'webui': [c_ctrl01],
    'database': [c_db01],
    'build': [deploy_node],
    'storage-master': [],
    'storage-compute': [],
    }
    #Openstack admin password
    env.openstack_admin_password = 'admin'
    env.password = 'r00tme'
    #Passwords of each host
    env.passwords = {
    os_ctrl01: 'r00tme',
    # os_ctrl02: 'r00tme',
    # os_ctrl03: 'r00tme',
    c_ctrl01: 'r00tme',
    #c_ctrl02: 'r00tme',
    #c_ctrl03: 'r00tme',
    c_db01: 'r00tme',
    # c_db02: 'r00tme',
    # c_db03: 'r00tme',
    deploy_node: 'r00tme',
    }
    #For reimage purpose
    env.ostypes = {
    os_ctrl01: 'ubuntu',
    # os_ctrl02: 'ubuntu',
    # os_ctrl03: 'ubuntu',
    c_ctrl01: 'ubuntu',
    # c_ctrl02: 'ubuntu',
    # c_ctrl03: 'ubuntu',
    c_db01: 'ubuntu',
    # c_db02: 'ubuntu',
    # c_db03: 'ubuntu',
    deploy_node: 'ubuntu',
    }
    env.openstack = {
    'service_token' : 'xqnCCCs2'
    }
    # env.ha = {
    # 'internal_vip': '10.55.55.4',
    # 'external_vip': '172.16.0.4',
    # 'contrail_internal_vip': '10.77.77.9',
    # 'contrail_external_vip': '10.77.77.9',
    # }
    env.keystone = {
    'service_tenant': 'services',
    'admin_token': 'xqnCCCs2',
    }
    multi_tenancy = True

```
从Fuel节点控制机上拷贝公钥文件，用于快速部署

```
# scp 10.20.0.2:/root/.ssh/id_rsa /root/.ssh/id_rsa
# chmod 0600 /root/.ssh/id_rsa

```
在节点上部署仓库，安装必要包，同意SUN协议:    

```
# fab -P -R control -w -- 'ls /etc/apt/preferences || echo -e "Package: *\nPin: release \
l=Ubuntu\nPin-Priority: 100" > /etc/apt/preferences'
# fab -P -R control -w -- 'DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes \
--allow-unauthenticated install python-crypto python-netaddr python-paramiko \
contrail-fabric-utils contrail-setup'
# fab -P -R control -w -- 'pip install --upgrade --no-deps --index-url="" \
/opt/contrail/python_packages/ecdsa-0.10.tar.gz'
# fab -P -R control -w -- 'pip install --upgrade --no-deps --index-url="" \
/opt/contrail/python_packages/Fabric-1.7.0.tar.gz'
# fab -P -R control -w -- 'echo "sun-java6-plugin shared/accepted-sun-dlj-v1-1 boolean \
true" | /usr/bin/debconf-set-selections' && fab -P -R control -w -- 'echo "sun-java6-bin shared/accepted-sun-dlj-v1-1 boolean \
 true" | /usr/bin/debconf-set-selections' && fab -P -R control -w -- 'echo "debconf shared/accepted-oracle-license-v1-1 select \
true" | sudo debconf-set-selections' && fab -P -R control -w -- 'echo "debconf shared/accepted-oracle-license-v1-1 seen \
 true" | sudo debconf-set-selections'

```
安装特定版本的tzdata， 安装和配置数据库，并检查状态：    

```
# fab -P -R control -w -- 'DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes \
 --allow-unauthenticated install tzdata=2014e-0ubuntu0.12.04' && fab install_database && fab setup_database && fab -R database -w -- "contrail-status"
# nodetool status

```
安装和配置cfgm, control, collector, webui，keepalived等, 并配置tenant服务:    

```
# fab install_cfgm && fab install_control && fab install_collector && fab install_webui && fab setup_contrail_keepalived
# fab -P -R control -w -- 'service keepalived restart'
# fab -P -R control -w -- "sed -i '49s/service/services/g' \
/usr/local/lib/python2.7/dist-packages/contrail_provisioning/config/quantum_in_keystone_setup.py"
# fab setup_cfgm
# fab setup_control && fab setup_collector && fab setup_webui

```
(OpenStack Controller节点)检查neutron endpoint的方法，看是否有10.77.77.100的字段出现：    

```
# keystone service-list
# keystone endpoint-list

```
(OpenStack Controller节点)顺便，我们要拿到rabbit_hosts的密码，供下面使用:     

```
# cat /etc/rabbitmq/rabbitmq.config | grep default_pass
    {default_pass,        <<"nFyBhsrP">>},

```
配置rabbit:    

```
# fab -P -R control -w -- 'openstack-config --del /etc/neutron/neutron.conf DEFAULT rabbit_host'
# fab -P -R control -w -- 'openstack-config --set /etc/neutron/neutron.conf DEFAULT rabbit_hosts 10.55.55.7:5672'
# fab -P -R control -w -- 'openstack-config --set /etc/neutron/neutron.conf DEFAULT rabbit_userid \
   nova'
# fab -P -R control -w -- 'openstack-config --set /etc/neutron/neutron.conf DEFAULT \
  rabbit_password nFyBhsrP'
# fab -P -R control -w -- 'service neutron-server restart'

```
配置contrail-api使用OpenStack Controller上的rabbit服务:     

```
# fab -P -R control -w -- 'perl -pi -e \
 "s/rabbit_server.*$/rabbit_server=10.55.55.7/" /etc/contrail/contrail-api.conf'
# fab -P -R control -w -- 'perl -pi -e "s/rabbit_port.*$/rabbit_port=5672/" \
 /etc/contrail/contrail-api.conf'
# fab -R control -w -- "perl -pi -e 'print \"rabbit_password=nFyBhsrP\n\" \
 if \$_ =~ rabbit_port' /etc/contrail/contrail-api.conf"
# fab -P -R control -w -- "perl -pi -e 'print \"rabbit_user=nova\n\" if \$_ =~ rabbit_port' \
 /etc/contrail/contrail-api.conf"
# fab -P -R control -w -- "service contrail-api restart"

```
替换neutron的插件为OpenContrail：    

```
# cp -r contrail-repo/neutron_plugin_contrail/plugins/opencontrail /usr/share/pyshared/neutron_plugin_contrail/plugins/
# cd /opt/contrail/utils
# fab -P -R cfgm -w -- 'service neutron-server restart'

```
重启BGP,METADATA,ENCAPSULATION:    

```
# fab prov_control_bgp && fab prov_metadata_services && fab prov_encap_type

```
验证:    

```
# fab verify_cfgm
# fab verify_control
# fab verify_collector
# fab verify_webui
# fab -R control -w -- "contrail-status"
# fab -P -R control -w -- 'update-rc.d supervisor-support-service disable'

```
现在访问:       
[https://10.77.77.100:8143](https://10.77.77.100:8143)      
Contrail的组件已经被配置完毕，接下来配置Compute节点，以引入Vrouter等。       

#### (OpenStack Controller节点)
删除ifcfg-eth4的配置后重启OpenStack Controller节点, 修改nova.conf文件:     

```
# vim /etc/nova/nova.conf
[DEFAULT]
network_api_class = nova.network.neutronv2.api.API
neutron_url = http://10.77.77.100:9696
neutron_admin_tenant_name = services
neutron_admin_username = neutron
neutron_admin_password = xqnCCCs2
neutron_url_timeout = 300
neutron_admin_auth_url = http://10.55.55.7:35357/v2.0/
firewall_driver = nova.virt.firewall.NoopFirewallDriver
enabled_apis = ec2,osapi_compute,metadata
security_group_api = neutron
service_neutron_metadata_proxy = True

```
重启服务:     

```
# service nova-api restart
# service nova-scheduler restart
# service nova-conductor restart

```
删除已注册的nova-network组件:     

```
# source ~/openrc
# for i in $(nova service-list|grep nova-network|awk '{print $2}'); \
do nova service-delete $i;done

```
接下来配置Compute节点.     
#### (Compute节点)
引入本地安装仓库:    

```
#  echo 'deb http://10.20.0.2:8080/contrail/ /' >/etc/apt/sources.list.d/contrail.list
# echo -e "Package: *\nPin: release l=Ubuntu\nPin-Priority: 100" > /etc/apt/preferences
# >/etc/apt/sources.list
# apt-get update

```
删除已有的vswitch模块，并验证:     

```
# apt-get purge -y openvswitch-switch nova-network nova-api
# apt-get purge -y  nova-network nova-api
# aptitude search -F '%p' '~i' | grep openvswitch

```
删除OVS内核模块:     

```
# lsmod | grep openvswitch && rmmod openvswitch

```
删除virtual网络,即virbr0端口:     

```
# virsh net-destroy default
# virsh net-undefine default

```
删除除ifcfg-eth4和ifcfg-eth0的其他端口，并重启，重启后用下列命令检查是否有iptables NAT规则存在，理论上应该是空的:     

```
# iptables -L -t nat

```
安装vrouter:     

```
# apt-get install -y contrail-openstack-vrouter

```
配置vhosts,vrouter需要使用这个端口,指定IP地址为10.77.77.101:     

```
# vim /etc/network/interfaces.d/ifcfg-vhost0 
auto vhost0
iface vhost0 inet static
    netmask 255.255.255.0
    network_name application
    address 10.77.77.101
    gateway 10.77.77.1
    mtu 1300
# vim /etc/network/interfaces.d/ifcfg-eth4 
auto eth4
iface eth4 inet manual

up ip l set eth4 up
down ip l set eth4 down

post-up  ethtool  -K  eth4  gso off  gro off || true

```
创建agent-param文件:     

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
server=10.77.77.100
max_control_nodes=1
[HYPERVISOR]
type=kvm
[NETWORKS]
control_network_ip=10.77.77.101
[VIRTUAL-HOST-INTERFACE]
name=vhost0
ip=10.77.77.101/24
gateway=10.77.77.1
physical_interface=eth4

```
配置节点管理参数,地址指向Contrail控制器的IP:     

```
# vim /etc/contrail/vrouter_nodemgr_param
DISCOVERY=10.77.77.100

```
配置nova-compute:     

```
 # openstack-config --set /etc/nova/nova.conf DEFAULT neutron_url http://10.77.77.100:9696
 # openstack-config --set /etc/nova/nova.conf DEFAULT neutron_admin_auth_url http://10.55.55.7:35357/v2.0/
 # openstack-config --set /etc/nova/nova.conf DEFAULT network_api_class nova_contrail_vif.contrailvif.ContrailNetworkAPI
 # openstack-config --set /etc/nova/nova.conf DEFAULT neutron_admin_tenant_name services
 # openstack-config --set /etc/nova/nova.conf DEFAULT neutron_admin_username neutron
 # openstack-config --set /etc/nova/nova.conf DEFAULT neutron_admin_password xqnCCCs2
 # openstack-config --set /etc/nova/nova.conf DEFAULT neutron_url_timeout 300
 # openstack-config --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver
 # openstack-config --set /etc/nova/nova.conf DEFAULT security_group_api neutron
 # service supervisor-vrouter restart

```
验证所有的vrouter服务都是active状态的:     

```
# contrail-status 
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
(Contrail Controller节点)更改vrouter的配置, ！！！注意，这是在Contrail Deploy的那个节点运行的！！！！, host_name的结果可以在compute节点上通过hostname命令来获得 ：    

```
# python /opt/contrail/utils/provision_vrouter.py --host_name node-18 --host_ip 10.77.77.101 --api_server_ip 10.77.77.100 --admin_user neutron --admin_password xqnCCCs2 --admin_tenant_name services --oper add

```
####  VGW配置
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
重启其他所有的encapsulation方法，除了MPLS On UDP:    
![/images/2015_04_27_22_45_01_799x306.jpg](/images/2015_04_27_22_45_01_799x306.jpg)    


最后结果如下:     
![/images/2015_05_06_16_24_52_891x430.jpg](/images/2015_05_06_16_24_52_891x430.jpg)    

### 总结
非HA方式部署，需要花费内存为:     
3+3+2+2=10G, 再加上Fuel Controller本身的3G,在16G的台式机上可以做到。    
