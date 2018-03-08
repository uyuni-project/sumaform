variable "base_configuration" {
  description = "use ${module.base.configuration}, see the main.tf example file"
  type = "map"
}

variable "name" {
  description = "hostname, without the domain part"
  type = "string"
}

variable "version" {
  description = "One of: 3.0-nightly, 3.0-released, 3.1-released, 3.1-nightly, head, test"
  type = "string"
}

variable "channels" {
  description = "a list of SUSE channel labels to add"
  default = []
}

variable "iss_master" {
  description = "ISS master server, leave the default for no ISS"
  default = "null"
}

variable "iss_slave" {
  description = "ISS slave server, leave the default for no ISS"
  default = "null"
}

variable "server_username" {
  description = "username of the SUSE Manager administrator, admin by default"
  default = "admin"
}

variable "server_password" {
  description = "password of the SUSE Manager administrator, admin by default"
  default = "admin"
}

variable "disable_firewall" {
  description = "whether to disable the built-in firewall, opening up all ports"
  default = true
}

variable "allow_postgres_connections" {
  description = "configure Postgres to accept connections from external hosts"
  default = true
}

variable "unsafe_postgres" {
  description = "whether to use PostgreSQL settings that improve performance by worsening durability"
  default = true
}

variable "java_debugging" {
  description = "enable Java debugging and profiling support in Tomcat and Taskomatic"
  default = true
}

variable "skip_changelog_import" {
  description = "import RPMs without changelog data, this speeds up spacewalk-repo-sync"
  default = true
}

variable "browser_side_less" {
  description = "enable compilation of LESS files in the browser, useful for development"
  default = true
}

variable "create_first_user" {
  description = "whether to automatically create the first user"
  default = true
}

variable "mgr_sync_autologin" {
  description = "whether to set mgr-sync credentials in the .mgr-sync file"
  default = true
}

variable "create_sample_channel" {
  description = "whether to create an empty test channel"
  default = true
}

variable "create_sample_activation_key" {
  description = "whether to create a sample activation key"
  default = true
}

variable "create_sample_bootstrap_script" {
  description = "whether to create a sample bootstrap script for traditional clients"
  default = true
}

variable "publish_private_ssl_key" {
  description = "whether to copy the private SSL key in /pub upon deployment"
  default = true
}

variable "use_unreleased_updates" {
  description = "This adds and updates sle packages from the test repo"
  default = false
}

variable "from_email" {
  description = "email address used as sender for emails"
  default = "null"
}

variable "smt" {
  description = "URL to an SMT server to get packages from"
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

variable "log_server" {
  description = "hostname:port address to a Logstash or Elasticsearch server to push logs to, see README_ADVANCED.md"
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

variable "traceback_email" {
  description = "recipient email address that will receive errors during usage"
  default = "null"
}

variable "ssh_key_path" {
  description = "path of additional pub ssh key you want to use to access VMs, see README_ADVANCED.md"
  default = "/dev/null"
  # HACK: "" cannot be used as a default because of https://github.com/hashicorp/hil/issues/50
}

variable "gpg_keys" {
  description = "salt/ relative paths of gpg keys that you want to add to your VMs, see README_ADVANCED.md"
  default = []
}

// Provider-specific variables

variable "image" {
  description = "Leave default for automatic selection or specify sles12sp2 only if version is 3.0-released or 3.0-nightly"
  default = "default"
}

variable "flavor" {
  description = "OpenStack flavor"
  default = "m1.medium"
}

variable "root_volume_size" {
  description = "Size of the root volume in GiB"
  default = 10
}

variable "floating_ips" {
  description = "List of floating IP IDs to associate"
  default = []
}
