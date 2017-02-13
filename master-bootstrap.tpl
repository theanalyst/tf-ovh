#!/bin/bash
cat <<EOF > /etc/sysconfig/network/ifcfg-eth1
BOOTPROTO='static'
BROADCAST=''
ETHTOOL_OPTIONS=''
IPADDR='${master_ip}/24'
MTU=''
NAME='Ethernet Card 1'
NETWORK=''
REMOTE_IPADDR=''
STARTMODE='auto'
EOF

sudo ip addr add ${master_ip}/24 dev eth1
sudo ip link set eth1 up


sudo zypper ref && sudo zypper --non-interactive up
sudo zypper --non-interactive in salt-master salt-minion
systemctl enable salt-master.service
systemctl enable salt-minion.service

if $deepsea_install_from_git
then
    cd ~ && git clone $deepsea_git_remote
    cd $deepsea && git checkout $deepsea_ref && sudo make install
else
    sudo zypper --non-interactive in deepsea
fi
echo "master_minion: ${prefix}-salt-master" > /srv/pillar/ceph/master_minion.sls
#sed -i 's/.localdomain//' /srv/pillar/ceph/master_minion.sls
echo "${prefix}-salt-master" > /etc/salt/minion_id
echo "master: ${master_ip}" > /etc/salt/minion.d/minion.conf
echo "autosign_file: /etc/salt/autosign_hosts.conf" > /etc/salt/master.d/autosign.conf
echo "*" > /etc/salt/autosign_hosts.conf
systemctl start salt-master.service
systemctl start salt-minion.service
if ! rpm -q --last kernel-default | head -1 | grep -q $(uname -r | awk -F '-d' '{print $1}')
then
    reboot
fi
