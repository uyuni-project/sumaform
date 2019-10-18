variable "cc_username" {
  description = "username for the Customer Center"
  type = "string"
}

variable "cc_password" {
  description = "password for the Customer Center"
  type = "string"
}

variable "timezone" {
  description = "Timezone setting for all VMs"
  default = "Europe/Berlin"
}

variable "ssh_key_path" {
  description = "path of pub ssh key you want to use to access VMs, see libvirt/README.md"
  default = "~/.ssh/id_rsa.pub"
}

variable "mirror" {
  description = "hostname of the mirror host or leave the default for no mirror"
  default = "null"
}

variable "use_mirror_images" {
  description = "use true download images from a mirror host"
  default = false
}

variable "use_avahi" {
  description = "use false only if you use bridged networking with static MACs and an external DHCP"
  default = true
}

variable "domain" {
  description = "hostname's domain"
  default = "tf.local"
}

variable "name_prefix" {
  description = "a prefix for all names of objects to avoid collisions. E.g. moio-"
  default = ""
}

variable "use_shared_resources" {
  description = "use true to avoid deploying images, mirrors and other shared infrastructure resources"
  default = false
}

variable "testsuite" {
  description = "true to enable specific setup for the integration testsuite"
  default = false
}

variable "additional_network" {
  description = "additional network in CIDR notation, leave empty if none"
  default = ""
}

// Provider-specific variables

variable "pool" {
  description = "libvirt storage pool name for VM disks"
  default = "default"
}

variable "network_name" {
  description = "libvirt NAT network name for VMs, use empty string for bridged networking"
  default = "default"
}

variable "bridge" {
  description = "a bridge device name available on the libvirt host, leave default for NAT"
  default = ""
}

variable "images" {
  description = "list of images to be uploaded to the libvirt host, leave default for all"
  default = ["centos7", "opensuse150", "opensuse151", "sles15", "sles15sp1", "sles11sp4", "sles12", "sles12sp1", "sles12sp2", "sles12sp3", "sles12sp4", "ubuntu1804"]
  type = "list"
}
