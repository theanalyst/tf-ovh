provider "openstack" {}

data "template_file" "master-bootstrap" {
  template = "${file("master-bootstrap.tpl")}"
  vars {
    master_ip = "${var.master_ip}"
  }
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
  }
  provisioner "remote-exec" {
    inline = [
      "zypper --quiet --non-interactive in salt-minion",
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
}
