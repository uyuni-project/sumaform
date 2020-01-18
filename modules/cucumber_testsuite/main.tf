
module "base" {
  source = "../base"

  cc_username          = var.cc_username
  cc_password          = var.cc_password
  use_avahi            = var.use_avahi
  domain               = var.domain
  name_prefix          = var.name_prefix
  images               = var.images
  mirror               = var.mirror
  use_mirror_images    = var.use_mirror_images
  use_shared_resources = var.use_shared_resources
  testsuite            = true

  provider_settings = var.provider_settings
}

locals {
  server_full_name          = "${var.name_prefix}srv.${var.domain}"
  hosts                     = keys(var.host_settings)
  provider_settings_by_host = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "provider_settings", {}) if var.host_settings[host_key] != null }
  additional_repos          = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "additional_repos", {}) if var.host_settings[host_key] != null }
  images                    = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "image", "default") if var.host_settings[host_key] != null ? contains(keys(var.host_settings[host_key]), "image") : false }
  names                     = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "name", null) if var.host_settings[host_key] != null ? contains(keys(var.host_settings[host_key]), "name") : false }
}

module "srv" {
  source                         = "../server"
  base_configuration             = module.base.configuration
  product_version                = var.product_version
  image                          = lookup(local.images, "srv", "default")
  name                           = lookup(local.names, "srv", "srv")
  auto_accept                    = false
  disable_firewall               = false
  allow_postgres_connections     = false
  skip_changelog_import          = false
  browser_side_less              = false
  create_first_user              = false
  mgr_sync_autologin             = false
  create_sample_channel          = false
  create_sample_activation_key   = false
  create_sample_bootstrap_script = false
  publish_private_ssl_key        = false
  disable_download_tokens        = false
  monitored                      = true
  use_os_released_updates        = true
  ssh_key_path                   = "./salt/controller/id_rsa.pub"
  from_email                     = var.from_email
  additional_repos               = lookup(local.additional_repos, "srv", {})

  saltapi_tcpdump   = var.saltapi_tcpdump
  provider_settings = lookup(local.provider_settings_by_host, "srv", {})
}

module "pxy" {
  source = "../proxy"

  quantity = contains(local.hosts, "pxy") ? 1 : 0

  base_configuration = module.base.configuration
  product_version    = var.product_version
  image              = lookup(local.images, "pxy", "default")
  name               = lookup(local.names, "pxy", "pxy")

  server_configuration      = { hostname = local.server_full_name, username = "admin", password = "admin" }
  auto_register             = false
  auto_connect_to_master    = false
  download_private_ssl_key  = false
  auto_configure            = false
  generate_bootstrap_script = false
  publish_private_ssl_key   = false
  use_os_released_updates   = true
  ssh_key_path              = "./salt/controller/id_rsa.pub"

  additional_repos  = lookup(local.additional_repos, "pxy", {})
  provider_settings = lookup(local.provider_settings_by_host, "pxy", {})
}

locals {
  proxy_full_name       = "${var.name_prefix}pxy.${var.domain}"
  minimal_configuration = { hostname = contains(local.hosts, "pxy") ? local.proxy_full_name : local.server_full_name }
}

module "cli-sles12sp4" {
  source             = "../client"

  quantity = contains(local.hosts, "cli-sles12sp4") ? 1 : 0
  base_configuration = module.base.configuration
  product_version    = var.product_version
  image              = lookup(local.images, "cli-sles12sp4", "sles12sp4")
  name               = lookup(local.names, "cli-sles12sp4", "cli-sles12")

  server_configuration = local.minimal_configuration

  auto_register           = false
  use_os_released_updates = true
  ssh_key_path            = "./salt/controller/id_rsa.pub"

  additional_repos  = lookup(local.additional_repos, "cli-sles12sp4", {})
  provider_settings = lookup(local.provider_settings_by_host, "cli-sles12sp4", {})
}

module "min-sles12sp4" {
  source             = "../minion"

  quantity = contains(local.hosts, "min-sles12sp4") ? 1 : 0
  base_configuration = module.base.configuration
  product_version    = var.product_version
  image              = lookup(local.images, "min-sles12sp4", "sles12sp4")
  name               = lookup(local.names, "min-sles12sp4", "min-sles12")

  server_configuration = local.minimal_configuration

  auto_connect_to_master  = false
  use_os_released_updates = true
  ssh_key_path            = "./salt/controller/id_rsa.pub"
  avahi_reflector         = var.avahi_reflector

  additional_repos  = lookup(local.additional_repos, "min-sles12sp4", {})
  provider_settings = lookup(local.provider_settings_by_host, "min-sles12sp4", {})
}

module "minssh-sles12sp4" {
  source = "../sshminion"

  quantity = contains(local.hosts, "minssh-sles12sp4") ? 1 : 0

