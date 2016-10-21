variable "name" {
  description = "hostname, without the domain part"
  type = "string"
}

variable "image_id" {
  description = "${module.sles12sp1.id}, see README_ADVANCED.md"
  type = "string"
}

variable "package_mirror" {
  description = "Use ${module.package_mirror.hostname} or leave the default for no package mirror"
  default = "null"
}

variable "memory" {
  description = "RAM memory in MiB"
  default = 4096
}

variable "vcpu" {
  description = "Number of virtual CPUs"
  default = 2
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
