variable "name" {
  description = "hostname, without the domain part"
  type = "string"
}

variable "memory" {
  description = "RAM memory in MiB"
  default = 512
}

variable "vcpu" {
  description = "Number of virtual CPUs"
  default = 1
}

variable "running" {
  description = "Whether this host should be turned on or off"
  default = true
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

variable "cc_username" {
  description = "Username for the Customer Center"
  default = "null"
}

variable "cc_password" {
  description = "Password for the Customer Center"
  default = "null"
}

variable "libvirt_pool" {
  description = "libvirt storage pool name for this host's disk"
  default = "default"
}

variable "bridged" {
  description = "set to true to use a bridge device, specified with the bridge variable"
  default = false
}

variable "bridge" {
  description = "an existing bridge device on the libvirt host"
  default = "br0"
}

variable "domain" {
  description = "hostname's domain"
  default = "tf.local"
}
