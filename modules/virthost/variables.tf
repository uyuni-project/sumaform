variable "base_configuration" {
  description = "use module.base.configuration, see the main.tf example file"
}

variable "name" {
  description = "hostname, without the domain part"
  type        = string
}

variable "product_version" {
  description = "A valid SUSE Manager version (eg. 4.2-nightly, head) see README_ADVANCED.md"
  default     = "released"
}

variable "server_configuration" {
  description = "use module.<SERVER_NAME>.configuration, see the main.tf example file"
}

variable "activation_key" {
  description = "an Activation Key to be used when onboarding this minion"
  default     = null
}

variable "auto_connect_to_master" {
  description = "whether this minion should automatically connect to the Salt Master upon deployment"
  default     = true
}

variable "use_os_released_updates" {
  description = "Apply all updates from SUSE Linux Enterprise repos"
  default     = false
}

variable "additional_repos" {
  description = "extra repositories used for installation {label = url}"
  default     = {}
}

variable "additional_repos_only" {
  description = "whether to exclusively use additional repos"
  default     = false
}

variable "additional_packages" {
  description = "extra packages which should be installed"
  default     = []
}

variable "install_salt_bundle" {
  description = "use true to install the venv-salt-minion package in the hosts"
  default     = false
}

variable "ssh_key_path" {
  description = "path of additional pub ssh key you want to use to access VMs, see README_ADVANCED.md"
  default     = null
}

variable "quantity" {
  description = "number of hosts like this one"
  default     = 1
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

variable "hvm_disk_image" {
  description = "Definition of the HVM disk images"
  type = map(map(string))
  default = {
    leap = {
      hostname = "leap154"
      image = "https://download.opensuse.org/distribution/leap/15.4/appliances/openSUSE-Leap-15.4-JeOS.x86_64-OpenStack-Cloud.qcow2"
      hash = "https://download.opensuse.org/distribution/leap/15.4/appliances/openSUSE-Leap-15.4-JeOS.x86_64-OpenStack-Cloud.qcow2.sha256"
    }
  }
}

variable "image" {
  description = "One of: sles15, sles15sp1, sles15sp2, sles15sp2o, sles15sp3o, sles15sp4o or opensuse154o"
  type        = string
}

variable "additional_grains" {
  description = "custom grain string to be added to this minion's configuration"
  default     = {}
}

variable "provider_settings" {
  description = "Map of provider-specific settings, see the backend-specific README file"
  default     = {}
}

variable "sles_registration_code" {
  description = "SUMA SCC registration code to enable the SLES server"
  default     = null
}
