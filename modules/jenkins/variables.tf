variable "base_configuration" {
  description = "use module.base.configuration, see the main.tf example file"
}

variable "use_os_released_updates" {
  description = "Apply all updates from SUSE Linux Enterprise repos"
  default     = true
}

variable "additional_repos" {
  description = "extra repositories in the form {label = url}, see README_ADVANCED.md"
  default     = {}
}

variable "additional_repos_only" {
  description = "whether to exclusively use additional repos"
  default     = false
}

variable "additional_packages" {
  description = "extra packages to install, see README_ADVANCED.md"
  default     = []
}

variable "swap_file_size" {
  description = "Swap file size in MiB, or 0 for none"
  default     = 0
}

variable "ssh_key_path" {
  description = "path of additional pub ssh key you want to use to access VMs, see README_ADVANCED.md"
  default     = null
}

variable "provider_settings" {
  description = "Map of provider-specific settings, see the backend-specific README file"
  default     = {}
}

variable "data_disk_size" {
  description = "Size of an aditional disk for the /var/lib/jenkins partition, defined in GiB"
  default     = 1024
}

variable "data_disk_fstype" {
  description = "Data disk file system type"
  default     = "ext4"
}

variable "volume_provider_settings" {
  description = "Map of volume-provider-specific settings, see the backend-specific README file"
  default     = {}
}

variable "image" {
  description = "An image name, e.g. sles15sp2o or opensuse153o"
  type        = string
  default = "opensuse153o"
}
