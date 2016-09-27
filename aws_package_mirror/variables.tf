variable "region" {
  description = "Region where the instance is created"
  type = "string"
}

variable "availability_zone" {
  description = "Availability zone where the instance is created"
  type = "string"
}

variable "ami" {
  description = "AMI of the custom openSUSE Terraform image for this region, see aws_images"
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
  description = "ID of the public subnet, see aws_network"
  type = "string"
}

variable "public_security_group_id" {
  description = "ID of the security group of the public subnet, see aws_network"
  type = "string"
}

variable "data_volume_snapshot_id" {
  description = "ID of an optional snapshot of the data volume"
  default = ""
}

variable "name_prefix" {
  description = "A prefix for names of objects created by this module"
  default = "sumaform"
}
