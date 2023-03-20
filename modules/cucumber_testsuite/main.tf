
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
  ssh_key_path         = var.ssh_key_path
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
  additional_repos_only     = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "additional_repos_only", {}) if var.host_settings[host_key] != null }
  additional_packages       = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "additional_packages", []) if var.host_settings[host_key] != null }
  additional_grains       = { for host_key in local.hosts :
  host_key => lookup(var.host_settings[host_key], "additional_grains", {}) if var.host_settings[host_key] != null }
  images                    = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "image", "default") if var.host_settings[host_key] != null ? contains(keys(var.host_settings[host_key]), "image") : false }
  names                     = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "name", null) if var.host_settings[host_key] != null ? contains(keys(var.host_settings[host_key]), "name") : false }
  install_salt_bundle       = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "install_salt_bundle", false) if var.host_settings[host_key] != null }
  server_mounted_mirror     = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "server_mounted_mirror", {}) if var.host_settings[host_key] != null }
  sles_registration_code    = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "sles_registration_code", null) if var.host_settings[host_key] != null }
  runtimes    = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "runtime", "podman") if var.host_settings[host_key] != null }
  container_repositories    = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "container_repository", null) if var.host_settings[host_key] != null }
}

module "server" {
  source                         = "../server"

  quantity = contains(local.hosts, "server") ? 1 : 0

  base_configuration             = module.base.configuration
  product_version                = var.product_version
  image                          = lookup(local.images, "server", "default")
  name                           = lookup(local.names, "server", "srv")
  auto_accept                    = false
  download_private_ssl_key       = false
  disable_firewall               = false
  allow_postgres_connections     = false
  skip_changelog_import          = false
  create_first_user              = false
  mgr_sync_autologin             = false
  create_sample_channel          = false
  create_sample_activation_key   = false
  create_sample_bootstrap_script = false
  publish_private_ssl_key        = false
  disable_download_tokens        = false
  forward_registration           = false
  monitored                      = true
  use_os_released_updates        = true
  install_salt_bundle            = lookup(local.install_salt_bundle, "server", false)
  ssh_key_path                   = "./salt/controller/id_rsa.pub"
  from_email                     = var.from_email
  additional_repos               = lookup(local.additional_repos, "server", {})
  additional_repos_only          = lookup(local.additional_repos_only, "server", {})
  additional_packages            = lookup(local.additional_packages, "server", [])
  login_timeout                  = var.login_timeout

  saltapi_tcpdump   = var.saltapi_tcpdump
  provider_settings = lookup(local.provider_settings_by_host, "server", {})
  server_mounted_mirror         = lookup(local.server_mounted_mirror, "server", {})
}

module "server_containerized" {
  source                         = "../server_containerized"

  quantity = contains(local.hosts, "server_containerized") ? 1 : 0

  base_configuration             = module.base.configuration
  product_version                = var.product_version
  image                          = lookup(local.images, "server_containerized", "default")
  name                           = lookup(local.names, "server_containerized", "srv")
  runtime                        = lookup(local.runtimes, "server_containerized", "podman")
  container_repository           = lookup(local.container_repositories, "server_containerized", "")
  auto_accept                    = false
  download_private_ssl_key       = false
  disable_firewall               = false
  allow_postgres_connections     = false
  skip_changelog_import          = false
  create_first_user              = false
  mgr_sync_autologin             = false
  create_sample_channel          = false
  create_sample_activation_key   = false
  create_sample_bootstrap_script = false
  publish_private_ssl_key        = false
  disable_download_tokens        = false
  //forward_registration           = false
  use_os_released_updates        = true
  install_salt_bundle            = lookup(local.install_salt_bundle, "server_containerized", false)
  ssh_key_path                   = "./salt/controller/id_rsa.pub"
  from_email                     = var.from_email
  additional_repos               = lookup(local.additional_repos, "server_containerized", {})
  additional_repos_only          = lookup(local.additional_repos_only, "server_containerized", {})
  additional_packages            = lookup(local.additional_packages, "server_containerized", [])
  //login_timeout                  = var.login_timeout

  //saltapi_tcpdump   = var.saltapi_tcpdump
  provider_settings = lookup(local.provider_settings_by_host, "server_containerized", {})
  server_mounted_mirror         = lookup(local.server_mounted_mirror, "server_containerized", {})
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
  install_salt_bundle = lookup(local.install_salt_bundle, "proxy", false)