  base_configuration = module.base.configuration
  product_version    = var.product_version
  image              = lookup(local.images, "minssh-sles12sp4", "sles12sp4")
  name               = lookup(local.names, "minssh-sles12sp4", "minssh-sles12")

  use_os_released_updates = true
  ssh_key_path            = "./salt/controller/id_rsa.pub"
  gpg_keys                = ["default/gpg_keys/galaxy.key"]

  additional_repos  = lookup(local.additional_repos, "minssh-sles12sp4", {})
  provider_settings = lookup(local.provider_settings_by_host, "minssh-sles12sp4", {})
}

module "min-centos7" {
  source = "../minion"

  quantity = contains(local.hosts, "min-centos7") ? 1 : 0

  base_configuration = module.base.configuration
  product_version    = var.product_version
  image              = lookup(local.images, "min-centos7", "centos7")
  name               = lookup(local.names, "min-centos7", "min-centos7")

  server_configuration   = local.minimal_configuration
  auto_connect_to_master = false
  ssh_key_path           = "./salt/controller/id_rsa.pub"

  additional_repos  = lookup(local.additional_repos, "min-centos7", {})
  provider_settings = lookup(local.provider_settings_by_host, "min-centos7", {})
}

module "min-ubuntu1804" {
  source = "../minion"

  quantity = contains(local.hosts, "min-ubuntu1804") ? 1 : 0

  base_configuration = module.base.configuration
  product_version    = var.product_version
  image              = lookup(local.images, "min-ubuntu1804", "ubuntu1804")
  name               = lookup(local.names, "min-ubuntu1804", "min-ubuntu1804")

  server_configuration   = local.minimal_configuration
  auto_connect_to_master = false
  ssh_key_path           = "./salt/controller/id_rsa.pub"

  additional_repos  = lookup(local.additional_repos, "min-ubuntu1804", {})
  provider_settings = lookup(local.provider_settings_by_host, "min-ubuntu1804", {})
}

module "min-pxeboot" {
  source = "../pxe_boot"

  quantity = contains(local.hosts, "min-pxeboot") ? 1 : 0

  base_configuration = module.base.configuration
  image              = lookup(local.images, "min-pxeboot", "sles12sp3")
  name               = lookup(local.names, "min-pxeboot", "min-pxeboot")
}

module "min-kvm" {
  source = "../virthost"

  quantity = contains(local.hosts, "min-kvm") ? 1 : 0

  base_configuration = module.base.configuration
  product_version    = var.product_version
  image              = lookup(local.images, "min-kvm", "sles15sp1")
  name               = lookup(local.names, "min-kvm", "min-kvm")

  ssh_key_path         = "./salt/controller/id_rsa.pub"
  server_configuration = local.minimal_configuration

  auto_connect_to_master = false

  additional_repos  = lookup(local.additional_repos, "min-kvm", {})
  provider_settings = lookup(local.provider_settings_by_host, "min-kvm", {})
}

module "ctl" {
  source = "../controller"
  name   = lookup(local.names, "ctl", "ctl")

  base_configuration      = module.base.configuration
  server_configuration    = module.srv.configuration
  proxy_configuration     = contains(local.hosts, "pxy") ? module.pxy.configuration : { hostname = null }
  client_configuration    = contains(local.hosts, "cli-sles12sp4") ? module.cli-sles12sp4.configuration : { hostnames = [], ids = [] }
  minion_configuration    = contains(local.hosts, "min-sles12sp4") ? module.min-sles12sp4.configuration : { hostnames = [], ids = [] }
  centos_configuration    = contains(local.hosts, "min-centos7") ? module.min-centos7.configuration : { hostnames = [], ids = [] }
  ubuntu_configuration    = contains(local.hosts, "min-ubuntu1804") ? module.min-ubuntu1804.configuration : { hostnames = [], ids = [] }
  sshminion_configuration = contains(local.hosts, "minssh-sles12sp4") ? module.minssh-sles12sp4.configuration : { hostnames = [], ids = [] }
  pxeboot_configuration   = contains(local.hosts, "min-pxeboot") ? module.min-pxeboot.configuration : { macaddr = null, image = null }
  kvmhost_configuration   = contains(local.hosts, "min-kvm") ? module.min-kvm.configuration : { hostnames = [], ids = [] }

  branch            = var.branch
  git_username      = var.git_username
  git_password      = var.git_password
  git_repo          = var.git_repo
  git_profiles_repo = var.git_profiles_repo
  portus_uri        = var.portus_uri
  portus_username   = var.portus_username
  portus_password   = var.portus_password
  server_http_proxy = var.server_http_proxy

  additional_repos  = lookup(local.additional_repos, "ctl", {})
  provider_settings = lookup(local.provider_settings_by_host, "ctl", {})
}
