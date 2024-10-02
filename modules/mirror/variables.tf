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

variable "install_salt_bundle" {
  description = "use true to install the venv-salt-minion package in the hosts"
  default     = true
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
  description = "List of Ubuntu versions to mirror among 20.04, 22.04, 24.04"
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
  description = "Disable the cron tasks not needed for MU features"
  default     = false
}

variable "image" {
  description = "An image name, e.g. sles12sp4 or opensuse155o"
  type        = string
  default = "opensuse155o"
}
