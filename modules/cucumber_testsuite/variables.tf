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

variable "avahi_reflector" {
  description = "if using avahi, allow one minion to have a reflector configured"
  default     = false
}

variable "domain" {
  description = "domain of all hosts in this testsuite"
  default     = "tf.local"
}

variable "name_prefix" {
  description = "a prefix for all names of objects created by this testsuite to avoid collisions. E.g. moio-"
  default     = ""
}

variable "images" {
  description = "list of images to be uploaded to the libvirt host, leave default for all"
  default     = ["centos6o", "centos7o", "centos8o", "opensuse152o", "opensuse153o", "sles11sp4", "sles12", "sles12sp1", "sles12sp2", "sles12sp3", "sles12sp4o", "sles12sp5o", "sles15o", "sles15sp1o", "sles15sp2o", "sles15sp3o", "ubuntu1604o", "ubuntu1804o", "ubuntu2004o"]
}

variable "mirror" {
  description = "hostname of the mirror host or leave the default for no mirror"
  default     = null
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
variable "host_settings" {
  description = "Hosts and their specific properties, see README_TESTING.md"
  default = {
    suse-client = {
    }
    suse-minion = {
    }
  }
}

// server
variable "product_version" {
  description = "One of: 3.2-nightly, 3.2-released, 4.0-nightly, 4.0-released, 4.1-nightly, 4.1-released, 4.2-nightly, 4.2-released, head, test, uyuni-master, uyuni-released"
  type        = string
}

variable "from_email" {
  description = "email address used as sender for emails"
  default     = null
}

// controller
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

variable "git_repo" {
  description = "Git repo clone URL for testsuite code"
  default     = "default"
}

variable "git_profiles_repo" {
  description = "URL of git repository with alternate Docker and Kiwi profiles, see README_TESTING.md"
  default     = "default"
}

variable "no_auth_registry" {
  description = "URI of container registry server, see README_TESTING.md"
  default     = null
}

variable "auth_registry" {
  description = "URI of authenticated registry, see README_TESTING.md"
  default     = null
}

variable "auth_registry_username" {
  description = "username on registry, see README_TESTING.md"
  default     = null
}

variable "auth_registry_password" {
  description = "password on registry, see README_TESTING.md"
  default     = null
}

variable "server_http_proxy" {
  description = "Hostname and port used by the server as the HTTP proxy to reach the outside network"
  default     = null
}

variable "saltapi_tcpdump" {
  description = "If set to true, all network operations of salt-api on the Server are logged to /tmp/ with tcpdump."
  default     = false
}

// provider
variable "provider_settings" {
  description = "Settings specific to the provider, see README_TESTING.md"
  default     = {}
}
