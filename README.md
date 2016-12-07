# README

Simple terraform state to bring up a salt cluster on OVH. To try, source the
openrc file, set the correct OS_REGION etc. and then do 

$ terraform apply

This will bring up a cluster with one master and default 3 minions, right now an ssh key is not automatically created
(but terraform has provisions for this) so this has to be created before hand. 

All variables in vars.tf are customizable and can be overriden from the cli or via a simple conf file like 

```
$ cat myvars.tfvars
image_name=myimage
key_pair=mykey

```

 and then launching terraform with 
 
 $ terraform apply -var-file=myvars.tfvars
 
 