  additional_repos  = lookup(local.additional_repos, "proxy", {})
  additional_repos_only  = lookup(local.additional_repos_only, "proxy", {})
  additional_packages = lookup(local.additional_packages, "proxy", [])
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
  image              = lookup(local.images, "suse-client", "sles15sp4o")
  name               = lookup(local.names, "suse-client", "cli-sles15")

  server_configuration = local.minimal_configuration
  sles_registration_code = lookup(local.sles_registration_code, "suse-client", null)

  auto_register           = false
  use_os_released_updates = true
  ssh_key_path            = "./salt/controller/id_rsa.pub"
  install_salt_bundle     = lookup(local.install_salt_bundle, "suse-client", false)

  additional_repos  = lookup(local.additional_repos, "suse-client", {})
  additional_repos_only  = lookup(local.additional_repos_only, "suse-client", {})
  additional_packages = lookup(local.additional_packages, "suse-client", [])
  provider_settings = lookup(local.provider_settings_by_host, "suse-client", {})
}

module "suse-minion" {
  source             = "../minion"

  quantity = contains(local.hosts, "suse-minion") ? 1 : 0
  base_configuration = module.base.configuration
  product_version    = var.product_version
  image              = lookup(local.images, "suse-minion", "sles15sp4o")
  name               = lookup(local.names, "suse-minion", "min-sles15")

  server_configuration = local.minimal_configuration
  sles_registration_code = lookup(local.sles_registration_code, "suse-minion", null)

  auto_connect_to_master  = false
  use_os_released_updates = true
  ssh_key_path            = "./salt/controller/id_rsa.pub"
  install_salt_bundle     = lookup(local.install_salt_bundle, "suse-minion", false)

  additional_repos  = lookup(local.additional_repos, "suse-minion", {})
  additional_repos_only  = lookup(local.additional_repos_only, "suse-minion", {})
  additional_packages = lookup(local.additional_packages, "suse-minion", [])
  additional_grains = lookup(local.additional_grains, "suse-minion", {})
  provider_settings = lookup(local.provider_settings_by_host, "suse-minion", {})
}

module "suse-sshminion" {
  source = "../sshminion"

  quantity = contains(local.hosts, "suse-sshminion") ? 1 : 0

  base_configuration = module.base.configuration
  product_version    = var.product_version
  image              = lookup(local.images, "suse-sshminion", "sles15sp4o")
  name               = lookup(local.names, "suse-sshminion", "minssh-sles15")
  sles_registration_code = lookup(local.sles_registration_code, "suse-sshminion", null)

  use_os_released_updates = true
  ssh_key_path            = "./salt/controller/id_rsa.pub"
  gpg_keys                = ["default/gpg_keys/galaxy.key"]
  install_salt_bundle     = lookup(local.install_salt_bundle, "suse-sshminion", false)

  additional_repos  = lookup(local.additional_repos, "suse-sshminion", {})
  additional_repos_only  = lookup(local.additional_repos_only, "suse-sshminion", {})
  additional_packages = lookup(local.additional_packages, "suse-sshminion", [])
  provider_settings = lookup(local.provider_settings_by_host, "suse-sshminion", {})
}

module "slemicro-minion" {
  source = "../minion"

  quantity = contains(local.hosts, "slemicro-minion") ? 1 : 0
  base_configuration = module.base.configuration
  product_version    = var.product_version
  image              = lookup(local.images, "slemicro-minion", "slemicro53-ign")
  name               = lookup(local.names, "slemicro-minion", "min-slemicro5")

  server_configuration = local.minimal_configuration
  sles_registration_code = lookup(local.sles_registration_code, "slemicro-minion", null)

  use_os_released_updates = true
  ssh_key_path            = "./salt/controller/id_rsa.pub"
  install_salt_bundle     = lookup(local.install_salt_bundle, "slemicro-minion", false)

  additional_repos  = lookup(local.additional_repos, "slemicro-minion", {})
  additional_repos_only  = lookup(local.additional_repos_only, "slemicro-minion", {})
  additional_packages = lookup(local.additional_packages, "slemicro-minion", ["avahi", "avahi-lang", "libavahi-common3", "libavahi-core7"])
  additional_grains = lookup(local.additional_grains, "slemicro-minion", {})
  provider_settings = lookup(local.provider_settings_by_host, "slemicro-minion", {})
}

module "redhat-minion" {
  source = "../minion"

  quantity = contains(local.hosts, "redhat-minion") ? 1 : 0

  base_configuration = module.base.configuration
  product_version    = var.product_version
  image              = lookup(local.images, "redhat-minion", "rocky8o")
  name               = lookup(local.names, "redhat-minion", "min-rocky8")

