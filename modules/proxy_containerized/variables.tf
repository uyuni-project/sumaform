variable "base_configuration" {
  description = "use module.base.configuration, see the main.tf example file"
}

variable "name" {
  description = "hostname, without the domain part"
  type        = string
}

variable "product_version" {
  description = "One of: head, uyuni-master, uyuni-released, uyuni-pr"
  type        = string
}

variable "runtime" {
  description = "Where to run the containers. One of podman or k3s"
  default = "podman"
}

variable "container_repository" {
  description = "Where to find the proxy container images. Uses the released ones per default."
  default = ""
}

variable "helm_chart_url" {
  description = "Where to get the helm chart from. Uses the released one by default."
  default = ""
}

variable "server_configuration" {
  description = "use module.<SERVER_NAME>.configuration, see README_ADVANCED.md"
}

variable "auto_configure" {
  description = "whether to automatically generate the configuration file and setup the pod upon deployment"
  default     = false
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
  default     = false
}

variable "quantity" {
  description = "number of hosts like this one"
  default     = 1
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

variable "provider_settings" {
  description = "Map of provider-specific settings, see the backend-specific README file"
  default     = {}
}

variable "volume_provider_settings" {
  description = "Map of volume-provider-specific settings, see the backend-specific README file"
  default     = {}
}

variable "main_disk_size" {
  description = "Size of main disk, defined in GiB"
  default     = 200
}

variable "repository_disk_size" {
  description = "Size of an aditional disk for /var/spacewalk partition, defined in GiB"
  default     = 0
}

variable "database_disk_size" {
  description = "Size of an additional disk for /var/lib/pgsql partition, defined in GiB"
  default     = 0
}

variable "roles" {
  description = "List of the host roles"
  default     = ["proxy_containerized"]
}

variable "avahi_reflector" {
  description = "if using avahi, let the daemon be a reflector"
  default     = false
}

variable "additional_grains" {
  description = "custom grain string to be added to this minion's configuration"
  default     = {}
}
