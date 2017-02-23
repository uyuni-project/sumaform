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

variable "instance_type" {
  description = "Instance type, see a list at: https://aws.amazon.com/ec2/instance-types/"
  default = "t2.nano"
}

variable "volume_size" {
  description = "Size of the root volume in GiB"
  default = 10
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

variable "version" {
  description = "Main product version (eg. 2.1-stable, 3-nightly, head)"
  default = "null"
}

variable "database" {
  description = "RDBMS name (eg. postgres, oracle, pgpool)"
  default = "null"
}

variable "role"  {
  description = "Name of the host role, see main.tf.libvirt.example"
  type = "string"
}

variable "cc_username" {
  description = "Username for the Customer Center"
  default = "null"
}

variable "cc_password" {
  description = "Password for the Customer Center"
  default = "null"
}

variable "server" {
  description = "Main server for this host"
  default = "null"
}

variable "iss_master" {
  description = "ISS master server, if any"
  default = "null"
}

variable "iss_slave" {
  description = "ISS slave server, if any"
  default = "null"
}

variable "additional_repos" {
  description = "extra repositories in the form {label = url}, see README_ADVANCED.md"
  default = {}
}

variable "additional_packages" {
  description = "extra packages to install, see README_ADVANCED.md"
  default = []
}

variable "package_mirror_public_name" {
  description = "package-mirror's public DNS name"
  type = "string"
}

variable "package_mirror_private_name" {
  description = "package-mirror's private DNS name"
  type = "string"
}