  server_configuration   = local.minimal_configuration

  auto_connect_to_master = false
  ssh_key_path           = "./salt/controller/id_rsa.pub"
  install_salt_bundle    = lookup(local.install_salt_bundle, "redhat-minion", false)

  additional_repos  = lookup(local.additional_repos, "redhat-minion", {})
  additional_repos_only  = lookup(local.additional_repos_only, "redhat-minion", {})
  additional_packages = lookup(local.additional_packages, "redhat-minion", [])
  additional_grains = lookup(local.additional_grains, "redhat-minion", {})
  provider_settings = lookup(local.provider_settings_by_host, "redhat-minion", {})
}

module "debian-minion" {
  source = "../minion"

  quantity = contains(local.hosts, "debian-minion") ? 1 : 0

  base_configuration = module.base.configuration
  product_version    = var.product_version
  image              = lookup(local.images, "debian-minion", "ubuntu2204o")
  name               = lookup(local.names, "debian-minion", "min-ubuntu2204")

  server_configuration   = local.minimal_configuration

  auto_connect_to_master = false
  ssh_key_path           = "./salt/controller/id_rsa.pub"
  install_salt_bundle    = lookup(local.install_salt_bundle, "debian-minion", false)

  additional_repos  = lookup(local.additional_repos, "debian-minion", {})
  additional_repos_only  = lookup(local.additional_repos_only, "debian-minion", {})
  additional_packages = lookup(local.additional_packages, "debian-minion", [])
  additional_grains = lookup(local.additional_grains, "debian-minion", {})
  provider_settings = lookup(local.provider_settings_by_host, "debian-minion", {})
}

module "build-host" {
  source = "../build_host"

  quantity           = contains(local.hosts, "build-host") ? 1 : 0
  base_configuration = module.base.configuration
  product_version    = var.product_version
  image              = lookup(local.images, "build-host", "sles15sp4o")
  name               = lookup(local.names, "build-host", "min-build")

  server_configuration = local.minimal_configuration

  auto_connect_to_master  = false
  use_os_released_updates = true
  ssh_key_path            = "./salt/controller/id_rsa.pub"
  avahi_reflector         = var.avahi_reflector
  install_salt_bundle     = lookup(local.install_salt_bundle, "build-host", false)

  additional_repos  = lookup(local.additional_repos, "build-host", {})
  additional_repos_only  = lookup(local.additional_repos_only, "build-host", {})
  additional_packages = lookup(local.additional_packages, "build-host", [])
  provider_settings = lookup(local.provider_settings_by_host, "build-host", {})
}

module "pxeboot-minion" {
  source = "../pxe_boot"

  quantity = contains(local.hosts, "pxeboot-minion") ? 1 : 0
  base_configuration = module.base.configuration
  image              = lookup(local.images, "pxeboot-minion", "sles15sp4o")
  name               = lookup(local.names, "pxeboot-minion", "min-pxeboot")

  provider_settings  = lookup(local.provider_settings_by_host, "pxeboot-minion", {})
}

module "kvm-host" {
  source = "../virthost"

  quantity = contains(local.hosts, "kvm-host") ? 1 : 0

  base_configuration = module.base.configuration
  product_version    = var.product_version
  image              = lookup(local.images, "kvm-host", "sles15sp4o")
  name               = lookup(local.names, "kvm-host", "min-kvm")

  server_configuration = local.minimal_configuration
  sles_registration_code = lookup(local.sles_registration_code, "kvm-host", null)

  auto_connect_to_master  = false
  use_os_released_updates = true
  ssh_key_path            = "./salt/controller/id_rsa.pub"
  install_salt_bundle     = lookup(local.install_salt_bundle, "kvm-host", false)

  additional_repos  = lookup(local.additional_repos, "kvm-host", {})
  additional_repos_only  = lookup(local.additional_repos_only, "kvm-host", {})
  additional_packages = lookup(local.additional_packages, "kvm-host", [])
  additional_grains = lookup(local.additional_grains, "kvm-host", {})
  provider_settings = lookup(local.provider_settings_by_host, "kvm-host", {})
}

module "monitoring-server" {
  source = "../minion"

  quantity = contains(local.hosts, "monitoring-server") ? 1 : 0

  base_configuration = module.base.configuration
  product_version    = var.product_version
  image              = lookup(local.images, "monitoring-server", "sles15sp4o")
  name               = lookup(local.names, "monitoring-server", "min-monitoring")

  server_configuration = local.minimal_configuration
  sles_registration_code = lookup(local.sles_registration_code, "monitoring-server", null)

