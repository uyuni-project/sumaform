
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
  product_version      = var.product_version
  testsuite            = true

  provider_settings = var.provider_settings
}

locals {
  server_full_name          = "${var.name_prefix}server.${var.domain}"
  proxy_full_name           = "${var.name_prefix}proxy.${var.domain}"

  hosts                     = keys(var.host_settings)
  provider_settings_by_host = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "provider_settings", {}) if var.host_settings[host_key] != null }
  additional_repos          = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "additional_repos", {}) if var.host_settings[host_key] != null }
  additional_repos_only     = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "additional_repos_only", false) if var.host_settings[host_key] != null }
  additional_packages       = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "additional_packages", []) if var.host_settings[host_key] != null }
  additional_grains         = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "additional_grains", {}) if var.host_settings[host_key] != null }
  private_ip                = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "private_ip", 4) if var.host_settings[host_key] != null }
  private_name              = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "private_name", "pxeboot") if var.host_settings[host_key] != null }
  images                    = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "image", "default") if var.host_settings[host_key] != null ? contains(keys(var.host_settings[host_key]), "image") : false }
  names                     = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "name", null) if var.host_settings[host_key] != null ? contains(keys(var.host_settings[host_key]), "name") : false }
  install_salt_bundle       = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "install_salt_bundle", true) if var.host_settings[host_key] != null }
  server_mounted_mirror     = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "server_mounted_mirror", {}) if var.host_settings[host_key] != null }
  sles_registration_code    = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "sles_registration_code", null) if var.host_settings[host_key] != null }
  runtimes                  = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "runtime", "podman") if var.host_settings[host_key] != null }
  container_repositories    = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "container_repository", null) if var.host_settings[host_key] != null }
  container_tags    = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "container_tag", null) if var.host_settings[host_key] != null }
  helm_chart_urls           = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "helm_chart_url", null) if var.host_settings[host_key] != null }
  main_disk_size            = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "main_disk_size", 200) if var.host_settings[host_key] != null }
  repository_disk_size      = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "repository_disk_size", 0) if var.host_settings[host_key] != null }
  database_disk_size        = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "database_disk_size", 0) if var.host_settings[host_key] != null }
  large_deployment          = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "large_deployment", false) if var.host_settings[host_key] != null }
  hypervisors               = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "hypervisor", null) if var.host_settings[host_key] != null }
  auto_configure            = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "auto_configure", false) if var.host_settings[host_key] != null }
  create_first_user         = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "create_first_user", false) if var.host_settings[host_key] != null }
  repository_disk_use_cloud_setup = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "repository_disk_use_cloud_setup", null) if var.host_settings[host_key] != null }
  scc_access_logging        = { for host_key in local.hosts :
    host_key => lookup(var.host_settings[host_key], "scc_access_logging", false) if var.host_settings[host_key] != null }

  minimal_configuration     = { hostname = contains(local.hosts, "proxy") ? local.proxy_full_name : local.server_full_name }
  server_configuration      = var.container_server ? module.server_containerized[0].configuration : module.server[0].configuration
  proxy_configuration       = var.container_proxy ? module.proxy_containerized[0].configuration : module.proxy[0].configuration
}

module "server" {
  source                         = "../server"

  count = var.container_server ? 0 : 1

  base_configuration             = module.base.configuration
  image                          = lookup(local.images, "server", "default")
  name                           = lookup(local.names, "server", "server")
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
  disable_auto_bootstrap         = false
  forward_registration           = false
  monitored                      = true
  use_os_released_updates        = false
  beta_enabled                   = var.beta_enabled
  install_salt_bundle            = lookup(local.install_salt_bundle, "server", true)
  ssh_key_path                   = "./salt/controller/id_rsa.pub"
  from_email                     = var.from_email
  additional_repos               = lookup(local.additional_repos, "server", {})
  additional_repos_only          = lookup(local.additional_repos_only, "server", false)
  additional_packages            = lookup(local.additional_packages, "server", [])
  login_timeout                  = var.login_timeout
  scc_access_logging             = lookup(local.scc_access_logging, "server", false)

  saltapi_tcpdump                 = var.saltapi_tcpdump
  provider_settings               = lookup(local.provider_settings_by_host, "server", {})
  server_mounted_mirror           = lookup(local.server_mounted_mirror, "server", {})
  main_disk_size                  = lookup(local.main_disk_size, "server", 200)
  repository_disk_size            = lookup(local.repository_disk_size, "server", 0)
  database_disk_size              = lookup(local.database_disk_size, "server", 0)
  large_deployment                = lookup(local.large_deployment, "server", false)
  repository_disk_use_cloud_setup = lookup(local.repository_disk_use_cloud_setup, "server", false)
}

