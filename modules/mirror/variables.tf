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

variable "ubuntu_distros" {
  description = "List of Ubuntu versions to mirror among 16.04, 18.04, xenial, bionic"
  default     = []
}

variable "provider_settings" {
  description = "Map of provider-specific settings, see the backend-specific README file"
  default     = {}
}

variable "repository_disk_size" {
  description = "Size of an aditional disk for the /srv/mirror partition, defined in GiB"
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

variable "customize_minima_file" {
  description = "Specify a customize minima file. Will only upload this file"
  default     = null
}

variable "synchronize_immediately" {
  description = "Synchronize the minima.yaml during terraform deployment"
  default     = false
}

variable "disable_cron" {
  description = "Synchronize the minima.yaml during terraform deployment"
  default     = false
}

variable "image" {
  description = "An image name, e.g. sles11sp4 or opensuse152o"
  type        = string
  default = "opensuse152o"
}