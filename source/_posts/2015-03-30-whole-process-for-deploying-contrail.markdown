---
layout: post
title: "Whole Process For Deploying Contrail"
date: 2015-03-30 18:20
comments: true
categories: 
---
Following are the steps, enjoy them:    

```
# First bootstrap the environment.   
juju bootstrap --metadata-source ~/.juju/metadata --upload-tools -v --show-log --constraints="mem=3G"

#####################################################
# Machine 0, hold 9 services. 3G mem. trusty
# Memory: 3G
# Service: 10
#####################################################


# Since machine 0 is ready for using, deploy services to this node via following commands:     
# Juju-gui is for monitoring the status and the components
# 1. juju-gui
juju deploy --to 0 --repository=/home/Trusty/charms/ local:trusty/juju-gui
# 2. rabbitmq-server
juju deploy --to lxc:0 --repository=/home/Trusty/charms/ local:trusty/rabbitmq-server
# 3. mysql
juju deploy --to lxc:0 --repository=/home/Trusty/charms/ local:trusty/mysql
# 4. keystone
juju deploy --to lxc:0 --repository=/home/Trusty/Code/deployOpenContrail/contrail-deployer/src/charms/ local:trusty/keystone
# 5. openstack-Trustyboard
juju deploy --to lxc:0 --repository=/home/Trusty/Code/deployOpenContrail/contrail-deployer/src/charms/ local:trusty/openstack-Trustyboard

# 6. nova-cloud-controller
juju deploy --to lxc:0 --repository=/home/Trusty/Code/deployOpenContrail/contrail-deployer/src/charms/ local:trusty/nova-cloud-controller --config=/home/Trusty/Code/deploy/nova-cloud-controller-config.yaml 
# 7. glance to lxc:0
juju deploy --to lxc:0 --repository=/home/Trusty/Code/deployOpenContrail/contrail-deployer/src/charms/ local:trusty/glance
# 8. contrail-configuration to lxc:0
juju deploy --to lxc:0 --repository=/home/Trusty/Code/deployOpenContrail/contrail-deployer/src/charms/ local:trusty/contrail-configuration
# 9. control-control to lxc:0
juju deploy --to lxc:0 --repository=/home/Trusty/Code/deployOpenContrail/contrail-deployer/src/charms/ local:trusty/contrail-control
# 10. neutron-api to lxc:0
juju deploy --to lxc:0 --repository=/home/Trusty/Code/deployOpenContrail/contrail-deployer/src/charms/ local:trusty/neutron-api --config=/home/Trusty/Code/deploy/neutron-api.yaml

# Now add the first node for nova-compute.   
juju set-constraints "mem=900M"
#####################################################
# Machine 1, hold nova-compute service, 2G with nested CPU, trusty
# Memory: 2G
# Service: 1
#####################################################

# Add name specified machine, which memory is 2048M, with cpu nested for kvm
juju add-machine MaasOpenContrail4
# Machine 1 will be added into the Juju environment, deploy nova-compute into this node
juju deploy --to 1 --repository=/home/Trusty/Code/deployOpenContrail/contrail-deployer/src/charms/ local:trusty/nova-compute

#####################################################
# Machine 2, hold neutron-gateway service, 1G , trusty
# Memory: 1G
# Service: 1
#####################################################
# Add neutron-gateway to 1G based machine , it may fail, so you could remove-machine, and re-add again. via `juju destroy-machine 2 --force`  
juju add-machine MaasOpenContrail7
juju deploy --to 4 --repository=/home/Trusty/Code/deployOpenContrail/contrail-deployer/src/charms/ local:trusty/quantum-gateway neutron-gateway

#####################################################
# Machine 3, hold cassandra and zookeeper serivce, 4G, precise.
# Memory: 4G
# Service: 2
#####################################################
# First we should change the default deployed system version to precise. 
juju set-environment default-series=precise
# Add new machine, whose memory is 4G.
juju add-machine MaasOpenContrail5
# Deploy cassandra to 4G Node
juju deploy --to 5 --repository=/home/Trusty/Code/deployOpenContrail/contrail-deployer/src/charms/ local:precise/cassandra --config=/home/Trusty/Code/deploy/cassandra.yaml
# Also use this machine for deploy a lxc based service, zookeeper, which is also based on precise.
juju deploy --to lxc:5 --repository=/home/Trusty/Code/deployOpenContrail/contrail-deployer/src/charms/ local:precise/zookeeper


# Well, set the default environment from precise to trusty
juju set-environment default-series=trusty

# Finally deploy  neutron-contrail
juju deploy --repository=/home/Trusty/Code/deployOpenContrail/contrail-deployer/src/charms/ local:trusty/neutron-contrail



#####################################################
#####################################################
# Well the deploy is finished, then add relationship
#####################################################
#####################################################
juju add-relation keystone mysql
juju add-relation nova-cloud-controller mysql
juju add-relation nova-cloud-controller rabbitmq-server
juju add-relation nova-cloud-controller glance
juju add-relation nova-cloud-controller keystone
juju add-relation neutron-gateway mysql
juju add-relation neutron-gateway:amqp rabbitmq-server:amqp
juju add-relation neutron-gateway nova-cloud-controller
juju add-relation nova-compute:shared-db mysql:shared-db
juju add-relation nova-compute:amqp rabbitmq-server:amqp
juju add-relation nova-compute glance
juju add-relation nova-compute nova-cloud-controller
juju add-relation glance mysql
juju add-relation glance keystone
juju add-relation openstack-Trustyboard keystone
juju add-relation neutron-api mysql
juju add-relation neutron-api rabbitmq-server
juju add-relation neutron-api nova-cloud-controller
juju add-relation neutron-api:identity-service keystone:identity-service
juju add-relation neutron-api:identity-admin keystone:identity-admin
juju add-relation contrail-configuration:cassandra cassandra:database
juju add-relation contrail-configuration zookeeper
juju add-relation contrail-configuration rabbitmq-server
juju add-relation contrail-configuration keystone
juju add-relation contrail-configuration neutron-gateway
juju add-relation neutron-api contrail-configuration
juju add-relation contrail-control contrail-configuration
juju add-relation nova-compute neutron-contrail
juju add-relation neutron-contrail contrail-control
juju add-relation neutron-contrail neutron-gateway
juju add-relation neutron-contrail contrail-configuration
juju add-relation neutron-contrail keystone


# change the passwd of OpenStack:    
juju set keystone admin-password="helloworld"

```


