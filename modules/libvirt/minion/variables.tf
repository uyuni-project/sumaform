variable "name" {
  description = "hostname, without the domain part"
  type = "string"
}

variable "image" {
  description = "One of: sles11sp3, sles11sp4, sles12, sles12sp1"
  type = "string"
}

variable "server" {
  description = "Use ${module.<SERVER_MODULE_NAME>.hostname}, see main.tf.libvirt.example"
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

variable "domain" {
  description = "hostname's domain"
  default = "tf.local"
}
