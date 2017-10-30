variable "region" {
  description = "Region where the instance is created"
  type = "string"
}

variable "availability_zone" {
  description = "Availability zone where the instance is created"
  type = "string"
}

variable "ami" {
  description = "AMI of the custom openSUSE Terraform image for this region, see modules/aws/images"
  type = "string"
}

variable "key_name" {
  description = "Name of the SSH key for the instance"
  type = "string"
}

variable "key_file" {
  description = "Path to the private SSH key"
  type = "string"
}

variable "public_subnet_id" {
  description = "ID of the public subnet, see modules/aws/network"
  type = "string"
}

variable "public_security_group_id" {
  description = "ID of the security group of the public subnet, see modules/aws/network"
  type = "string"
}

variable "data_volume_snapshot_id" {
  description = "ID of a snapshot of the data volume, leave default to start with a blank volume"
  default = ""
}

variable "cc_username" {
  description = "Username for the Customer Center"
  type = "string"
}

variable "cc_password" {
  description = "Password for the Customer Center"
  type = "string"
}

variable "timezone" {
  description = "Timezone setting for this VM"
  default = "Europe/Berlin"
}

variable "additional_repos" {
  description = "extra repositories in the form {label = url}, see README_ADVANCED.md"
  default = {}
}

variable "additional_packages" {
  description = "extra packages to install, see README_ADVANCED.md"
  default = []
}

variable "name_prefix" {
  description = "A prefix for names of objects created by this module"
  default = "sumaform"
}
