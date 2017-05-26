variable "name" {
  description = "Symbolic name of this host for terraform use"
  type = "string"
}

variable "region" {
  description = "Region where the instance is created"
  type = "string"
}

variable "availability_zone" {
  description = "Availability zone where the instance is created"
  type = "string"
}

variable "ami" {
  description = "AMI image for the selected for the configured region, see modules/aws/images"
  type = "string"
}

variable "count"  {
  description = "Number of hosts like this one"
  default = 1
}

variable "monitoring" {
  description = "Wether to enable AWS's Detailed Monitoring"
  default = false
}

variable "key_name" {
  description = "Name of the SSH key for the instance"
  type = "string"
}

variable "key_file" {
  description = "Path to the private SSH key"
  type = "string"
}

variable "private_subnet_id" {
  description = "ID of the private subnet, see modules/aws/network"
  type = "string"
}

variable "private_security_group_id" {
  description = "ID of the security group of the private subnet, see modules/aws/network"
  type = "string"
}

variable "name_prefix" {
  description = "A prefix for names of objects created by this module"
  default = "sumaform"
}

variable "server" {
  description = "Main server for this host"
  default = "null"
}

variable "timezone" {
  description = "Timezone setting for this VM"
  default = "Europe/Berlin"
}

variable "evil_minion_count"  {
  description = "number of minions that will be spawned by evil-minions"
  default = 500
}

variable "minion_dump_yml_file" {
  description = "path to salt minion yaml dump file"
  type = "string"
  default = "salt/evil_minions/minion-dump-default.yml"
}

variable "slowdown_factor"  {
  description = "slowdown factor for evil-minions"
  default = 0
}

variable "additional_repos" {
  description = "extra repositories in the form {label = url}, see README_ADVANCED.md"
  default = {}
}

variable "additional_packages" {
  description = "extra packages to install, see README_ADVANCED.md"
  default = []
}

variable "mirror_public_name" {
  description = "mirror's public DNS name"
  type = "string"
}

variable "mirror_private_name" {
  description = "mirror's private DNS name"
  type = "string"
}
