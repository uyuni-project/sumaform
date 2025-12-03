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
  description = "Platform location"
}

variable "cucumber_gitrepo" {
  type = string
  default = "This is defined in product tfvars"
}

variable "cucumber_branch" {
  type = string
  default = "This is defined in product tfvars"
}

variable "scc_user" {
  type = string
}

variable "scc_password" {
  type = string
}

variable "scc_ptf_user" {
  type = string
  default = null
  // Not needed for master, as PTFs are only build for SUSE Manager / MLM
}

variable "scc_ptf_password" {
  type = string
  default = null
  // Not needed for master, as PTFs are only build for SUSE Manager / MLM
}

variable "server_container_repository" {
  type = string
  default = ""
}

variable "proxy_container_repository" {
  type = string
  default = ""
}

variable "server_container_image" {
  type = string
  default = ""
}

variable "zvm_admin_token" {
  type = string
}

variable "git_user" {
  type = string
  default = null // Not needed for master, as it is public
}

variable "git_password" {
  type = string
  default = null // Not needed for master, as it is public
}

variable "base_os" {
  type        = string
  description = "Optional override for the server base OS image"
  default     = null
}

variable "product_version" {
  type        = string
  description = "Product version"
}

variable "base_configurations" {
  type        = map(any)
  description = "Map of base configurations. Mandatory keys: default. Optional: old_sle, new_sle, res, debian, retail, arm, s390."
}