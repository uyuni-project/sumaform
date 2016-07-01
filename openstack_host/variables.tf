variable "openstack_tenant_name" {
  description = "The name of the Tenant (eg: `openstack`)."
}

variable "openstack_auth_url" {
  description = "The endpoint url to connect to OpenStack (eg: `***REMOVED***.0`)."
}

variable "tenant_network" {
  description = "The network to be used (eg. `8cce38fd-443f-4b87-8ea5-ad2dc184064f`)."
}

variable "avahi-domain" {
  default = "vagrant.local"
}

variable "package-mirror" {
  default = "null"
}

variable "server" {
  default = "null"
}
