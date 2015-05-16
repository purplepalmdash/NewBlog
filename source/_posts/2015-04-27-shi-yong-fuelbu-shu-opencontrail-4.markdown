---
layout: post
title: "使用Fuel部署OpenContrail(4)"
date: 2015-04-27 19:44
comments: true
categories: Virtualization
---
前面已经准备好了集成OpenContrail的所有事宜，接下来就是真正部署OpenContrail的过程了。部署OpenContrail需要修改所有的Contrail Controller节点，OpenStack Controller节点， OpenStack Compute节点，为了避免混淆，本节主要完成在Contrail Controller上的部署工作。   
### OpenStack Controller节点部署后配置
在所有的OpenStack Controller节点(OS1,OS2,OS3)上，打开/usr/lib/ocf/resource.d/mirantis/ns_haproxy文件，编辑以下字段:   
OCF_Parameters部分:    

```
OCF_RESKEY_private_network_default="10.55.55.0/24"
OCF_RESKEY_private_network_gateway_default="10.55.55.1"

```   
在meta_data()函数中，添加以下内容:    

```
<parameter name="private_network">
<longdesc lang="en">
Private L3 network that should be configured inside the namespace
</longdesc>
<shortdesc lang="en">Namespace private network</shortdesc>
<content type="string" default="${OCF_RESKEY_private_network_default}" />
</parameter>

<parameter name="private_network_gateway">
<longdesc lang="en">
Private L3 network gateway that should be configured inside the namespace.
</longdesc>
<shortdesc lang="en">Namespace private gateway network</shortdesc>
<content type="string" default="${OCF_RESKEY_private_network_gateway_default}" />
</parameter>

```
set_ns_routing()函数中，添加一下内容:    

```
nsip route list | grep -q "${OCF_RESKEY_private_network}"
if [ $? -gt 0 ]; then
ocf_log debug "Creating ${OCF_RESKEY_private_network} route inside the namespace"
ocf_run nsip route add "${OCF_RESKEY_private_network}" via "${OCF_RESKEY_private_network_gateway}"
fi

```
以上的修改是为了引入haproxy的namespace的。     

### 配置Contrail部署节点
我们引入了三个Contrail Controller节点，从中挑选一个，作为部署的管理节点，OpenContrail通过fabric下发安装指令给各节点机，因此我们首先要准备的是部署节点。这里的例子中，我们选择Contrail1(10.20.0.10)作为部署节点。    

```
# echo 'deb http://10.20.0.2:8080/contrail/ /' > /etc/apt/sources.list.d/contrail.list
# echo -e "Package: *\nPin: release l=Ubuntu\nPin-Priority: 100" > /etc/apt/preferences
# >/etc/apt/sources.list
# apt-get update
# apt-get install -y python-paramiko contrail-fabric-utils contrail-setup
# pip install --upgrade --no-deps --index-url=”” /opt/contrail/python_packages/Fabric-1.7.0.tar.gz

```
apt-get udpate前我们需要清空本机上的sources.list文件，因为经过前两步后，本机的sources.list中会加上10.20.0.2的默认源，这会引发update失败，因此我们清空此文件。    
安装完一些准备包后，部署节点进入就绪状态。    

### 编写testbed.py
testbed.py文件定义了整个OpenContrail的组建部署节点信息，在编写此文件前，我们需要得到以下信息:    
A. OpenStack的Service_Token, 在任何一台OpenStack Controller机器上，运行以下命令以得到系统当前的service_token值:    

```
root@node-20:~# cat /etc/keystone/keystone.conf  | grep -i "admin_token=" | more
#admin_token=ADMIN
admin_token=rVlaAKUs

```
记下rVlaAKUs这个值，在testbed.py文件中我们会用到。    

B. OpenStack Controller的Public vip和Management vip, 如下所示，结合我们的网络规划，Public vip是172网段，而Management vip则是10.55.55网段的IP:    

```
root@node-20:~# source /root/openrc 
root@node-20:~# keystone endpoint-list | grep 5000
| 0e3c0684e8ae4c9fa4e080c9e1c66513 | RegionOne |         http://172.16.0.4:5000/v2.0          |         http://10.55.55.4:5000/v2.0          |       http://10.55.55.4:35357/v2.0      | f822df80ee1042d9b10d57118bb410aa |


```

C. Contrail Controller的内部vip和外部vip, 因为我们把Contrail Controller的Private IP分配在10.77.77.0/24网段，所以我们暂时选用10.77.77.9作为两个vip的地址。    

