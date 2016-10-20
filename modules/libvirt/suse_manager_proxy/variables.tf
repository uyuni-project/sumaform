variable "name" {
  description = "hostname, without the domain part"
  type = "string"
}

variable "version" {
  description = "One of: 2.1-stable,  2.1-nightly, 3-nightly, 3-stable, head"
  type = "string"
}

variable "server" {
  description = "Use ${module.<MODULE_NAME>.hostname}, see ADVANCED_MAIN_TF.md"
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