module "server_containerized" {
  source                         = "../server_containerized"

  count = var.container_server ? 1 : 0

  base_configuration             = module.base.configuration
  image                          = lookup(local.images, "server_containerized", "default")
  name                           = lookup(local.names, "server_containerized", "server")
  runtime                        = lookup(local.runtimes, "server_containerized", "podman")
  container_repository           = lookup(local.container_repositories, "server_containerized", "")
  container_tag                  = lookup(local.container_tags, "server_containerized", "")
  auto_accept                    = false
  download_private_ssl_key       = false
  disable_firewall               = false
  allow_postgres_connections     = false
  skip_changelog_import          = false
  mgr_sync_autologin             = false
  create_sample_channel          = false
  create_sample_activation_key   = false
  create_sample_bootstrap_script = false
  publish_private_ssl_key        = false
  disable_download_tokens        = false
  //forward_registration           = false
  use_os_released_updates        = false
  beta_enabled                   = var.beta_enabled
  install_salt_bundle            = lookup(local.install_salt_bundle, "server_containerized", true)
  ssh_key_path                   = "./salt/controller/id_rsa.pub"
  from_email                     = var.from_email
  additional_repos               = lookup(local.additional_repos, "server_containerized", {})
  additional_repos_only          = lookup(local.additional_repos_only, "server_containerized", false)
  additional_packages            = lookup(local.additional_packages, "server_containerized", [])
  //login_timeout                  = var.login_timeout

  //saltapi_tcpdump               = var.saltapi_tcpdump
  provider_settings             = lookup(local.provider_settings_by_host, "server_containerized", {})
  server_mounted_mirror         = lookup(local.server_mounted_mirror, "server_containerized", {})
  main_disk_size                = lookup(local.main_disk_size, "server_containerized", 200)
  repository_disk_size          = lookup(local.repository_disk_size, "server_containerized", 0)
  database_disk_size            = lookup(local.database_disk_size, "server_containerized", 0)
  large_deployment              = lookup(local.large_deployment, "server_containerized", false)
}

module "proxy" {
  source = "../proxy"

  count = var.container_proxy ? 0 : 1

  quantity = contains(local.hosts, "proxy") ? 1 : 0

  base_configuration = module.base.configuration
  image              = lookup(local.images, "proxy", "default")
  name               = lookup(local.names, "proxy", "proxy")

  server_configuration      = { hostname = local.server_full_name, username = "admin", password = "admin" }
  auto_register             = false
  auto_connect_to_master    = false
  download_private_ssl_key  = false
  install_proxy_pattern     = false
  auto_configure            = false
  generate_bootstrap_script = false
  publish_private_ssl_key   = false
  use_os_released_updates   = false
  ssh_key_path              = "./salt/controller/id_rsa.pub"
  install_salt_bundle = lookup(local.install_salt_bundle, "proxy", true)

  additional_repos      = lookup(local.additional_repos, "proxy", {})
  additional_repos_only = lookup(local.additional_repos_only, "proxy", false)
  additional_packages   = lookup(local.additional_packages, "proxy", [])
  main_disk_size        = lookup(local.main_disk_size, "proxy", 200)
  repository_disk_size  = lookup(local.repository_disk_size, "proxy", 0)
  provider_settings     = lookup(local.provider_settings_by_host, "proxy", {})
}

module "proxy_containerized" {
  depends_on = [module.server_containerized]
  source = "../proxy_containerized"

  count = var.container_proxy ? 1 : 0
  quantity = contains(local.hosts, "proxy_containerized") ? 1 : 0

  base_configuration     = module.base.configuration
  image                  = lookup(local.images, "proxy_containerized", "default")
  name                   = lookup(local.names, "proxy_containerized", "proxy")

  runtime                = lookup(local.runtimes, "proxy_containerized", "podman")
  container_repository   = lookup(local.container_repositories, "proxy_containerized", "")
  container_tag          = lookup(local.container_tags, "proxy_containerized", "")
  helm_chart_url         = lookup(local.helm_chart_urls, "proxy_containerized", "")
  server_configuration   = { hostname = local.server_full_name,
                              username = "admin",
                              password = "admin",
                              create_first_user = lookup(local.create_first_user, "server_containerized", false) }

  auto_configure          = lookup(local.auto_configure, "proxy_containerized", false)

