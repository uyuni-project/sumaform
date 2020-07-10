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
  default     = ["centos7", "opensuse150", "opensuse151", "opensuse152o", "sles15", "sles15sp1", "sles15sp2o", "sles11sp4", "sles12", "sles12sp1", "sles12sp2", "sles12sp3", "sles12sp4", "ubuntu1804"]
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
  description = "Object with clients and their specific properties, see README_TESTING.md"
  default = {
    cli-sles12sp4 = {
      present = true
    }
    min-sles12sp4 = {
      present = true
    }
  }
}

// srv
variable "product_version" {
  description = "One of: 3.2-nightly, 3.2-released, 4.0-nightly, 4.0-released, head, test, uyuni-released"
  type        = string
}

variable "from_email" {
  description = "email address used as sender for emails"
  default     = null
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

variable "git_repo" {
  description = "Git repo clone URL for testsuite code"
  default     = "default"
}

variable "git_profiles_repo" {
  description = "URL of git repository with alternate Docker and Kiwi profiles, see README_TESTING.md"
  default     = "default"
}

variable "portus_uri" {
  description = "URI of portus server, see README_TESTING.md"
  default     = null
}

variable "portus_username" {
  description = "username on portus server, see README_TESTING.md"
  default     = null
}

variable "portus_password" {
  description = "password on portus server, see README_TESTING.md"
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
