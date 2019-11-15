// base
variable "cc_username" {
  description = "username for the Customer Center"
  type        = string
}

variable "cc_password" {
  description = "password for the Customer Center"
  type        = string
}

variable "use_avahi" {
  description = "use false only if you use bridged networking with static MACs and an external DHCP"
  default     = true
}

variable "domain" {
  description = "hostname's domain"
  default     = "tf.local"
}

variable "name_prefix" {
  description = "a prefix for all names of objects to avoid collisions. E.g. moio-"
  default     = ""
}

variable "images" {
  description = "list of images to be uploaded to the libvirt host, leave default for all"
  default     = ["centos7", "opensuse150", "opensuse151", "sles15", "sles15sp1", "sles11sp4", "sles12", "sles12sp1", "sles12sp2", "sles12sp3", "sles12sp4", "ubuntu1804"]
}

variable "mirror" {
  description = "hostname of the mirror host or leave the default for no mirror"
  default     = "null"
}

variable "use_mirror_images" {
  description = "use true download images from a mirror host"
  default     = false
}

variable "use_shared_resources" {
  description = "use true to avoid deploying images, mirrors and other shared infrastructure resources"
  default     = false
}

// cucumber_testsuite
variable "proxy" {
  description = "whether or not to include a Proxy in the test"
  default     = true
}

variable "optional_clients" {
  description = "list of optional clients to test. Defaults to all"
  default     = ["min-centos7", "min-ubuntu1804", "minssh-sles12sp4", "min-pxeboot", "min-kvm"]
}

// srv
variable "product_version" {
  description = "One of: 3.2-nightly, 3.2-released, 4.0-nightly, 4.0-released, head, test, uyuni-released"
  type        = string
}

variable "from_email" {
  description = "email address used as sender for emails"
  default     = "null"
}

// ctl
variable "branch" {
  description = "Leave default for automatic selection or specify an existing branch of spacewalk"
  default     = "default"
}

variable "git_username" {
  description = "username for GitHub"
  type        = string
}

variable "git_password" {
  description = "password for GitHub"
  type        = string
}

variable "server_http_proxy" {
  description = "Hostname and port used by SUSE Manager http proxy"
  default     = ""
}

variable "saltapi_tcpdump" {
  description = "If set to true, all network operations of salt-api are logged to /tmp/ with tcpdump."
  default     = false
}

// provider
variable "provider_settings" {
  description = "Settings specific to the provider, see README_TESTING.md"
  type        = map(any)
  default = {
    libvirt = {
      // provider
      uri = "qemu:///system"
      // base
      pool               = "default"
      network_name       = "default"
      bridge             = ""
      additional_network = ""
      macs               = {}
    }
  }
}
