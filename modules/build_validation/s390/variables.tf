variable "name_prefix" {
  type = string
}

variable "domain" {
  type = string
}

variable "product_version" {
  type = string
}

variable "sles15sp5s390_minion_configuration" {
  type = object({
    name   = string
    userid = string
    mac    = string
  })
  default = null
}

variable "sles15sp5s390_sshminion_configuration" {
  type = object({
    name   = string
    userid = string
    mac    = string
  })
  default = null
}
