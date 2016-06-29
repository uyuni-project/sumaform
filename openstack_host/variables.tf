variable "openstack_tenant_name" {
    description = "The name of the Tenant."
    default  = "openstack"
}

variable "openstack_auth_url" {
    description = "The endpoint url to connect to OpenStack."
    default  = "***REMOVED***.0"
}

variable "tenant_network" {
    description = "The network to be used."
    default  = "8cce38fd-443f-4b87-8ea5-ad2dc184064f"
}

# TODO: instead of root/vagrant
#variable "openstack_keypair" {
#    description = "The keypair to be used."
#    default  = ""
#}

variable "avahi-domain" {
  default = "vagrant.local"
}
