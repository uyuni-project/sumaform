variable "base_configuration" {
  description = "use module.base.configuration, see the main.tf example file"
}

variable "name" {
  description = "hostname, without the domain part"
  type        = string
  default     = "nfs"
}

variable "image" {
  description = "image to use for the NFS server VM"
  type        = string
  default     = "opensuse156o"
}

variable "use_os_released_updates" {
  description = "Apply all updates from SUSE Linux Enterprise repos"
  default     = true
}

variable "install_salt_bundle" {
  description = "use true to install the venv-salt-minion package in the hosts"
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
  description = "Settings specific to the provider, see README_ADVANCED.md"
  default     = {}
}

variable "volume_provider_settings" {
  description = "Settings for the data volume, see README_ADVANCED.md"
  default     = {}
}

variable "data_disk_size" {
  description = "Size of an additional disk used for the NFS export, defined in GiB. Use 0 for no extra disk."
  default     = 0
}

variable "export_path" {
  description = "Path on the NFS server VM that will be exported"
  type        = string
  default     = "/srv/nfs"
}

variable "allowed_cidr" {
  description = "CIDR range allowed to mount the export"
  type        = string
  default     = "0.0.0.0/0"
}

variable "export_options" {
  description = "NFS export options applied to the share"
  type        = string
  default     = "rw,sync,no_subtree_check,no_root_squash"
}
