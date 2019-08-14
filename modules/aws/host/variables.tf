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
  default = "t2.micro"
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

variable "product_version" {
  description = "Main product version (eg. 4.0-released, 4.0-nightly, 3.2-released, 3.2-nightly, head)"
  default = "null"
}

variable "channels" {
  description = "a list of SUSE channel labels to add"
  default = []
}

variable "role"  {
  description = "Name of the host role, see the main.tf example file"
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

variable "activation_key" {
  description = "an Activation Key to be used when onboarding a minion"
  default = "null"
}

variable "unsafe_postgres" {
  description = "whether to use PostgreSQL settings that improve performance by worsening durability"
  default = true
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

variable "auto_accept" {
  description = "whether to automatically accept all incoming minion keys"
  default = true
}

variable "monitored" {
  description = "whether this host should be monitored via Prometheus"
  default = false
}

variable "apparmor" {
  description = "whether AppArmor access control should be installed"
  default = false
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

variable "mirror_public_name" {
  description = "mirror's public DNS name"
  type = "string"
}

variable "mirror_private_name" {
  description = "mirror's private DNS name"
  type = "string"
}

variable "gpg_keys" {
  description = "salt/ relative paths of gpg keys that you want to add to your VMs, see README_ADVANCED.md"
  default = []
}