  auto_connect_to_master  = false
  use_os_released_updates = true
  ssh_key_path            = "./salt/controller/id_rsa.pub"
  install_salt_bundle     = lookup(local.install_salt_bundle, "monitoring-server", false)

  additional_repos  = lookup(local.additional_repos, "monitoring-server", {})
  additional_repos_only  = lookup(local.additional_repos_only, "monitoring-server", {})
  additional_packages = lookup(local.additional_packages, "monitoring-server", [])
  additional_grains = lookup(local.additional_grains, "monitoring-server", {})
  provider_settings = lookup(local.provider_settings_by_host, "monitoring-server", {})
}

module "controller" {
  source = "../controller"
  name   = lookup(local.names, "controller", "ctl")

  base_configuration             = module.base.configuration
  server_configuration           = contains(local.hosts, "server") ? module.server.configuration : module.server_containerized.configuration
  proxy_configuration            = contains(local.hosts, "proxy") ? module.proxy.configuration : { hostname = null }
  client_configuration           = contains(local.hosts, "suse-client") ? module.suse-client.configuration : { hostnames = [], ids = [], ipaddrs = [], macaddrs = [] }
  minion_configuration           = contains(local.hosts, "suse-minion") ? module.suse-minion.configuration : { hostnames = [], ids = [], ipaddrs = [], macaddrs = [] }
  sshminion_configuration        = contains(local.hosts, "suse-sshminion") ? module.suse-sshminion.configuration : { hostnames = [], ids = [], ipaddrs = [], macaddrs = [] }
  slemicro_minion_configuration  = contains(local.hosts, "slemicro-minion") ? module.slemicro-minion.configuration : { hostnames = [], ids = [], ipaddrs = [], macaddrs = [] }  
  redhat_configuration           = contains(local.hosts, "redhat-minion") ? module.redhat-minion.configuration : { hostnames = [], ids = [], ipaddrs = [], macaddrs = [] }
  debian_configuration           = contains(local.hosts, "debian-minion") ? module.debian-minion.configuration : { hostnames = [], ids = [], ipaddrs = [], macaddrs = [] }
  buildhost_configuration        = contains(local.hosts, "build-host") ? module.build-host.configuration : { hostnames = [], ids = [], ipaddrs = [], macaddrs = [] }
  pxeboot_configuration          = contains(local.hosts, "pxeboot-minion") ? module.pxeboot-minion.configuration : { macaddr = null, image = null }
  kvmhost_configuration          = contains(local.hosts, "kvm-host") ? module.kvm-host.configuration : { hostnames = [], ids = [], ipaddrs = [], macaddrs = [] }
  monitoringserver_configuration = contains(local.hosts, "monitoring-server") ? module.monitoring-server.configuration : { hostnames = [], ids = [], ipaddrs = [], macaddrs = [] }

  branch                   = var.branch
  git_username             = var.git_username
  nested_vm_host          = var.nested_vm_host
  nested_vm_mac           = var.nested_vm_mac
  git_password             = var.git_password
  git_repo                 = var.git_repo
  git_profiles_repo        = var.git_profiles_repo
  no_auth_registry         = var.no_auth_registry
  auth_registry            = var.auth_registry
  auth_registry_username   = var.auth_registry_username
  auth_registry_password   = var.auth_registry_password
  server_http_proxy        = var.server_http_proxy
  custom_download_endpoint = var.custom_download_endpoint
  swap_file_size           = null

  additional_repos  = lookup(local.additional_repos, "controller", {})
  additional_repos_only  = lookup(local.additional_repos_only, "controller", {})
  additional_packages = lookup(local.additional_packages, "controller", [])
  provider_settings = lookup(local.provider_settings_by_host, "controller", {})
}

output "configuration" {
  value = {
    base = module.base.configuration
    server = module.server.configuration
    server = contains(local.hosts, "server") ? module.server.configuration : module.server_containerized.configuration
    proxy = module.proxy.configuration
    suse-client = module.suse-client.configuration
    slemicro-minion = module.slemicro-minion.configuration
    suse-minion = module.suse-minion.configuration
    suse-sshminion = module.suse-sshminion.configuration
    redhat-minion = module.redhat-minion.configuration
    debian-minion = module.debian-minion.configuration
    build-host = module.build-host.configuration
    pxeboot-minion = module.pxeboot-minion.configuration
    kvm-host = module.kvm-host.configuration
    monitoring-server = module.monitoring-server.configuration
    controller = module.controller.configuration
  }
}
