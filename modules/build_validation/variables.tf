variable "environment_configuration" {
  type = any
  description = "Collection of values containing: mac addresses, hypervisor and additional network"
}

variable "platform_location_configuration" {
  type = any
  description = "Collection of values containing location specific information"
}

variable location {
  type = string
  description = "Platform location, nue or slc1"
}

variable "cucumber_gitrepo" {
  type = string
  description = "Testsuite git repository"
}

variable "cucumber_branch" {
  type = string
  description = "Testsuite git branch"
}

variable "git_user" {
  type = string
  description = "Git user to access git repository"
  default = null // Not needed for master, as it is public
}

variable "git_password" {
  type = string
  description = "Git user password to access git repository"
  default = null // Not needed for master, as it is public
}

variable "scc_user" {
  type = string
  description = "SCC user used as product organization"
}

variable "scc_password" {
  type = string
  description = "SCC password used as product organization"
}

variable "scc_ptf_user" {
  type = string
  description = "SCC user used for PTF Feature testing, only available for 5.1"
  default = null
  // Not needed for master, as PTFs are only build for SUSE Manager / MLM
}

variable "scc_ptf_password" {
  type = string
  description = "SCC user used for PTF Feature testing, only available for 5.1"
  default = null
  // Not needed for master, as PTFs are only build for SUSE Manager / MLM
}

variable "server_container_repository" {
  type = string
  description = "Server container registry path, not needed for 4.3"
  default = ""
}

variable "proxy_container_repository" {
  type = string
  description = "Proxy container registry path, not needed for 4.3"
  default = ""
}

variable "server_container_image" {
  type = string
  description = "Server container image, not needed for 4.3"
  default = ""
}

variable "zvm_admin_token" {
  type = string
  description = "Admin token for Feilong provider"
}

variable "base_os" {
  type        = string
  description = "Optional override for the server base OS image"
  default     = null
}

variable "product_version" {
  type        = string
}

variable "base_configurations" {
  type        = map(any)
  description = "Map of base configurations. Mandatory keys: default. Optional: old_sle, new_sle, res, debian, retail, arm, s390."
}

variable "module_base_configurations" {
  type        = map(any)
  description = "Module base configurations"
}
