variable "name" {
  description = "hostname, without the domain part"
  type = "string"
}

variable "image" {
  description = "Name of the base OS image, see main.tf.libvirt.example"
  type = "string"
}

variable "version" {
  description = "Main product version (eg. 2.1-stable, 3-nightly, head)"
  default = "null"
}

variable "database" {
  description = "RDBMS name (eg. postgres, oracle, pgpool)"
  default = "null"
}

variable "role"  {
  description = "Name of the host role, see main.tf.libvirt.example"
  type = "string"
}

variable "count"  {
  description = "Number of hosts like this one"
  default = 1
}

variable "server_configuration" {
  description = "use ${module.<SERVER_NAME>.configuration}, see main.tf.openstack.example"
  default = { hostname = "null" }
}

variable "openstack_tenant_name" {
  description = "OpenStack's tenant name"
  type = "string"
}

variable "openstack_auth_url" {
  description = "OpenStack's authentication URL"
  type = "string"
}

variable "flavor" {
  description = "OpenStack image flavor: m1.medium, m1.small, etc."
  type = "string"
}

variable "cc_username" {
  description = "Username for the Customer Center"
  default = "null"
}

variable "cc_password" {
  description = "Password for the Customer Center"
  default = "null"
}

variable "iss_master" {
  description = "ISS master server, if any"
  default = "null"
}

variable "iss_slave" {
  description = "ISS slave server, if any"
  default = "null"
}

variable "additional_repos" {
  description = "extra repositories in the form {label = url}, see README_ADVANCED.md"
  default = {}
}

variable "additional_packages" {
  description = "extra packages to install, see README_ADVANCED.md"
  default = []
}

variable "domain" {
  description = "hostname's domain"
  default = "tf.local"
}
