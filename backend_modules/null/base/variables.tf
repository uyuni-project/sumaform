variable "cc_username" {
  description = "username for the Customer Center"
  type        = string
  default     = null
}

variable "cc_password" {
  description = "password for the Customer Center"
  type        = string
  default     = null
}

variable "timezone" {
  description = "Timezone setting for all VMs"
  default     = "Europe/Berlin"
}

variable "use_ntp" {
  description = "use false if you don't want to run Network Time Protocol"
  default     = true
}

variable "ssh_key_path" {
  description = "path of pub ssh key you want to use to access VMs, see backend_modules/libvirt/README.md"
  default     = "~/.ssh/id_ed25519.pub"
}

variable "mirror" {
  description = "hostname of the mirror host or leave the default for no mirror"
  default     = null
}

variable "use_mirror_images" {
  description = "use true download images from a mirror host"
  default     = false
}

variable "use_avahi" {
  description = "use false only if you use bridged networking with static MACs and an external DHCP"
  default     = false
}

variable "domain" {
  description = "hostname's domain"
  default     = "tf.local"
}

variable "name_prefix" {
  description = "a prefix for all names of objects to avoid collisions. E.g. moio-"
  default     = ""
}

variable "use_shared_resources" {
  description = "use true to avoid deploying images, mirrors and other shared infrastructure resources"
  default     = false
}

variable "testsuite" {
  description = "true to enable specific setup for the integration testsuite"
  default     = false
}

variable "provider_settings" {
  description = "Map of provider-specific settings, see the backend_modules/libvirt/README.md"
  default     = {}
}

variable "images" {
  description = "list of images to be uploaded to the libvirt host, leave default for all"
  default     = [ "almalinux8o", "almalinux9o", "amazonlinux2o", "amazonlinux2023o", "centos7o", "libertylinux9o", "openeuler2403o", "opensuse155o", "opensuse156o", "tumbleweedo", "oraclelinux9o", "rocky8o", "rocky9o", "sles12sp5o", "sles15sp3o", "sles15sp4o", "sles15sp5o", "sles15sp6o", "sles15sp7o", "ubuntu2004o", "ubuntu2204o", "ubuntu2404o"]
  type        = set(string)
}

variable "use_eip_bastion" {
  description = "Use eip feature for bastion on AWS"
  default     = true
  type        = bool
}

variable "is_server_paygo_instance" {
  description = "specify if the server instance is a paygo instance"
  type        = bool
  default     = false
}

variable "product_version" {
  description = "One of: 4.3-nightly, 4.3-released, 4.3-pr, 4.3-VM-nightly, 4.3-VM-released, 5.0-nightly, 5.0-released, 5.1-nightly, 5.1-released, head, uyuni-master, uyuni-released, uyuni-pr"
  type        = string
  default     = ""
}

variable "salt_log_lvl_debug" {
  description = "Set salt log_level to debug"
  type        = bool
  default     = true
}