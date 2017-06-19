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

variable "additional_repos" {
  description = "extra repositories in the form {label = url}, see README_ADVANCED.md"
  default = {}
}

variable "additional_packages" {
  description = "extra packages to install, see README_ADVANCED.md"
  default = []
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
  }
  type = "map"
}

variable "images" {
  description = "list of images to be uploaded to the libvirt host, leave default for all"
  default = ["centos7",  "opensuse422",  "sles11sp3",  "sles11sp4",  "sles12",   "sles12sp1",  "sles12sp2"]
  type = "list"
}
