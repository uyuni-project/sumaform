variable "base_configuration" {
  description = "use module.base.configuration, see the main.tf example file"
}

variable "name" {
  description = "hostname, without the domain part"
  type        = string
}

variable "product_version" {
  description = "One of: 3.2-released, 3.2-nightly, 4.0-released, 4.0-nightly, 4.1-released, 4.1-nightly, 4.2-beta, head"
  type        = string
}

variable "server_configuration" {
  description = "use module.<SERVER_NAME>.configuration, see README_ADVANCED.md"
}

variable "disable_firewall" {
  description = "whether to disable the built-in firewall, opening up all ports"
  default     = true
}

variable "minion" {
  description = "whether this Proxy should be onboarded as a minion"
  default     = true
}

variable "auto_connect_to_master" {
  description = "whether this minion should automatically connect to the Salt Master upon deployment, requires minion to be true"
  default     = true
}

variable "auto_register" {
  description = "whether this proxy should be automatically registered upon deployment (as a traditional client)"
  default     = false
}

variable "download_private_ssl_key" {
  description = "copy SSL certificates from the server upon deployment"
  default     = true
}

variable "install_proxy_pattern" {
  description = "whether to install proxy pattern upon deployment"
  default     = true
}

variable "auto_configure" {
  description = "whether to automatically run configure-proxy.sh upon deployment"
  default     = true
}

variable "generate_bootstrap_script" {
  description = "whether to generate a bootstrap script in /pub upon deployment"
  default     = true
}

variable "publish_private_ssl_key" {
  description = "whether to copy the private SSL key in /pub upon deployment"
  default     = true
}

variable "use_os_released_updates" {
  description = "Apply all updates from SUSE Linux Enterprise repos"
  default     = false
}

variable "use_os_unreleased_updates" {
  description = "Apply all updates from SUSE Linux Enterprise unreleased (Test) repos"
  default     = false
}

variable "additional_repos" {
  description = "extra repositories in the form {label = url}, see README_ADVANCED.md"
  default     = {}
}

variable "additional_packages" {
  description = "extra packages to install, see README_ADVANCED.md"
  default     = []
}

variable "quantity" {
  description = "number of hosts like this one"
  default     = 1
}

variable "swap_file_size" {
  description = "Swap file size in MiB, or 0 for none"
  default     = 0
}

variable "ssh_key_path" {
  description = "path of additional pub ssh key you want to use to access VMs, see README_ADVANCED.md"
  default     = null
}

variable "gpg_keys" {
  description = "salt/ relative paths of gpg keys that you want to add to your VMs, see README_ADVANCED.md"
  default     = []
}

variable "ipv6" {
  description = "IPv6 tuning: enable it, accept the RAs"
  default = {
    enable    = true
    accept_ra = true
  }
}

variable "image" {
  description = "Leave default for automatic selection or specify an OS supported by the specified product version"
  default     = "default"
}

variable "repository_disk_size" {
  description = "Size of an aditional disk for /var/spacewalk partition, defined in GiB"
  default     = 0
}

variable "provider_settings" {
  description = "Map of provider-specific settings, see the backend-specific README file"
  default     = {}
}

variable "volume_provider_settings" {
  description = "Map of volume-provider-specific settings, see the backend-specific README file"
  default     = {}
}