D. 如果有外部路由器，则需要配置外部路由器的IP地址。这次的部署中我们不采用外部路由器，因而对比于官方的推荐配置文件，我们的testbed.py中删除了这一部分。    

综合考虑到上述因素后，我们的testbed.py文件定义如下:    

```
root@node-24:~# vim /opt/contrail/utils/fabfile/testbeds/testbed.py|more
from fabric.api import env
#Management ip addresses of hosts in the cluster
os_ctrl01 = 'root@10.55.55.6'
os_ctrl02 = 'root@10.55.55.7'
os_ctrl03 = 'root@10.55.55.8'
c_ctrl01 = 'root@10.77.77.10'
c_ctrl02 = 'root@10.77.77.11'
c_ctrl03 = 'root@10.77.77.12'
c_db01 = 'root@10.77.77.10'
c_db02 = 'root@10.77.77.11'
c_db03 = 'root@10.77.77.12'
#External routers
# ext_routers = [('gateway01', '<Gateway_node1_LOOPBACK_ip>'), ('gateway02', '<Gateway_node2_LOOPBACK_ip>')]
#Autonomous system number
router_asn = 64512
#Host from which the fab commands are triggered to install and provision
deploy_node = 'root@10.77.77.10'
#Role definition of the hosts.
env.roledefs = {
'all': [c_ctrl01, c_ctrl02, c_ctrl03, c_db01, c_db02, c_db03],
'cfgm': [c_ctrl01, c_ctrl02, c_ctrl03],
'openstack': [os_ctrl01, os_ctrl02, os_ctrl03],
'control': [c_ctrl01, c_ctrl02, c_ctrl03],
'compute': [],
'collector': [c_ctrl01, c_ctrl02, c_ctrl03],
'webui': [c_ctrl01, c_ctrl02, c_ctrl03],
'database': [c_db01, c_db02, c_db03],
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
os_ctrl02: 'r00tme',
os_ctrl03: 'r00tme',
c_ctrl01: 'r00tme',
c_ctrl02: 'r00tme',
c_ctrl03: 'r00tme',
c_db01: 'r00tme',
c_db02: 'r00tme',
c_db03: 'r00tme',
deploy_node: 'r00tme',
}
#For reimage purpose
env.ostypes = {
os_ctrl01: 'ubuntu',
os_ctrl02: 'ubuntu',
os_ctrl03: 'ubuntu',
c_ctrl01: 'ubuntu',
c_ctrl02: 'ubuntu',
c_ctrl03: 'ubuntu',
c_db01: 'ubuntu',
c_db02: 'ubuntu',
c_db03: 'ubuntu',
deploy_node: 'ubuntu',
}
env.openstack = {
'service_token' : 'rVlaAKUs'
}
env.ha = {
'internal_vip': '10.55.55.4',
'external_vip': '172.16.0.4',
'contrail_internal_vip': '10.77.77.9',
'contrail_external_vip': '10.77.77.9',
}
env.keystone = {
'service_tenant': 'services',
'admin_token': 'rVlaAKUs',
}
multi_tenancy = True

```
编写完testbed.py文件后，就可以根据文件中的定义，部署OpenContrail的组件到多台节点主机了。    
Fuel Controller节点上的id_rsa文件可以实现对各个节点的无密码登录，拷贝它到我们的Contrail部署节点上:    

```
# scp 10.20.0.2:/root/.ssh/id_rsa /root/.ssh/id_rsa
# chmod 0600 /root/.ssh/id_rsa

```
### 部署多节点
首先切换到/opt/contrail/utils目录下，所有用fab执行的部署都需要在这个目录下执行。执行以下操作, 以初始化各部署子节点:    

```
# cd /opt/contrail/utils
# fab -P -R control -w -- "ls /etc/apt/sources.list.d/contrail.list || echo 'deb \
http://10.20.0.2:8080/contrail/ /' > \
/etc/apt/sources.list.d/contrail.list"
# fab -P -R control -w -- 'ls /etc/apt/preferences || echo -e "Package: *\nPin: release \
l=Ubuntu\nPin-Priority: 100" > /etc/apt/preferences'
# fab -P -R control -w -- 'DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes \
--allow-unauthenticated install python-crypto python-netaddr python-paramiko \
contrail-fabric-utils contrail-setup'
# fab -P -R control -w -- 'pip install --upgrade --no-deps --index-url="" \
/opt/contrail/python_packages/ecdsa-0.10.tar.gz'
# fab -P -R control -w -- 'pip install --upgrade --no-deps --index-url="" \
/opt/contrail/python_packages/Fabric-1.7.0.tar.gz'

```
如果出现apt-get update的问题，可以如上面提到的，手动登录到各个节点上去清空/etc/apt/sources.list文件，当然一般情况下不会出现这个问题。    
运行以下命令，接受sun的协议:    

