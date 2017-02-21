variable "base_configuration" {
  description = "use ${module.base.configuration}, see main.tf.libvirt.example"
  type = "map"
}

variable "name" {
  description = "hostname, without the domain part"
  type = "string"
}

variable "image" {
  description = "One of: opensuse422, sles11sp3, sles11sp4, sles12, sles12sp1, centos7"
  type = "string"
}

variable "count"  {
  description = "number of hosts like this one"
  default = 1
}

variable "memory" {
  description = "RAM memory in MiB"
  default = 512
}

variable "vcpu" {
  description = "number of virtual CPUs"
  default = 1
}

variable "running" {
  description = "whether this host should be turned on or off"
  default = true
}

variable "mac" {
  description = "a MAC address in the form AA:BB:CC:11:22:22"
  default = ""
}

variable "additional_disk" {
  description = "disk block definition(s) to be added to this host"
  default = []
}

variable "grains" {
  description = "custom grain string to be added to this host's configuration"
  default = ""
}

variable "extra_repos" {
  description = "extra repositories used for installation {label = url}"
  default = {}
}

variable "extra_pkgs" {
  description = "extra packages which should be installed"
  default = []
}
