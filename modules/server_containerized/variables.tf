variable "base_configuration" {
  description = "use module.base.configuration, see the main.tf example file"
}

variable "name" {
  description = "hostname, without the domain part"
  type        = string
}

variable "roles" {
  description = "List of the host roles"
  default     = []
}

variable "runtime" {
  description = "Where to run the containers. One of podman or k3s"
  default = "podman"
}

variable "container_repository" {
  description = "Where to find the server container images. Uses the released ones per default."
  default = ""
}

variable "product_version" {
  description = "One of: uyuni-master, uyuni-released"
  type        = string
}

variable "channels" {
  description = "a list of SUSE channel labels to add"
  default     = []
}

variable "wait_for_reposync" {
  description = "turn to true to make sure reposync is finished for channels"
  default     = false
}

variable "cloned_channels" {
  description = "a json formatted string representing a list of dictionaries containing SUSE channels information to clone"
  default     = null
  type = list(object({
    channels = list(string)
    prefix   = string
    date     = string
  }))
}

variable "iss_master" {
  description = "ISS master server, leave the default for no ISS"
  default     = null
}

variable "iss_slave" {
  description = "ISS slave server, leave the default for no ISS"
  default     = null
}

variable "register_to_server" {
  description = "name of another Server to register to, eg module.<SERVER_NAME>.configuration.hostname"
  default     = null
}

variable "auto_register" {
  description = "whether this Server should automatically register to another Server"
  default     = true
}

variable "download_private_ssl_key" {
  description = "copy SSL certificates from the hub server upon deployment"
  default     = true
}

variable "activation_key" {
  description = "an Activation Key to be used when registering to another Server"
  default     = null
}

variable "server_username" {
  description = "username of the SUSE Manager administrator, admin by default"
  default     = "admin"
}

variable "server_password" {
  description = "password of the SUSE Manager administrator, admin by default"
  default     = "admin"
}

variable "disable_firewall" {
  description = "whether to disable the built-in firewall, opening up all ports"
  default     = true
}

variable "allow_postgres_connections" {
  description = "configure Postgres to accept connections from external hosts"
  default     = true
}

variable "unsafe_postgres" {
  description = "whether to use PostgreSQL settings that improve performance by worsening durability"
  default     = true
}

variable "postgres_log_min_duration" {
  description = "log any PostgreSQL statement taking longer than the specified amount of milliseconds. 0 for all, leave default for none"
  default     = null
}

variable "java_debugging" {
  description = "enable Java debugging and profiling support in Tomcat and Taskomatic"
  default     = true
}

variable "skip_changelog_import" {
  description = "import RPMs without changelog data, this speeds up spacewalk-repo-sync"
  default     = true
}

variable "create_first_user" {
  description = "whether to automatically create the first user"
  default     = true
}

variable "mgr_sync_autologin" {
  description = "whether to set mgr-sync credentials in the .mgr-sync file"
  default     = true
}

variable "create_sample_channel" {
  description = "whether to create an empty test channel"
  default     = true
}

variable "create_sample_activation_key" {
  description = "whether to create a sample activation key"
  default     = true
}

variable "create_sample_bootstrap_script" {
  description = "whether to create a sample bootstrap script for traditional clients"
  default     = true
}

variable "publish_private_ssl_key" {
  description = "whether to copy the private SSL key in /pub upon deployment"
  default     = true
}

variable "disable_download_tokens" {
  description = "disable package token download checks"
  default     = true
}

variable "use_os_released_updates" {
  description = "Apply all updates from SUSE Linux Enterprise repos"
  default     = false
}

variable "from_email" {
  description = "email address used as sender for emails"
  default     = null
}

variable "smt" {
  description = "URL to an SMT server to get packages from"
  default     = null
}

variable "auto_accept" {
  description = "whether to automatically accept all incoming minion keys"
  default     = true
}

variable "monitored" {
  description = "whether this host should be monitored via Prometheus"
  default     = false
}

variable "additional_repos" {
  description = "extra repositories in the form {label = url}, see README_ADVANCED.md"
  default     = {}
}

variable "additional_repos_only" {
  description = "whether to exclusively use additional repos"
  default     = false
}

variable "additional_certs" {
  description = "extra SSL certficates in the form {name = url}, see README_ADVANCED.md"
  default     = {}
}

variable "additional_packages" {
  description = "extra packages to install, see README_ADVANCED.md"
  default     = []
}

variable "install_salt_bundle" {
  description = "use true to install the venv-salt-minion package in the hosts"
  default     = false
}

variable "quantity" {
  description = "number of hosts like this one"
  default     = 1
}

variable "grains" {
  description = "custom grain map to be added to this host's configuration"
  default     = {}
}

variable "swap_file_size" {
  description = "Swap file size in MiB, or 0 for none"
  default     = 0
}

variable "ssh_key_path" {
  description = "path of additional pub ssh key you want to use to access VMs, see README_ADVANCED.md"
  default     = null
}

variable "gpg_keys" {
  description = "salt/ relative paths of gpg keys that you want to add to your VMs, see README_ADVANCED.md"
  default     = []
}

variable "ipv6" {
  description = "IPv6 tuning: enable it, accept the RAs"
  default = {
    enable    = true
    accept_ra = true
  }
}

variable "connect_to_base_network" {
  description = "true if you want a card connected to the main network, see README_ADVANCED.md"
  default     = true
}

variable "connect_to_additional_network" {
  description = "true if you want a card connected to the additional network (if any), see README_ADVANCED.md"
  default     = false
}

variable "image" {
  description = "An image name, e.g. sles12sp4 or opensuse154o"
  type        = string
  default     = "opensuse154o"
}

variable "provision" {
  description = "Indicates whether servers should be provisioned or not"
  type        = bool
  default     = true
}

variable "provider_settings" {
  description = "Map of provider-specific settings, see the modules/libvirt/README.md"
  default     = {}
}

variable "additional_disk_size" {
  description = "Size of an aditional disk, defined in GiB"
  default     = null
}

variable "volume_provider_settings" {
  description = "Map of volume-provider-specific settings, see the backend-specific README file"
  default     = {}
}

variable "overwrite_fqdn" {
  description = "use the specified FQDN as hostname for the system"
  type        = string
  default     = null
}

variable "server_mounted_mirror" {
  description = "hostname of a mounted mirror in the server (to get packages from it)"
  default     = null
}
