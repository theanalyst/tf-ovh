provider "openstack" {}

data "template_file" "master-bootstrap" {
  template = "${file("master-bootstrap.tpl")}"
  vars {
    master_ip = "${var.master_ip}"
    prefix = "${var.vm_name_prefix}"
  }
}

resource "openstack_blockstorage_volume_v2" "minion-blk" {
  count = "${var.minion_count}",
  size = "${var.minion_block_size}"
  name = "${var.vm_name_prefix}-${var.minion_block_name}${count.index}"
}

resource "openstack_compute_instance_v2" "salt-master" {
  count = "1"
  name = "${var.vm_name_prefix}-salt-master"
  key_pair = "${var.key_pair}"
  image_name = "${var.image_name}"
  flavor_name = "${var.master_flavor}"
  network  {
    name = "Ext-Net"
    access_network = true
  }
  network {
    name = "VLAN"
    fixed_ip_v4 = "${var.master_ip}"
  }
  user_data = "${data.template_file.master-bootstrap.rendered}"
}

resource "openstack_compute_instance_v2" "salt-minion" {
  count = "${var.minion_count}"
  name = "${var.vm_name_prefix}-salt-minion-${count.index}"
  key_pair = "${var.key_pair}"
  image_name = "${var.image_name}"
  flavor_name = "${var.master_flavor}"
  network  {
    name = "Ext-Net"
    access_network = true
  }
  network {
    name = "VLAN"
  }
  # Ideally we'd love to use template user-data here, however
  # tf prevents the use of self vars in template, we'd have to come up
  # with fixed vm ips otherwise
  provisioner "remote-exec" {
    inline = [
      "zypper --quiet --non-interactive in salt-minion",
      "echo ${self.name} > /etc/salt/minion_id", # all names are sles.suse.de otherwise :/
      "echo \"master: ${var.master_ip}\" > /etc/salt/minion.d/minion.conf",
      "ip addr add ${self.network.1.fixed_ip_v4}/24 dev eth1",
      "ip link set eth1 up",
      "systemctl enable salt-minion",
      "systemctl start salt-minion"
    ]
    connection{
      type = "ssh"
      user = "${var.login_user}"
      agent = true
    }
  }

  volume {
    volume_id = "${element(openstack_blockstorage_volume_v2.minion-blk.*.id, count.index)}"
  }
}

output "master-ip" {
  value = "${openstack_compute_instance_v2.salt-master.0.access_ip_v4}"
}

output "minion_ips" {
  value = "${join(" ", openstack_compute_instance_v2.salt-minion.*.access_ip_v4)}"
}
