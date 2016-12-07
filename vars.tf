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
variable "master_ip" {
  "default" = "192.168.2.10"
}
variable "login_user" {
  "default" = "root"
}
