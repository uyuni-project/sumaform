// base
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

variable "use_avahi" {
  description = "use false only if you use bridged networking with static MACs and an external DHCP"
  default     = true
}

variable "avahi_reflector" {
  description = "if using avahi, allow one minion to have a reflector configured"
  default     = false
}

variable "ssh_key_path" {
  description = "path of pub ssh key you want to use to access VMs, see backend_modules/libvirt/README.md"
  default     = "~/.ssh/id_rsa.pub"
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
  default     = ["centos7o", "opensuse155o", "rocky8o", "rocky9o", "sles12sp4o", "sles12sp5o", "sles15sp3o", "sles15sp4o", "ubuntu2004o", "ubuntu2204o", "suma43VM-ign"]
}

variable "main_disk_size" {
  description = "Size of main disk, defined in GiB"
  default     = 200
}

variable "repository_disk_size" {
  description = "Size of an additional disk for /var/spacewalk partition, defined in GiB"
  default     = 0
}

variable "database_disk_size" {
  description = "Size of an additional disk for /var/lib/pgsql partition, defined in GiB"
  default     = 0
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
  description = "One of: 4.2-nightly, 4.2-released, 4.3-nightly, 4.3-released, 4.3-pr, 4.3-beta, 4.3-VM-nightly, 4.3-VM-released, head, uyuni-master, uyuni-released, uyuni-pr"
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

variable "custom_download_endpoint" {
  description = "URL (protocol, domain name and port) of custom download endpoint for packages"
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

variable "login_timeout" {
  description = "How long the webUI login session cookie is valid"
  default     = null
}

variable "container_server" {
  description = "true to run the server in containers"
  default = false
}

variable "container_proxy" {
  description = "true to run the proxy in containers"
  default = false
}
