
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

module "server" {
  source                         = "../server"
  base_configuration             = module.base.configuration
  product_version                = var.product_version
  image                          = lookup(local.images, "server", "default")
  name                           = lookup(local.names, "server", "srv")
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
  additional_repos               = lookup(local.additional_repos, "server", {})

  saltapi_tcpdump   = var.saltapi_tcpdump
  provider_settings = lookup(local.provider_settings_by_host, "server", {})
}

module "proxy" {
  source = "../proxy"

  quantity = contains(local.hosts, "proxy") ? 1 : 0

  base_configuration = module.base.configuration
  product_version    = var.product_version
  image              = lookup(local.images, "proxy", "default")
  name               = lookup(local.names, "proxy", "pxy")

  server_configuration      = { hostname = local.server_full_name, username = "admin", password = "admin" }
  auto_register             = false
  auto_connect_to_master    = false
  download_private_ssl_key  = false
  install_proxy_pattern     = false
  auto_configure            = false
  generate_bootstrap_script = false
  publish_private_ssl_key   = false
  use_os_released_updates   = true
  ssh_key_path              = "./salt/controller/id_rsa.pub"

  additional_repos  = lookup(local.additional_repos, "proxy", {})
  provider_settings = lookup(local.provider_settings_by_host, "proxy", {})
}

locals {
  proxy_full_name       = "${var.name_prefix}pxy.${var.domain}"
  minimal_configuration = { hostname = contains(local.hosts, "proxy") ? local.proxy_full_name : local.server_full_name }
}

module "suse-client" {
  source             = "../client"

  quantity = contains(local.hosts, "suse-client") ? 1 : 0
  base_configuration = module.base.configuration
  product_version    = var.product_version
  image              = lookup(local.images, "suse-client", "sles12sp4o")
  name               = lookup(local.names, "suse-client", "cli-sles12")

  server_configuration = local.minimal_configuration

  auto_register           = false
  use_os_released_updates = true
  ssh_key_path            = "./salt/controller/id_rsa.pub"

  additional_repos  = lookup(local.additional_repos, "suse-client", {})
  provider_settings = lookup(local.provider_settings_by_host, "suse-client", {})
}

module "suse-minion" {
  source             = "../minion"

  quantity = contains(local.hosts, "suse-minion") ? 1 : 0
  base_configuration = module.base.configuration
  product_version    = var.product_version
  image              = lookup(local.images, "suse-minion", "sles12sp4o")
  name               = lookup(local.names, "suse-minion", "min-sles12")

  server_configuration = local.minimal_configuration

  auto_connect_to_master  = false
  use_os_released_updates = true
  ssh_key_path            = "./salt/controller/id_rsa.pub"

  additional_repos  = lookup(local.additional_repos, "suse-minion", {})
  provider_settings = lookup(local.provider_settings_by_host, "suse-minion", {})
}

module "build-host" {
  source = "../minion"

  quantity           = contains(local.hosts, "build-host") ? 1 : 0
  base_configuration = module.base.configuration
  product_version    = var.product_version
  image              = lookup(local.images, "build-host", "sles12sp4o")
  name               = lookup(local.names, "build-host", "min-build")

  server_configuration = local.minimal_configuration

  auto_connect_to_master  = false
  use_os_released_updates = true
  ssh_key_path            = "./salt/controller/id_rsa.pub"
  avahi_reflector         = var.avahi_reflector

  additional_repos  = lookup(local.additional_repos, "build-host", {})
  provider_settings = lookup(local.provider_settings_by_host, "build-host", {})
}

module "suse-sshminion" {
  source = "../sshminion"

  quantity = contains(local.hosts, "suse-sshminion") ? 1 : 0

  base_configuration = module.base.configuration
  product_version    = var.product_version
  image              = lookup(local.images, "suse-sshminion", "sles12sp4o")
  name               = lookup(local.names, "suse-sshminion", "minssh-sles12")

  use_os_released_updates = true
  ssh_key_path            = "./salt/controller/id_rsa.pub"
  gpg_keys                = ["default/gpg_keys/galaxy.key"]

  additional_repos  = lookup(local.additional_repos, "suse-sshminion", {})
  provider_settings = lookup(local.provider_settings_by_host, "suse-sshminion", {})
}

module "redhat-minion" {
  source = "../minion"

  quantity = contains(local.hosts, "redhat-minion") ? 1 : 0

  base_configuration = module.base.configuration
  product_version    = var.product_version
  image              = lookup(local.images, "redhat-minion", "centos7o")
  name               = lookup(local.names, "redhat-minion", "min-centos7")

  server_configuration   = local.minimal_configuration
  auto_connect_to_master = false
  ssh_key_path           = "./salt/controller/id_rsa.pub"

  additional_repos  = lookup(local.additional_repos, "redhat-minion", {})
  provider_settings = lookup(local.provider_settings_by_host, "redhat-minion", {})
}

module "debian-minion" {
  source = "../minion"

  quantity = contains(local.hosts, "debian-minion") ? 1 : 0