  ssh_key_path            = "./salt/controller/id_rsa.pub"
  install_salt_bundle     = lookup(local.install_salt_bundle, "proxy_containerized", true)
  use_os_released_updates = false
  additional_repos        = lookup(local.additional_repos, "proxy_containerized", {})
  additional_repos_only   = lookup(local.additional_repos_only, "proxy_containerized", false)
  additional_packages     = lookup(local.additional_packages, "proxy_containerized", [])
  main_disk_size          = lookup(local.main_disk_size, "proxy_containerized", 200)
  repository_disk_size    = lookup(local.repository_disk_size, "proxy_containerized", 0)
  provider_settings       = lookup(local.provider_settings_by_host, "proxy_containerized", {})
}

module "dhcp_dns" {
  source             = "../dhcp_dns"

  quantity           = contains(local.hosts, "dhcp_dns") ? 1 : 0
  base_configuration = module.base.configuration
  image              = lookup(local.images, "dhcp_dns", "opensuse155o")
  name               = lookup(local.names, "dhcp_dns", "dhcp-dns")

  private_hosts      = [ local.proxy_configuration, module.pxeboot_minion.configuration ]

  hypervisor         = lookup(local.hypervisors, "dhcp_dns", null)
}

module "suse_client" {
  source             = "../client"

  quantity = contains(local.hosts, "suse_client") ? 1 : 0
  base_configuration = module.base.configuration
  image              = lookup(local.images, "suse_client", "sles15sp4o")
  name               = lookup(local.names, "suse_client", "suse-client")

  server_configuration = local.minimal_configuration
  sles_registration_code = lookup(local.sles_registration_code, "suse_client", null)

  auto_register           = false
  use_os_released_updates = false
  ssh_key_path            = "./salt/controller/id_rsa.pub"
  install_salt_bundle     = lookup(local.install_salt_bundle, "suse_client", true)

  additional_repos  = lookup(local.additional_repos, "suse_client", {})
  additional_repos_only  = lookup(local.additional_repos_only, "suse_client", false)
  additional_packages = lookup(local.additional_packages, "suse_client", [])
  provider_settings = lookup(local.provider_settings_by_host, "suse_client", {})
}

module "suse_minion" {
  source             = "../minion"

  quantity = contains(local.hosts, "suse_minion") ? 1 : 0
  base_configuration = module.base.configuration
  image              = lookup(local.images, "suse_minion", "sles15sp4o")
  name               = lookup(local.names, "suse_minion", "suse-minion")

  server_configuration = local.minimal_configuration
  sles_registration_code = lookup(local.sles_registration_code, "suse_minion", null)

  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "./salt/controller/id_rsa.pub"
  install_salt_bundle     = lookup(local.install_salt_bundle, "suse_minion", true)

  additional_repos  = lookup(local.additional_repos, "suse_minion", {})
  additional_repos_only  = lookup(local.additional_repos_only, "suse_minion", false)
  additional_packages = lookup(local.additional_packages, "suse_minion", [])
  additional_grains = lookup(local.additional_grains, "suse_minion", {})
  provider_settings = lookup(local.provider_settings_by_host, "suse_minion", {})
}

module "suse_sshminion" {
  source = "../sshminion"

  quantity = contains(local.hosts, "suse_sshminion") ? 1 : 0

  base_configuration = module.base.configuration
  image              = lookup(local.images, "suse_sshminion", "sles15sp4o")
  name               = lookup(local.names, "suse_sshminion", "suse-sshminion")
  sles_registration_code = lookup(local.sles_registration_code, "suse_sshminion", null)

  use_os_released_updates = false
  ssh_key_path            = "./salt/controller/id_rsa.pub"
  gpg_keys                = ["default/gpg_keys/galaxy.key"]
  install_salt_bundle     = lookup(local.install_salt_bundle, "suse_sshminion", true)

  additional_repos  = lookup(local.additional_repos, "suse_sshminion", {})
  additional_repos_only  = lookup(local.additional_repos_only, "suse_sshminion", false)
  additional_packages = lookup(local.additional_packages, "suse_sshminion", [])
  provider_settings = lookup(local.provider_settings_by_host, "suse_sshminion", {})
}

module "slemicro_minion" {
  source = "../minion"

  quantity = contains(local.hosts, "slemicro_minion") ? 1 : 0
  base_configuration = module.base.configuration
  image              = lookup(local.images, "slemicro_minion", "slemicro55o")
  name               = lookup(local.names, "slemicro_minion", "slemicro-minion")

  server_configuration = local.minimal_configuration
  sles_registration_code = lookup(local.sles_registration_code, "slemicro_minion", null)

  use_os_released_updates = false
  ssh_key_path            = "./salt/controller/id_rsa.pub"
  install_salt_bundle     = lookup(local.install_salt_bundle, "slemicro_minion", true)

