variable "base_configuration" {
  description = "use ${module.base.configuration}, see main.tf.libvirt.example"
  type = "map"
}

variable "name" {
  description = "hostname, without the domain part"
  type = "string"
}

variable "server_configuration" {
  description = "use ${module.<SERVER_NAME>.configuration}, see main.tf.libvirt.example"
  type = "map"
}

variable "minion_count"  {
  description = "number of minions that this swarm will spawn"
  default = 200
}

variable "minion_pool" {
  description = "number of evil-minions processes"
  default = 2
}

variable "minion_dump_yml_file" {
  description = "Salt minion YaML dump file"
  type = "string"
  default = "minion-dump.yml"
}

variable "slowdown_factor"  {
  description = "slowdown factor for evil-minions"
  default = 1.0
}

variable "count"  {
  description = "number of hosts like this one"
  default = 1
}

variable "memory" {
  description = "RAM memory in MiB"
  default = 1024 
}

variable "vcpu" {
  description = "Number of virtual CPUs"
  default = 1
}

variable "running" {
  description = "Whether this host should be turned on or off"
  default = true
}

variable "mac" {
  description = "a MAC address in the form AA:BB:CC:11:22:22"
  default = ""
}