```
# fab -P -R control -w -- 'echo "sun-java6-plugin shared/accepted-sun-dlj-v1-1 boolean \
true" | /usr/bin/debconf-set-selections' && fab -P -R control -w -- 'echo "sun-java6-bin shared/accepted-sun-dlj-v1-1 boolean \
 true" | /usr/bin/debconf-set-selections' && fab -P -R control -w -- 'echo "debconf shared/accepted-oracle-license-v1-1 select \
true" | sudo debconf-set-selections' && fab -P -R control -w -- 'echo "debconf shared/accepted-oracle-license-v1-1 seen \
 true" | sudo debconf-set-selections'

```
OpenContrail组件依赖于特定版本的tzdata， 用以下命令安装：    

```
# fab -P -R control -w -- 'DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes \
 --allow-unauthenticated install tzdata=2014e-0ubuntu0.12.04'

```
安装和设置database, 并检查节点的状态:   

```
 # fab install_database && fab setup_database
 # fab -R database -w -- "contrail-status"
 # nodetool status
--  Address      Load       Tokens  Owns   Host ID                               Rack
UN  10.77.77.12  141.84 MB  256     33.3%  4ea3abec-16ee-417a-b78c-69e8dca292be  rack1
UN  10.77.77.11  141.33 MB  256     35.8%  d7677bf2-1447-48af-b1d4-356b4a8d6cff  rack1
UN  10.77.77.10  134.28 MB  256     30.9%  e418e4ef-af22-4874-ad94-777d6b4c511c  rack1

```
当看到上面有三个条目时，代表安装成功，可以进行下一步。     

安装cfgm, control, collector, webui 组件以及keepalived集群。    

```
# fab install_cfgm && fab install_control && fab install_collector && fab install_webui && fab setup_contrail_keepalived && fab fixup_restart_haproxy_in_collector 2>&1 | tee all.txt

```
删除掉/etc/keepalived/keepalived.conf里的EXTERNAL部分, 值得注意的是，在三个Contrail Controller上，都需要执行此操作:     

```
# vim /etc/keepalived/keepalived.conf
......remove something......

```
删除以后，重新启动keepalived服务:     

```
# fab -P -R control -w -- 'service keepalived restart'

```
更新haproxy的配置文件，添加WebUI的虚拟IP地址(vip). 值得注意的是，在三个Contrail Controller上，都需要执行此操作:    

```
# vim /etc/haproxy/haproxy.cfg
#contrail-webui-marker-start
frontend contrail-webui-api *:443
    mode tcp
    default_backend contrail-webui-api
backend contrail-webui-api
    mode tcp
    balance roundrobin
    option nolinger
    stick on src
    stick-table type ip size 200k expire 300m
    option tcp-check
    tcp-check connect port 8143
    default-server error-limit 1 on-error mark-down
    server 10.77.77.10 10.77.77.10:8143 check inter 2000 rise 2 fall 3
    server 10.77.77.11 10.77.77.11:8143 check inter 2000 rise 2 fall 3
    server 10.77.77.12 10.77.77.12:8143 check inter 2000 rise 2 fall 3
#contrail-webui-marker-end

```
更改完以后，重启haproxy服务:    

```
# fab -P -R control -w -- 'service haproxy restart'

```
更改每个节点上的tenant服务名称，从'service'改成'services':    

```
# fab -P -R control -w -- "sed -i '49s/service/services/g' \
/usr/local/lib/python2.7/dist-packages/contrail_provisioning/config/quantum_in_keystone_setup.py"

```
配置cfgm服务:    

```
# fab setup_cfgm

```
这时我们可以验证neutron endpoint是否被正确安装，在任何一个OpenStack Controller节点上，运行以下命令:    

```
# keystone service-list
# keystone endpoint-list

```
例如:    

