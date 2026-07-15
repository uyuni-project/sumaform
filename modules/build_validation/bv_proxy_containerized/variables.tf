variable "base_configuration" {
  description = "use module.base.configuration"
}

variable "name" {
  description = "hostname, without the domain part"
  type        = string
}

variable "mac" {
  description = "MAC address for the VM"
  type        = string
}

variable "image" {
  description = "OS image name"
  type        = string
}

variable "string_registry" {
  description = "set the registry in string variable in mgradm.yaml"
  type        = bool
}

variable "container_registry" {
  description = "where to find the proxy container images"
  default     = ""
}

variable "additional_repos" {
  description = "extra repositories in the form {label = url}"
  default     = {}
}

variable "ssh_key_path" {
  description = "path of additional pub ssh key for VM access"
  default     = null
}
