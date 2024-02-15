variable "base_configuration" {
  description = "use module.base.configuration, see the main.tf example file"
}

variable "name" {
  description = "hostname, without the domain part"
  type        = string
}

variable "use_os_released_updates" {
  description = "Apply all updates from SUSE Linux Enterprise repos"
  type        = bool
  default     = false
}

variable "salt_obs_flavor" {
  description = "One of: products, products:testing or products:next"
  type        = string
  default     = "products:testing"
}

variable "additional_repos" {
  description = "extra repositories in the form {label = url}, see README_ADVANCED.md"
  type        = map(string)
  default     = {}
}

variable "additional_repos_only" {
  description = "whether to exclusively use additional repos"
  type        = bool
  default     = false
}

variable "additional_packages" {
  description = "extra packages to install, see README_ADVANCED.md"
  type        = list(string)
  default     = []
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

variable "provider_settings" {
  description = "Map of provider-specific settings, see the backend-specific README file"
  default     = {}
}

variable "image" {
  description = "An image name, e.g. sles12sp4 or opensuse155o"
  type        = string
  default     = "opensuse155o"
}