```
root@node-20:~# keystone service-list | grep neutron
| 2f4c887f68a9428aa448cbd688d7061f | neutron  |    network     |             network              |
root@node-20:~# keystone endpoint-list | grep 2f4c887f68a9428aa448cbd688d7061f
| 7dd2c25e69ad4a3296f272aa253001c8 | RegionOne |            http://10.77.77.9:9696            |            http://10.77.77.9:9696            |          http://10.77.77.9:9696         | 2f4c887f68a9428aa448cbd688d7061f |

```
成功的话，接着下一步设置，删除所有的Contrail Controller节点上文件/etc/haproxy/haproxy.cfg里的rabbit字段：     

```
# vim /etc/haproxy/haproxy.cfg
......remove something......

```
重新启动haproxy服务:     

```
# fab -P -R control -w -- 'service haproxy restart'

```
设置control,collector,webui组件服务:     

```
# fab setup_control
# fab setup_collector && fab setup_webui

```
在任一OpenStack Controller节点上，运行以下命令，得到rabbit的密码:     

```
root@node-22:~# cat /etc/rabbitmq/rabbitmq.config | grep default_pass
    {default_pass,        <<"gYFQP10P">>},

```
配置neutron插件，使用运行在OpenStack Controller上的rabbit 集群, 这里的rabbit_password使用上面得到的值:     

```
#  fab -P -R control -w -- 'openstack-config --del /etc/neutron/neutron.conf DEFAULT rabbit_host'
#  fab -P -R control -w -- 'openstack-config --set /etc/neutron/neutron.conf DEFAULT rabbit_hosts \
  10.55.55.6:5673,10.55.55.7:5673,10.55.55.8:5673'
#  fab -P -R control -w -- 'openstack-config --set /etc/neutron/neutron.conf DEFAULT rabbit_userid \
   nova'
#  fab -P -R control -w -- 'openstack-config --set /etc/neutron/neutron.conf DEFAULT \
  rabbit_password gYFQP10P'
# fab -P -R control -w -- 'service neutron-server restart'

```
配置contrail-api以使用运行在OpenStack Controller上的rabbit集群:     

```
# fab -P -R control -w -- 'perl -pi -e \
 "s/rabbit_server.*$/rabbit_server=10.55.55.4/" /etc/contrail/contrail-api.conf'
# fab -P -R control -w -- 'perl -pi -e "s/rabbit_port.*$/rabbit_port=5672/" \
 /etc/contrail/contrail-api.conf'
# fab -R control -w -- "perl -pi -e 'print \"rabbit_password=gYFQP10P\n\" \
 if \$_ =~ rabbit_port' /etc/contrail/contrail-api.conf"
# fab -P -R control -w -- "perl -pi -e 'print \"rabbit_user=nova\n\" if \$_ =~ rabbit_port' \
 /etc/contrail/contrail-api.conf"
# fab -P -R control -w -- "service contrail-api restart"

```
使用前面下载的OpenContrail 插件，作为neutron挂载的插件, 或者你可以直接从github克隆下来:    

```
# mkdir -p /tmp/contrail-repo
# apt-get install -y git
# git clone https://github.com/Juniper/contrail-neutron-plugin.git /tmp/contrail-repo
# cd /tmp/contrail-repo
# git checkout 3189155
# cp -r /tmp/contrail-repo/neutron_plugin_contrail/plugins/opencontrail \
/usr/share/pyshared/neutron_plugin_contrail/plugins/

```
重新启动neutron-service:   

```
# cd /opt/contrail/utils
# fab -P -R cfgm -w -- 'service neutron-server restart'

```
设置Contrail Controller之间的BGP节点发现，metadata服务及encapsulation类型:    

```
# fab prov_control_bgp && fab prov_metadata_services && fab prov_encap_type

```
用以下命令验证安装是否成功:    

```
# fab verify_cfgm
# fab verify_control
# fab verify_collector
# fab verify_webui
# fab -R control -w -- "contrail-status"

```
更新rc.d，这样在启动的时候，不会启动supervisor-support进程：     

```
# fab -P -R control -w -- 'update-rc.d supervisor-support-service disable'

```
用浏览器访问以下页面，以确认Contrail已经被正确安装:      
[https://10.77.77.9](https://10.77.77.9)     
此时你看到的页面应该如下：     
![/images/2015_04_27_21_49_07_1006x746.jpg](/images/2015_04_27_21_49_07_1006x746.jpg)     

本章过完以后，我们的OpenContrail部署已经完成了大半，接下来就是在Compute和OpenStack Controller节点上的配置，达到最后的集成过程。
