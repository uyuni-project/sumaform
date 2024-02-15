variable "base_configuration" {
  description = "use module.base.configuration, see the main.tf example file"
}

variable "name" {
  description = "hostname, without the domain part"
  type        = string
}

variable "roles" {
  description = "List of the host roles"
  type        = list(string)
  default     = []
}

variable "runtime" {
  description = "Where to run the containers. One of podman or k3s"
  type        = string
  default      = "podman"
}

variable "container_repository" {
  description = "Where to find the server container images. Uses the released ones per default."
  type        = string
  default     = ""
}

variable "container_tag" {
  description = "The container image tag to use."
  type        = string
  default     = ""
}

variable "helm_chart_url" {
  description = "Where to get the helm chart from. Uses the released one by default."
  type        = string
  default     = ""
}

variable "product_version" {
  description = "One of: uyuni-master, uyuni-released, head, uyuni-pr"
  type        = string
}

variable "channels" {
  description = "a list of SUSE channel labels to add"
  type        = list(string)
  default     = []
}

variable "wait_for_reposync" {
  description = "turn to true to make sure reposync is finished for channels"
  type        = bool
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
  type        = bool
  default     = true
}

variable "download_private_ssl_key" {
  description = "copy SSL certificates from the hub server upon deployment"
  type        = bool
  default     = true
}

variable "activation_key" {
  description = "an Activation Key to be used when registering to another Server"
  type        = string
  default     = null
}

variable "server_username" {
  description = "username of the SUSE Manager administrator, admin by default"
  type        = string
  default     = "admin"
}

variable "server_password" {
  description = "password of the SUSE Manager administrator, admin by default"
  type        = string
  default     = "admin"
}

variable "disable_firewall" {
  description = "whether to disable the built-in firewall, opening up all ports"
  type        = bool
  default     = true
}

variable "allow_postgres_connections" {
  description = "configure Postgres to accept connections from external hosts"
  type        = bool
  default     = true
}

variable "unsafe_postgres" {
  description = "whether to use PostgreSQL settings that improve performance by worsening durability"
  type        = bool
  default     = true
}

variable "postgres_log_min_duration" {
  description = "log any PostgreSQL statement taking longer than the specified amount of milliseconds. 0 for all, leave default for none"
  type        = number
  default     = null
}

variable "java_debugging" {
  description = "enable Java debugging and profiling support in Tomcat and Taskomatic"
  type        = bool
  default     = true
}

variable "java_hibernate_debugging" {
  description = "enable additional logs for Hibernate in Tomcat and Taskomatic"
  type        = bool
  default     = false
}

variable "java_salt_debugging" {
  description = "enable additional logs for Hibernate in Tomcat"
  type        = bool
  default     = false
}

variable "skip_changelog_import" {
  description = "import RPMs without changelog data, this speeds up spacewalk-repo-sync"
  type        = bool
  default     = true
}

variable "create_first_user" {
  description = "whether to automatically create the first user"
  type        = bool
  default     = true
}

variable "mgr_sync_autologin" {
  description = "whether to set mgr-sync credentials in the .mgr-sync file"
  type        = bool
  default     = true
}

variable "create_sample_channel" {
  description = "whether to create an empty test channel"
  type        = bool
  default     = true
}

variable "create_sample_activation_key" {
  description = "whether to create a sample activation key"
  type        = bool
  default     = true
}

variable "create_sample_bootstrap_script" {
  description = "whether to create a sample bootstrap script for traditional clients"
  type        = bool
  default     = true
}

variable "publish_private_ssl_key" {
  description = "whether to copy the private SSL key in /pub upon deployment"
  type        = bool
  default     = true
}

variable "disable_download_tokens" {
  description = "disable package token download checks"
  type        = bool
  default     = true
}

variable "disable_auto_bootstrap" {
  description = "disable the default bootstrap mgr-create-bootstrap-repo call after product synchronization"
  type        = bool
  default     = false
}

variable "use_os_released_updates" {
  description = "Apply all updates from SUSE Linux Enterprise repos"
  type        = bool
  default     = false
}

variable "from_email" {
  description = "email address used as sender for emails"
  type        = string
  default     = null
}

variable "traceback_email" {
  description = "recipient email address that will receive errors during usage"
  type        = string
  default     = null
}

variable "smt" {
  description = "URL to an SMT server to get packages from"
  type        = string
  default     = null
}

variable "auto_accept" {
  description = "whether to automatically accept all incoming minion keys"
  type        = bool
  default     = true
}

variable "monitored" {
  description = "whether this host should be monitored via Prometheus"
  type        = bool
  default     = false
}

variable "additional_repos" {
  description = "extra repositories in the form {label = url}, see README_ADVANCED.md"
  type        = map(string)
  default     = {}
}

variable "additional_repos_only" {
  description = "whether to exclusively use additional repos"
  type        = bool
  default     = false
}

variable "additional_certs" {
  description = "extra SSL certficates in the form {name = url}, see README_ADVANCED.md"
  default     = {}
}

variable "additional_packages" {
  description = "extra packages to install, see README_ADVANCED.md"
  type        = list(string)
  default     = []
}

variable "install_salt_bundle" {
  description = "use true to install the venv-salt-minion package in the hosts"
  type        = bool
  default     = false
}

variable "quantity" {
  description = "number of hosts like this one"
  type        = number
  default     = 1
}

variable "grains" {
  description = "custom grain map to be added to this host's configuration"
  default     = {}
}

variable "swap_file_size" {
  description = "Swap file size in MiB, or 0 for none"
  type        = number
  default     = 0
}

variable "ssh_key_path" {
  description = "path of additional pub ssh key you want to use to access VMs, see README_ADVANCED.md"
  type        = string
  default     = null
}

variable "gpg_keys" {
  description = "salt/ relative paths of gpg keys that you want to add to your VMs, see README_ADVANCED.md"
  type        = list(string)
  default     = []
}

variable "ipv6" {
  description = "IPv6 tuning: enable it, accept the RAs"
  type    = map(bool)
  default = {
    enable    = true
    accept_ra = true
  }
}

variable "connect_to_base_network" {
  description = "true if you want a card connected to the main network, see README_ADVANCED.md"
  type        = bool
  default     = true
}

variable "connect_to_additional_network" {
  description = "true if you want a card connected to the additional network (if any), see README_ADVANCED.md"
  type        = bool
  default     = false
}

variable "image" {
  description = "An image name, e.g. sles15sp5 or opensuse155o"
  type        = string
  default     = "default"
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

variable "main_disk_size" {
  description = "Size of main disk, defined in GiB"
  type        = number
  default     = 200
}

variable "repository_disk_size" {
  description = "Size of an additional disk for /var/spacewalk partition, defined in GiB"
  type        = number
  default     = 0
}

variable "database_disk_size" {
  description = "Size of an additional disk for /var/lib/pgsql partition, defined in GiB"
  type        = number
  default     = 0
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

variable "large_deployment" {
  description = "set up for a deployment with a great number of clients"
  type        = bool
  default     = false
}
