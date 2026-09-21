variable "project_name" {
  type        = "string"
  description = "The name of the project to instanciate the instance at."
  default     = "suse-css-qa"
}

variable "region_name" {
  type        = "string"
  description = "The region that this terraform configuration will instanciate at."
  default     = "europe-west3"
}

variable "zone_name" {
  type        = "string"
  description = "The zone that this terraform configuration will instanciate at."
  default     = "europe-west3-b"
}

variable "machine_size" {
  type        = "string"
  description = "The size that this instance will be."
  default     = "f1-micro"
}

variable "name_prefix" {
  description = "a prefix for all names of objects to avoid collisions. E.g. moio-"
  default     = ""
}

variable "image_name" {
  type        = "string"
  description = "The kind of VM this instance will become"
  default     = ""
}

variable "script_path" {
  type        = "string"
  description = "Where is the path to the script locally on the machine?"
  default = ""
}

variable "private_key_path" {
  type        = "string"
  description = "The path to the private key used to connect to the instance"
  default = ""
}

variable "username" {
  type        = "string"
  description = "The name of the user that will be used to remote exec the script"
  default = ""
}
