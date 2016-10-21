variable "name" {
  description = "hostname, without the domain part"
  type = "string"
}

variable "image_id" {
  description = "${module.sles11sp3.id} for 2.1 or ${module.sles12sp1.id} for 3.0 and head"
  type = "string"
}

variable "version" {
  description = "One of: 2.1-stable,  2.1-nightly, 3-nightly, 3-stable, head"
  type = "string"
}

variable "cc_username" {
  description = "Username for the Customer Center"
  type = "string"
}

variable "cc_password" {
  description = "Password for the Customer Center"
  type = "string"
}

variable "database" {
  description = "oracle or postgres for 2.1, postgres or pgpool for 3 and head"
  default = "postgres"
}

variable "package_mirror" {
  description = "Use ${module.package_mirror.hostname} or leave the default for no package mirror"
  default = "null"
}

variable "iss_master" {
  description = "ISS master server, leave the default for no ISS"
  default = "null"
}

variable "iss_slave" {
  description = "ISS slave server, leave the default for no ISS"
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
