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

variable "monitoring" {
  description = "Wether to enable AWS's Detailed Monitoring"
  default = false
}

variable "public_subnet_id" {
  description = "ID of the public subnet, see modules/aws/network"
  type = "string"
}

variable "public_security_group_id" {
  description = "ID of the security group of the public subnet, see modules/aws/network"
  type = "string"
}

variable "name_prefix" {
  description = "A prefix for names of objects created by this module"
  default = "sumaform"
}

variable "timezone" {
  description = "Timezone setting for this VM"
  default = "Europe/Berlin"
}

variable "additional_repos" {
  description = "extra repositories in the form {label = url}, see README_ADVANCED.md"
  default = {}
}

variable "additional_repos_only" {
  description = "whether to exclusively use additional repos"
  default = false
}

variable "additional_certs" {
  description = "extra SSL certficates in the form {name = url}, see README_ADVANCED.md"
  default = {}
}

variable "additional_packages" {
  description = "extra packages to install, see README_ADVANCED.md"
  default = []
}

variable "gpg_keys" {
  description = "salt/ relative paths of gpg keys that you want to add to your VMs, see README_ADVANCED.md"
  default = []
}

variable "ssh_user" {
  description = "user name to use with ssh connection"
  type = "string"
  default = "ec2-user"
}

variable "server" {
  description = "address of Manager server"
  type = "string"
}

variable "client" {
  description = "address of client host"
  type = "string"
}

variable "minion" {
  description = "address of minion host"
  type = "string"
}

variable "git_username" {
  description = "username for GitHub"
  type = "string"
  default = ""
}

variable "git_password" {
  description = "password for GitHub"
  type = "string"
  default = ""
}

variable "git_repo" {
  description = "git repo to use when checking out testsuite"
  type = "string"
  default = "https://github.com/uyuni-project/uyuni.git"
}

variable "git_branch" {
  description = "git branch to use when checking out testsuite"
  type = "string"
  default = "4.0-rc1"
}

variable "repos_to_sync" {
  description = "list of repositories needed to be synced on the server for init_client test set"
  type = "string"
  default = ""
}