  additional_repos  = lookup(local.additional_repos, "slemicro_minion", {})
  additional_repos_only  = lookup(local.additional_repos_only, "slemicro_minion", false)
  additional_packages = lookup(local.additional_packages, "slemicro_minion", ["avahi", "avahi-lang", "libavahi-common3", "libavahi-core7"])
  additional_grains = lookup(local.additional_grains, "slemicro_minion", {})
  provider_settings = lookup(local.provider_settings_by_host, "slemicro_minion", {})
}

module "rhlike_minion" {
  source = "../minion"

  quantity = contains(local.hosts, "rhlike_minion") ? 1 : 0

  base_configuration = module.base.configuration
  image              = lookup(local.images, "rhlike_minion", "rocky8o")
  name               = lookup(local.names, "rhlike_minion", "rhlike-minion")

  server_configuration   = local.minimal_configuration

  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "./salt/controller/id_rsa.pub"
  install_salt_bundle     = lookup(local.install_salt_bundle, "rhlike_minion", true)

  additional_repos  = lookup(local.additional_repos, "rhlike_minion", {})
  additional_repos_only  = lookup(local.additional_repos_only, "rhlike_minion", false)
  additional_packages = lookup(local.additional_packages, "rhlike_minion", [])
  additional_grains = lookup(local.additional_grains, "rhlike_minion", {})
  provider_settings = lookup(local.provider_settings_by_host, "rhlike_minion", {})
}

module "deblike_minion" {
  source = "../minion"

  quantity = contains(local.hosts, "deblike_minion") ? 1 : 0

  base_configuration = module.base.configuration
  image              = lookup(local.images, "deblike_minion", "ubuntu2204o")
  name               = lookup(local.names, "deblike_minion", "deblike-minion")

  server_configuration   = local.minimal_configuration

  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "./salt/controller/id_rsa.pub"
  install_salt_bundle     = lookup(local.install_salt_bundle, "deblike_minion", true)

  additional_repos      = lookup(local.additional_repos, "deblike_minion", {})
  additional_repos_only = lookup(local.additional_repos_only, "deblike_minion", false)
  additional_packages   = lookup(local.additional_packages, "deblike_minion", [])
  additional_grains     = lookup(local.additional_grains, "deblike_minion", {})
  provider_settings     = lookup(local.provider_settings_by_host, "deblike_minion", {})
}

module "build_host" {
  source = "../build_host"

  quantity           = contains(local.hosts, "build_host") ? 1 : 0
  base_configuration = module.base.configuration
  image              = lookup(local.images, "build_host", "sles15sp4o")
  name               = lookup(local.names, "build_host", "build-host")

  server_configuration = local.minimal_configuration

  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "./salt/controller/id_rsa.pub"
  avahi_reflector         = var.avahi_reflector
  install_salt_bundle     = lookup(local.install_salt_bundle, "build_host", true)

  additional_repos  = lookup(local.additional_repos, "build_host", {})
  additional_repos_only  = lookup(local.additional_repos_only, "build_host", false)
  additional_packages = lookup(local.additional_packages, "build_host", [])
  provider_settings = lookup(local.provider_settings_by_host, "build_host", {})
}

module "pxeboot_minion" {
  source = "../pxe_boot"

  quantity = contains(local.hosts, "pxeboot_minion") ? 1 : 0
  base_configuration = module.base.configuration
  image              = lookup(local.images, "pxeboot_minion", "sles15sp4o")
  name               = lookup(local.names, "pxeboot_minion", "pxeboot-minion")

  private_ip         = lookup(local.private_ip, "pxeboot_minion", 4)
  private_name       = lookup(local.private_name, "pxeboot_minion", "pxeboot")

  provider_settings  = lookup(local.provider_settings_by_host, "pxeboot_minion", {})
}

module "kvm_host" {
  source = "../virthost"

  quantity = contains(local.hosts, "kvm_host") ? 1 : 0

  base_configuration = module.base.configuration
  image              = lookup(local.images, "kvm_host", "sles15sp4o")
  name               = lookup(local.names, "kvm_host", "kvm-host")

  server_configuration = local.minimal_configuration
  sles_registration_code = lookup(local.sles_registration_code, "kvm_host", null)

  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "./salt/controller/id_rsa.pub"
  install_salt_bundle     = lookup(local.install_salt_bundle, "kvm_host", true)

