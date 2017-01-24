#!/bin/bash
sudo ip addr add ${master_ip}/24 dev eth1
sudo ip link set eth1 up
sudo zypper --non-interactive in salt-master salt-minion
systemctl enable salt-master.service
systemctl enable salt-minion.service
echo "${prefix}-salt-master" > /etc/salt/minion_id
echo "master: ${master_ip}" > /etc/salt/minion.d/minion.conf
echo "autosign_file: /etc/salt/autosign_hosts.conf" > /etc/salt/master.d/autosign.conf
echo "*" > /etc/salt/autosign_hosts.conf
systemctl start salt-master.service
systemctl start salt-minion.service
