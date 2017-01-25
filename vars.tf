variable "key_pair" {
  "default" = "abhi-keys"
}
variable "image_name"{
  "default" = "ses4"
}
variable "master_flavor" {
  "default" = "vps-ssd-1"
}
variable "vm_name_prefix" {
  "default" = "tf"
}
# this should be in the same subnet you create in vRACK
variable "master_subnet" {
  "default" = "192.168.2.0/24"
}

variable "master_ip" {
  "default" = "10"
}

variable "minion_ip" {
  "default" = "192.168.2.101"
}

variable "login_user" {
  "default" = "root"
}
variable "minion_count" {
  "default" = "4"
}

variable "minion_block_size" {
  "default" = "10"
}

variable "minion_block_name" {
  "default" = "osd."
}