  additional_repos  = lookup(local.additional_repos, "kvm_host", {})
  additional_repos_only  = lookup(local.additional_repos_only, "kvm_host", false)
  additional_packages = lookup(local.additional_packages, "kvm_host", [])
  additional_grains = lookup(local.additional_grains, "kvm_host", {})
  provider_settings = lookup(local.provider_settings_by_host, "kvm_host", {})
}

module "monitoring_server" {
  source = "../minion"

  quantity = contains(local.hosts, "monitoring_server") ? 1 : 0

  base_configuration = module.base.configuration
  image              = lookup(local.images, "monitoring_server", "sles15sp4o")
  name               = lookup(local.names, "monitoring_server", "monitoring")

  server_configuration = local.minimal_configuration
  sles_registration_code = lookup(local.sles_registration_code, "monitoring_server", null)

  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "./salt/controller/id_rsa.pub"
  install_salt_bundle     = lookup(local.install_salt_bundle, "monitoring_server", true)

  additional_repos  = lookup(local.additional_repos, "monitoring_server", {})
  additional_repos_only  = lookup(local.additional_repos_only, "monitoring_server", false)
  additional_packages = lookup(local.additional_packages, "monitoring_server", [])
  additional_grains = lookup(local.additional_grains, "monitoring_server", {})
  provider_settings = lookup(local.provider_settings_by_host, "monitoring_server", {})
}

module "controller" {
  source = "../controller"
  name   = lookup(local.names, "controller", "controller")

  base_configuration             = module.base.configuration
  server_configuration           = local.server_configuration
  proxy_configuration            = local.proxy_configuration
  client_configuration           = contains(local.hosts, "suse_client") ? module.suse_client.configuration : { hostnames = [], ids = [], ipaddrs = [], macaddrs = [], private_macs = [] }
  minion_configuration           = contains(local.hosts, "suse_minion") ? module.suse_minion.configuration : { hostnames = [], ids = [], ipaddrs = [], macaddrs = [], private_macs = [] }
  sshminion_configuration        = contains(local.hosts, "suse_sshminion") ? module.suse_sshminion.configuration : { hostnames = [], ids = [], ipaddrs = [], macaddrs = [], private_macs = [] }
  # TODO: rename redhat_configuration and debian_configuration to rhlike_configuration and deblike_configuration once the renaming is done: https://github.com/SUSE/spacewalk/issues/25062
  redhat_configuration           = contains(local.hosts, "rhlike_minion") ? module.rhlike_minion.configuration : { hostnames = [], ids = [], ipaddrs = [], macaddrs = [], private_macs = [] }
  debian_configuration           = contains(local.hosts, "deblike_minion") ? module.deblike_minion.configuration : { hostnames = [], ids = [], ipaddrs = [], macaddrs = [], private_macs = [] }
  buildhost_configuration        = contains(local.hosts, "build_host") ? module.build_host.configuration : { hostnames = [], ids = [], ipaddrs = [], macaddrs = [], private_macs = [] }
  pxeboot_configuration          = contains(local.hosts, "pxeboot_minion") ? module.pxeboot_minion.configuration : { private_mac = null, private_ip = null, private_name = null, image = null }
  kvmhost_configuration          = contains(local.hosts, "kvm_host") ? module.kvm_host.configuration : { hostnames = [], ids = [], ipaddrs = [], macaddrs = [], private_macs = [] }
  monitoringserver_configuration = contains(local.hosts, "monitoring_server") ? module.monitoring_server.configuration : { hostnames = [], ids = [], ipaddrs = [], macaddrs = [], private_macs = [] }

  branch                   = var.branch
  git_username             = var.git_username
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
  beta_enabled             = var.beta_enabled

  additional_repos  = lookup(local.additional_repos, "controller", {})
  additional_repos_only  = lookup(local.additional_repos_only, "controller", false)
  additional_packages = lookup(local.additional_packages, "controller", [])
  provider_settings = lookup(local.provider_settings_by_host, "controller", {})
}

output "configuration" {
  value = {
    base = module.base.configuration
    server = var.container_server ? module.server_containerized[0].configuration : module.server[0].configuration
    proxy = var.container_proxy ? module.proxy_containerized[0].configuration : module.proxy[0].configuration
    suse_client = module.suse_client.configuration
    suse_minion = module.suse_minion.configuration
    suse_sshminion = module.suse_sshminion.configuration
    rhlike_minion = module.rhlike_minion.configuration
    deblike_minion = module.deblike_minion.configuration
    build_host = module.build_host.configuration
    pxeboot_minion = module.pxeboot_minion.configuration
    kvm_host = module.kvm_host.configuration
    monitoring_server = module.monitoring_server.configuration
    controller = module.controller.configuration
  }
}
