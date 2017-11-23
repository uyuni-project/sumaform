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

variable "use_avahi" {
  description = "use false only if you use bridged networking with static MACs and an external DHCP"
  default = true
}

variable "domain" {
  description = "hostname's domain"
  default = "tf.local"
}

variable "name_prefix" {
  description = "a prefix for all names of objects to avoid collisions. Eg. moio-"
  default = ""
}

variable "images" {
  description = "list of images to be uploaded to the libvirt host, leave default for all"
  default = ["centos7",  "opensuse422",  "sles11sp3",  "sles11sp4",  "sles12",   "sles12sp1",  "sles12sp2", "sles12sp3", "sles15"]
  type = "list"
}

variable "image_locations" {
  description = "list of locations to download images, override to add custom ones"
  default = {
    centos7 = "http://w3.nue.suse.com/~smoioli/sumaform-images/centos7_v2.qcow2"
    opensuse422 = "http://download.opensuse.org/repositories/home:/SilvioMoioli:/Terraform:/Images/images/opensuse422.x86_64.qcow2"
    sles11sp3 = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles11sp3.x86_64.qcow2"
    sles11sp4 = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles11sp4.x86_64.qcow2"
    sles12 = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12.x86_64.qcow2"
    sles12sp1 = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp1.x86_64.qcow2"
    sles12sp2 = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp2.x86_64.qcow2"
    sles12sp3 = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles12sp3.x86_64.qcow2"
    sles15 = "http://download.suse.de/ibs/Devel:/Galaxy:/Terraform:/Images/images/sles15b3.x86_64.qcow2"
  }
  type = "map"
}
