provider "openstack" {}

resource "openstack_compute_instance_v2" "salt-master" {
  count = "1"
  name = "salt-master"
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

}
