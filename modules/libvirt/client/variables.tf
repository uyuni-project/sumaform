variable "name" {
  description = "hostname, without the domain part"
  type = "string"
}

variable "image_id" {
  description = "One of: ${modules.sles11sp3.id}, ${modules.sles11sp4.id}, ${modules.sles12.id}, ${modules.sles12sp1.id}"
  type = "string"
}

variable "server" {
  description = "Use ${module.<SERVER_NAME>.hostname}, see main.tf.libvirt.example"
  type = "string"
}

variable "count"  {
  description = "number of hosts like this one"
  default = 1
}

variable "package_mirror" {
  description = "Use ${module.package_mirror.hostname} or leave the default for no package mirror"
  default = "null"
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

variable "pool" {
  description = "libvirt storage pool name for this host's disk"
  default = "default"
}

variable "bridge" {
  description = "a bridge device name available on the libvirt host, leave default for NAT"
  default = ""
}

variable "mac" {
  description = "a MAC address, in the form AA:BB:CC:11:22:22, only if bridge is specified"
  default = ""
}

variable "domain" {
  description = "hostname's domain"
  default = "tf.local"
}

variable "name_prefix" {
  description = "A prefix for names of objects created by this module"
  default = ""
}
