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

if [ ${deepsea_install_from_git} -ne 0 ]
then
    sudo zypper --non-interactive in git-core make rpm-build
    cd ~ && git clone ${deepsea_git_remote} deepsea && cd deepsea
    git checkout ${deepsea_ref}
    mkdir -p ~/rpmbuild/SOURCES/ ~/rpmbuild/RPMS
    echo "%_topdir %{getenv:HOME}/rpmbuild" > ~/.rpmmacros
    #make install && make rpm
    make tarball && rpmbuild --define '_topdir /root/rpmbuild' -bb deepsea.spec
    cd ~/rpmbuild/RPMS/noarch && rpm -iF deepsea*.rpm && touch done
else
    sudo zypper --non-interactive in deepsea
fi
mkdir -p /srv/pillar/ceph/proposals && chown -R salt:salt /srv/pillar/ceph/proposals
echo "master_minion: ${prefix}-salt-master" > /srv/pillar/ceph/master_minion.sls
cat <<EOF > /srv/pillar/ceph/proposals/policy.cfg
cluster-ceph/cluster/*.sls
# Hardware Profile
profile*/cluster/*.sls
profile*/stack/default/ceph/minions/*yml
# Common configuration
config/stack/default/global.yml
config/stack/default/ceph/cluster.yml
# Role assignment
role-master/cluster/*-salt-master.sls
role-mon/cluster/*-salt-minion-[012].sls
role-admin/cluster/*.sls
#role-igw/cluster/*.sls
role-mon/stack/default/ceph/minions/*-salt-minion-[012].yml
EOF
#mkdir -p /srv/pillar/ceph/proposals/config/ && chown -R salt:salt /srv/pillar/ceph/proposals/config

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
