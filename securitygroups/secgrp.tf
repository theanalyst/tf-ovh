resource "openstack_networking_secgroup_v2" "ssh-http" {
  name = "ssh-http"
  description = "allow only ssh and sec. group traffic from outside"
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 22
  port_range_max = 22
  security_group_id = "${openstack_networking_secgroup_v2.ssh-http.id}"
}

resource "openstack_networking_secgroup_rule_v2" "http" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 80
  port_range_max = 80
  security_group_id = "${openstack_networking_secgroup_v2.ssh-http.id}"
}
