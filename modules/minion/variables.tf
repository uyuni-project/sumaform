variable "base_configuration" {
  description = "use module.base.configuration, see the main.tf example file"
}

variable "name" {
  description = "hostname, without the domain part"
  type        = string
}

variable "roles" {
  description = "list of the host roles"
  type        = list(string)
  default     = ["minion"]
}

variable "product_version" {
  description = "A valid SUSE Manager version (eg. 4.2-nightly, head) see README_ADVANCED.md"
  type        = string
  default     = "released"
}

variable "server_configuration" {
  description = "use module.<SERVER_NAME>.configuration, see the main.tf example file"
}

variable "activation_key" {
  description = "an Activation Key to be used when onboarding this minion"
  type        = string
  default     = null
}

variable "auto_connect_to_master" {
  description = "whether this minion should automatically connect to the Salt Master upon deployment"
  type        = bool
  default     = true
}

variable "evil_minion_count" {
  description = "change to a number to use the evil-minions load generator, see README_ADVANCED.md"
  type        = number
  default     = 0
}

variable "evil_minion_slowdown_factor" {
  description = "slowdown factor for evil-minions (floating point), see README_ADVANCED.md"
  type        = number
  default     = 0
}

variable "use_os_released_updates" {
  description = "Apply all updates from SUSE Linux Enterprise repos"
  type        = bool
  default     = false
}

variable "avahi_reflector" {
  description = "if using avahi, let the daemon be a reflector"
  type        = bool
  default     = false
}

variable "disable_firewall" {
  description = "whether to disable the built-in firewall, opening up all ports"
  type        = bool
  default     = true
}

variable "additional_repos" {
  description = "extra repositories used for installation {label = url}"
  type        = map(string)
  default     = {}
}

variable "additional_repos_only" {
  description = "whether to exclusively use additional repos"
  type        = bool
  default     = false
}

variable "additional_packages" {
  description = "extra packages which should be installed"
  type        = list(string)
  default     = []
}

variable "install_salt_bundle" {
  description = "use true to install the venv-salt-minion package in the hosts"
  type        = bool
  default     = false
}

variable "quantity" {
  description = "number of hosts like this one"
  type        = number
  default     = 1
}

variable "swap_file_size" {
  description = "Swap file size in MiB, or 0 for none"
  type        = number
  default     = 0
}

variable "ssh_key_path" {
  description = "path of additional pub ssh key you want to use to access VMs, see README_ADVANCED.md"
  type        = string
  default     = null
}

variable "gpg_keys" {
  description = "salt/ relative paths of gpg keys that you want to add to your VMs, see README_ADVANCED.md"
  type        = list(string)
  default     = []
}

variable "ipv6" {
  description = "IPv6 tuning: enable it, accept the RAs"
  type    = map(bool)
  default = {
    enable    = true
    accept_ra = true
  }
}

variable "additional_grains" {
  description = "custom grain string to be added to this minion's configuration"
  default     = {}
}


variable "image" {
  description = "An image name, e.g. sles12sp4 or opensuse155o"
  type        = string
}

variable "provider_settings" {
  description = "Map of provider-specific settings, see the backend-specific README file"
  default     = {}
}

variable "sles_registration_code" {
  description = "SUMA SCC registration code to enable the SLES server"
  type        = string
  default     = null
}
