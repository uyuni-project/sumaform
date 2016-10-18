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

variable "server" {
  description = "Main server for this host"
  default = "null"
}

variable "openstack_tenant_name" {
  description = "OpenStack's tenant name"
  type = "string"
}

variable "openstack_auth_url" {
  description = "OpenStack's authentication URL"
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

variable "iss-master" {
  description = "ISS master server, if any"
  default = "null"
}

variable "iss-slave" {
  description = "ISS slave server, if any"
  default = "null"
}

variable "package-mirror" {
  description = "package-mirror server, if any"
  default = "null"
}

variable "domain" {
  description = "hostname's domain"
  default = "tf.local"
}
