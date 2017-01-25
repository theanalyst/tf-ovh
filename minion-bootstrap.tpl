#!/bin/bash
cat <<EOF > /etc/sysconfig/network/ifcfg-eth1
BOOTPROTO='static'
BROADCAST=''
ETHTOOL_OPTIONS=''
IPADDR='${minion_ip}/24'
MTU=''
NAME='Ethernet Card 1'
NETWORK=''
REMOTE_IPADDR=''
STARTMODE='auto'
EOF

zypper --non-interactive up kernel-default
zypper --quiet --non-interactive in salt-minion
echo ${node_name} > /etc/salt/minion_id
echo "master: ${master_ip}" > /etc/salt/minion.d/minion.conf
ip addr add ${minion_ip}/24 dev eth1
ip link set eth1 up
systemctl enable salt-minion
systemctl start salt-minion
