variable "base_configuration" {
  description = "use module.base.configuration, see the main.tf example file"
}

variable "name" {
  description = "hostname, without the domain part"
  type        = string
}

variable "product_version" {
  description = "One of: 4.2-released, 4.2-nightly, 4.2-build_image, 4.3-released, 4.3-nightly, 4.3-pr, 4.3-beta, 4.3-build_image, 4.3-paygo, 4.3-VM-nightly, 4.3-VM-released, head, uyuni-master, uyuni-released, uyuni-pr"
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
  type = list(object({
    channels = list(string)
    prefix   = string
    date     = string
  }))
  default     = null
}

variable "iss_master" {
  description = "ISS master server, leave the default for no ISS"
  type        = string
  default     = null
}

variable "iss_slave" {
  description = "ISS slave server, leave the default for no ISS"
  type        = string
  default     = null
}

variable "register_to_server" {
  description = "name of another Server to register to, eg module.<SERVER_NAME>.configuration.hostname"
  type        = string
  default     = null
}

variable "disable_auto_bootstrap" {
  description = "disable the default bootstrap mgr-create-bootstrap-repo call after product synchronization"
  type        = bool
  default     = false
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
  type        = map(string)
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

variable "traceback_email" {
  description = "recipient email address that will receive errors during usage"
  type        = string
  default     = null
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

variable "image" {
  description = "Leave default for automatic selection or specify an OS supported by the specified product version"
  type        = string
  default     = "default"
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

variable "repository_disk_use_cloud_setup" {
  description = "Use cloud tool suma-storage to setup additional disk for repository and database data"
  default = false
}

variable "saltapi_tcpdump" {
  description = "If set to true, all network operations of salt-api are logged to /tmp/ with tcpdump."
  type        = bool
  default     = false
}

variable "provider_settings" {
  description = "Map of provider-specific settings, see the backend-specific README file"
  default     = {}
}

variable "volume_provider_settings" {
  description = "Map of volume-provider-specific settings, see the backend-specific README file"
  default     = {}
}

variable "server_mounted_mirror" {
  description = "hostname of a mounted mirror in the server (to get packages from it)"
  default     = null
}

variable "forward_registration" {
  description = "Forward client registrations to SCC"
  type        = bool
  default     = false
}

variable "server_registration_code" {
  description = "SUMA SCC registration code to enable the SLES and SUMA repositories for server"
  type        = string
  default     = null
}

variable "accept_all_ssl_protocols" {
  description = "Turn to true to force Apache to accept a greater range of protocol versions"
  type        = bool
  default     = false
}

variable "login_timeout" {
  description = "How long the webUI login session cookie is valid"
  type        = number
  default     = null
}

variable "db_configuration" {
  description = "Database configuration. by default setup to localhost"
  type = map(string)
  default = {
    local     = "true"
    hostname  = "localhost"
    port      = "5432"
  }
}

variable "c3p0_connection_timeout" {
  description = "c3p0 connections will be closed after this timeout"
  type        = bool
  # WORKAROUND: this is causing problems in the testsuite, disable it for now
  default     = false
}

variable "c3p0_connection_debug" {
  description = "log additional info regarding leaked c3p0 connections"
  type        = bool
  default     = false
}

variable "large_deployment" {
  description = "set up for a deployment with a great number of clients"
  type        = bool
  default     = false
}

variable "quantity" {
  description = "number of hosts like this one"
  type        = number
  default     = 1
}