  base_configuration = module.base.configuration
  product_version    = var.product_version
  image              = lookup(local.images, "debian-minion", "ubuntu1804o")
  name               = lookup(local.names, "debian-minion", "min-ubuntu1804")

  server_configuration   = local.minimal_configuration
  auto_connect_to_master = false
  ssh_key_path           = "./salt/controller/id_rsa.pub"

  additional_repos  = lookup(local.additional_repos, "debian-minion", {})
  provider_settings = lookup(local.provider_settings_by_host, "debian-minion", {})
}

module "pxeboot-minion" {
  source = "../pxe_boot"

  quantity = contains(local.hosts, "pxeboot-minion") ? 1 : 0

  base_configuration = module.base.configuration
  image              = lookup(local.images, "pxeboot-minion", "sles12sp3")
  name               = lookup(local.names, "pxeboot-minion", "min-pxeboot")
  provider_settings  = lookup(local.provider_settings_by_host, "pxeboot-minion", {})
}

module "kvm-host" {
  source = "../virthost"

  quantity = contains(local.hosts, "kvm-host") ? 1 : 0

  base_configuration = module.base.configuration
  product_version    = var.product_version
  image              = lookup(local.images, "kvm-host", "sles15sp1o")
  name               = lookup(local.names, "kvm-host", "min-kvm")

  server_configuration = local.minimal_configuration

  auto_connect_to_master  = false
  use_os_released_updates = true
  ssh_key_path            = "./salt/controller/id_rsa.pub"

  additional_repos  = lookup(local.additional_repos, "kvm-host", {})
  provider_settings = lookup(local.provider_settings_by_host, "kvm-host", {})
}

module "xen-host" {
  source = "../virthost"

  quantity = contains(local.hosts, "xen-host") ? 1 : 0

  base_configuration = module.base.configuration
  product_version    = var.product_version
  image              = lookup(local.images, "xen-host", "sles15sp1")
  name               = lookup(local.names, "xen-host", "min-xen")
  hypervisor         = "xen"

  server_configuration = local.minimal_configuration

  auto_connect_to_master  = false
  use_os_released_updates = true
  ssh_key_path            = "./salt/controller/id_rsa.pub"

  additional_repos  = lookup(local.additional_repos, "xen-host", {})
  provider_settings = lookup(local.provider_settings_by_host, "xen-host", {})
}

module "controller" {
  source = "../controller"
  name   = lookup(local.names, "controller", "ctl")

  base_configuration      = module.base.configuration
  server_configuration    = module.server.configuration
  proxy_configuration     = contains(local.hosts, "proxy") ? module.proxy.configuration : { hostname = null }
  client_configuration    = contains(local.hosts, "suse-client") ? module.suse-client.configuration : { hostnames = [], ids = [] }
  minion_configuration    = contains(local.hosts, "suse-minion") ? module.suse-minion.configuration : { hostnames = [], ids = [] }
  buildhost_configuration = contains(local.hosts, "build-host") ? module.build-host.configuration : { hostnames = [], ids = [] }
  sshminion_configuration = contains(local.hosts, "suse-sshminion") ? module.suse-sshminion.configuration : { hostnames = [], ids = [] }
  redhat_configuration    = contains(local.hosts, "redhat-minion") ? module.redhat-minion.configuration : { hostnames = [], ids = [] }
  debian_configuration    = contains(local.hosts, "debian-minion") ? module.debian-minion.configuration : { hostnames = [], ids = [] }
  pxeboot_configuration   = contains(local.hosts, "pxeboot-minion") ? module.pxeboot-minion.configuration : { macaddr = null, image = null }
  kvmhost_configuration   = contains(local.hosts, "kvm-host") ? module.kvm-host.configuration : { hostnames = [], ids = [] }
  xenhost_configuration   = contains(local.hosts, "xen-host") ? module.xen-host.configuration : { hostnames = [], ids = [] }

  branch                 = var.branch
  git_username           = var.git_username
  git_password           = var.git_password
  git_repo               = var.git_repo
  git_profiles_repo      = var.git_profiles_repo
  no_auth_registry       = var.no_auth_registry
  auth_registry          = var.auth_registry
  auth_registry_username = var.auth_registry_username
  auth_registry_password = var.auth_registry_password
  server_http_proxy      = var.server_http_proxy
  swap_file_size         = null

  additional_repos  = lookup(local.additional_repos, "controller", {})
  provider_settings = lookup(local.provider_settings_by_host, "controller", {})
}

output "configuration" {
  value = {
    base = module.base.configuration
    server = module.server.configuration
    proxy = module.proxy.configuration
    suse-client = module.suse-client.configuration
    suse-minion = module.suse-minion.configuration
    build-host = module.build-host.configuration
    suse-sshminion = module.suse-sshminion.configuration
    redhat-minion = module.redhat-minion.configuration
    debian-minion = module.debian-minion.configuration
    pxeboot-minion = module.pxeboot-minion.configuration
    kvm-host = module.kvm-host.configuration
    xen-host = module.xen-host.configuration
    controller = module.controller.configuration
  }
}
