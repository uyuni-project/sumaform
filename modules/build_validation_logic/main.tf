terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3"
      # Define abstract slots for hardware connections.
      # These are filled by the top-level files (BV-NUE.tf / BV-SLC.tf).
      configuration_aliases = [
        libvirt.host_old_sle, # For SLES 12 (Tatooine/Default)
        libvirt.host_new_sle, # For SLES 15/Micro (Florina/Default)
        libvirt.host_res,     # For Alma/Rocky/CentOS/Oracle (Tatooine/Default)
        libvirt.host_debian,  # For Ubuntu/Debian (Trantor/Default)
        libvirt.host_retail,  # For Proxy/BuildHosts/Terminals (Terminus/Default)
        libvirt.host_arm      # For ARM Minions (Suma-ARM/Shared)
      ]
    }
  }
}

locals {
  # Base Configuration Mapping
  # If a specific base is not passed in the map, fallback to 'default'.
  base_default = var.base_configurations["default"]
  base_old_sle = lookup(var.base_configurations, "old_sle", local.base_default)
  base_new_sle = lookup(var.base_configurations, "new_sle", local.base_default)
  base_res     = lookup(var.base_configurations, "res",     local.base_default)
  base_debian  = lookup(var.base_configurations, "debian",  local.base_default)
  base_retail  = lookup(var.base_configurations, "retail",  local.base_default)
  base_arm     = lookup(var.base_configurations, "arm",     null) # Null if not provided

  server_configuration = length(module.server_containerized) > 0 ? module.server_containerized[0].configuration : module.server[0].configuration
  proxy_configuration  = length(module.proxy_containerized) > 0 ? module.proxy_containerized[0].configuration : module.proxy[0].configuration
  product_version      = var.PRODUCT_VERSION != null ? var.PRODUCT_VERSION : var.ENVIRONMENT_CONFIGURATION.product_version

  # Empty configs for safe ternary fallbacks
  empty_minion_config   = { ids = [], hostnames = [], macaddrs = [], private_macs = [], ipaddrs = [] }
  empty_terminal_config = { private_mac = null, private_ip = null, private_name = null, image = null }
}

module "server" {
  source             = "../server"
  count               = lookup(var.ENVIRONMENT_CONFIGURATION, "server", null) != null ? 1 : 0
  base_configuration = local.base_default
  name               = "server"
  image              = "sles15sp4o"
  beta_enabled       = false
  provider_settings = {
    mac       = var.ENVIRONMENT_CONFIGURATION.server.mac
    memory    = 40960
    vcpu      = 10
    data_pool = "ssd"
  }
  main_disk_size       = 100
  repository_disk_size = 3072
  database_disk_size   = 150

  server_mounted_mirror          = var.PLATFORM_LOCATION_CONFIGURATION[var.LOCATION].mirror
  java_debugging                 = false
  auto_accept                    = false
  monitored                      = true
  disable_firewall               = false
  allow_postgres_connections     = false
  skip_changelog_import          = false
  create_first_user              = false
  mgr_sync_autologin             = false
  create_sample_channel          = false
  create_sample_activation_key   = false
  create_sample_bootstrap_script = false
  publish_private_ssl_key        = false
  use_os_released_updates        = true
  disable_download_tokens        = false
  disable_auto_bootstrap         = true
  large_deployment               = true
  ssh_key_path                   = "./salt/controller/id_ed25519.pub"
  from_email                     = "root@suse.de"
  accept_all_ssl_protocols       = true

  //server_additional_repos
}

module "server_containerized" {
  source             = "../server_containerized"
  count               = lookup(var.ENVIRONMENT_CONFIGURATION, "server_containerized", null) != null ? 1 : 0
  base_configuration = local.base_default
  name               = var.ENVIRONMENT_CONFIGURATION.server_containerized.name
  image              = var.BASE_OS != null ? var.BASE_OS : var.ENVIRONMENT_CONFIGURATION.server.image
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.server_containerized.mac
    memory = 40960
    vcpu   = 10
  }
  runtime              = "podman"
  container_repository = var.SERVER_CONTAINER_REPOSITORY
  container_image      = var.SERVER_CONTAINER_IMAGE
  main_disk_size       = 100

  repository_disk_size           = 3072
  database_disk_size             = 150
  container_tag                  = "latest"
  beta_enabled                   = false
  server_mounted_mirror          = var.PLATFORM_LOCATION_CONFIGURATION[var.LOCATION].mirror
  java_debugging                 = false
  auto_accept                    = false
  disable_firewall               = false
  allow_postgres_connections     = false
  skip_changelog_import          = false
  mgr_sync_autologin             = false
  create_sample_channel          = false
  create_sample_activation_key   = false
  create_sample_bootstrap_script = false
  publish_private_ssl_key        = false
  use_os_released_updates        = true
  disable_download_tokens        = false
  large_deployment               = true
  ssh_key_path                   = "./salt/controller/id_ed25519.pub"
  from_email                     = "root@suse.de"
  provision                      = true

  //server_additional_repos
}

module "proxy" {
  providers = { libvirt = libvirt.host_retail }
  source             = "../proxy"
  count               = lookup(var.ENVIRONMENT_CONFIGURATION, "proxy", null) != null ? 1 : 0
  base_configuration = local.base_retail
  server_configuration = module.server[0].configuration
  name                 = "proxy"
  image                = "sles15sp4o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.proxy.mac
    memory = 4096
  }
  auto_register             = false
  auto_connect_to_master    = false
  download_private_ssl_key  = false
  install_proxy_pattern     = false
  auto_configure            = false
  generate_bootstrap_script = false
  publish_private_ssl_key   = false
  use_os_released_updates   = true
  ssh_key_path              = "./salt/controller/id_ed25519.pub"

  //proxy_additional_repos
}

module "proxy_containerized" {
  providers = { libvirt = libvirt.host_retail }
  source             = "../proxy_containerized"
  count               = lookup(var.ENVIRONMENT_CONFIGURATION, "proxy_containerized", null) != null ? 1 : 0
  base_configuration = local.base_retail
  name               = var.ENVIRONMENT_CONFIGURATION.proxy_containerized.name
  image              = var.BASE_OS != null ? var.BASE_OS : var.ENVIRONMENT_CONFIGURATION.proxy_containerized.image
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.proxy_containerized.mac
    memory = 4096
  }
  runtime              = "podman"
  container_repository = var.PROXY_CONTAINER_REPOSITORY
  container_tag        = "latest"
  auto_configure       = false
  ssh_key_path         = "./salt/controller/id_ed25519.pub"
  provision            = true

  //proxy_additional_repos
}

# -------------------------------------------------------------------
# 3. OLD SLE MINIONS (SLES 12)
# -------------------------------------------------------------------
module "sles12sp5_minion" {
  providers = { libvirt = libvirt.host_old_sle }
  source             = "../minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles12sp5_minion", null) != null ? 1 : 0
  base_configuration = local.base_old_sle
  name               = var.ENVIRONMENT_CONFIGURATION.sles12sp5_minion.name
  image              = "sles12sp5o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.sles12sp5_minion.mac
    memory = 4096
  }
  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "./salt/controller/id_ed25519.pub"
}

# -------------------------------------------------------------------
# 4. NEW SLE MINIONS (SLES 15, SLE Micro)
# -------------------------------------------------------------------
module "sles15sp3_minion" {
  providers = { libvirt = libvirt.host_new_sle }
  source             = "../minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles15sp3_minion", null) != null ? 1 : 0
  base_configuration = local.base_new_sle
  name               = var.ENVIRONMENT_CONFIGURATION.sles15sp3_minion.name
  image              = "sles15sp3o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.sles15sp3_minion.mac
    memory = 4096
  }
  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "./salt/controller/id_ed25519.pub"
}

module "sles15sp4_minion" {
  providers = { libvirt = libvirt.host_new_sle }
  source             = "../minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles15sp4_minion", null) != null ? 1 : 0
  base_configuration = local.base_new_sle
  name               = var.ENVIRONMENT_CONFIGURATION.sles15sp4_minion.name
  image              = "sles15sp4o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.sles15sp4_minion.mac
    memory = 4096
  }
  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "./salt/controller/id_ed25519.pub"
}

module "sles15sp5_minion" {
  providers = { libvirt = libvirt.host_new_sle }
  source             = "../minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles15sp5_minion", null) != null ? 1 : 0
  base_configuration = local.base_new_sle
  name               = var.ENVIRONMENT_CONFIGURATION.sles15sp5_minion.name
  image              = "sles15sp5o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.sles15sp5_minion.mac
    memory = 4096
  }
  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "./salt/controller/id_ed25519.pub"
}

module "sles15sp6_minion" {
  providers = { libvirt = libvirt.host_new_sle }
  source             = "../minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles15sp6_minion", null) != null ? 1 : 0
  base_configuration = local.base_new_sle
  name               = var.ENVIRONMENT_CONFIGURATION.sles15sp6_minion.name
  image              = "sles15sp6o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.sles15sp6_minion.mac
    memory = 4096
  }
  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "./salt/controller/id_ed25519.pub"
}

module "sles15sp7_minion" {
  providers = { libvirt = libvirt.host_new_sle }
  source             = "../minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles15sp7_minion", null) != null ? 1 : 0
  base_configuration = local.base_new_sle
  name               = var.ENVIRONMENT_CONFIGURATION.sles15sp7_minion.name
  image              = "sles15sp7o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.sles15sp7_minion.mac
    memory = 4096
  }
  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "./salt/controller/id_ed25519.pub"
}

# --- SLE Micro Minions (New SLE Host) ---
module "slemicro55_minion" {
  providers = { libvirt = libvirt.host_new_sle }
  source             = "../minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "slemicro55_minion", null) != null ? 1 : 0
  base_configuration = local.base_new_sle
  name               = var.ENVIRONMENT_CONFIGURATION.slemicro55_minion.name
  image              = "slemicro55o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.slemicro55_minion.mac
    memory = 2048
  }
  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "./salt/controller/id_ed25519.pub"
  install_salt_bundle     = false
}

module "slmicro60_minion" {
  providers = { libvirt = libvirt.host_new_sle }
  source             = "../minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "slmicro60_minion", null) != null ? 1 : 0
  base_configuration = local.base_new_sle
  name               = var.ENVIRONMENT_CONFIGURATION.slmicro60_minion.name
  image              = "slmicro60o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.slmicro60_minion.mac
    memory = 2048
  }
  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "./salt/controller/id_ed25519.pub"
}

# -------------------------------------------------------------------
# 5. RES / EL MINIONS (Rocky, Alma, CentOS, Oracle)
# -------------------------------------------------------------------
module "alma9_minion" {
  providers = { libvirt = libvirt.host_res }
  source             = "../minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "alma9_minion", null) != null ? 1 : 0
  base_configuration = local.base_res
  name               = var.ENVIRONMENT_CONFIGURATION.alma9_minion.name
  image              = "almalinux9o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.alma9_minion.mac
    memory = 4096
  }
  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "./salt/controller/id_ed25519.pub"
}

module "rocky9_minion" {
  providers = { libvirt = libvirt.host_res }
  source             = "../minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "rocky9_minion", null) != null ? 1 : 0
  base_configuration = local.base_res
  name               = var.ENVIRONMENT_CONFIGURATION.rocky9_minion.name
  image              = "rocky9o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.rocky9_minion.mac
    memory = 4096
  }
  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "./salt/controller/id_ed25519.pub"
}

module "centos7_minion" {
  providers = { libvirt = libvirt.host_res }
  source             = "../minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "centos7_minion", null) != null ? 1 : 0
  base_configuration = local.base_res
  name               = var.ENVIRONMENT_CONFIGURATION.centos7_minion.name
  image              = "centos7o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.centos7_minion.mac
    memory = 4096
  }
  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "./salt/controller/id_ed25519.pub"
}

module "oracle9_minion" {
  providers = { libvirt = libvirt.host_res }
  source             = "../minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "oracle9_minion", null) != null ? 1 : 0
  base_configuration = local.base_res
  name               = var.ENVIRONMENT_CONFIGURATION.oracle9_minion.name
  image              = "oraclelinux9o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.oracle9_minion.mac
    memory = 4096
  }
  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "./salt/controller/id_ed25519.pub"
}

# -------------------------------------------------------------------
# 6. DEBIAN / UBUNTU MINIONS
# -------------------------------------------------------------------
module "ubuntu2204_minion" {
  providers = { libvirt = libvirt.host_debian }
  source             = "../minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "ubuntu2204_minion", null) != null ? 1 : 0
  base_configuration = local.base_debian
  name               = var.ENVIRONMENT_CONFIGURATION.ubuntu2204_minion.name
  image              = "ubuntu2204o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.ubuntu2204_minion.mac
    memory = 4096
  }
  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "./salt/controller/id_ed25519.pub"
}

module "debian12_minion" {
  providers = { libvirt = libvirt.host_debian }
  source             = "../minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "debian12_minion", null) != null ? 1 : 0
  base_configuration = local.base_debian
  name               = var.ENVIRONMENT_CONFIGURATION.debian12_minion.name
  image              = "debian12o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.debian12_minion.mac
    memory = 4096
  }
  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "./salt/controller/id_ed25519.pub"
}

# -------------------------------------------------------------------
# 7. ARM MINIONS (Shared Host)
# -------------------------------------------------------------------
module "opensuse156arm_minion" {
  providers = { libvirt = libvirt.host_arm }
  source             = "../minion"
  count              = (lookup(var.ENVIRONMENT_CONFIGURATION, "opensuse156arm_minion", null) != null && local.base_arm != null) ? 1 : 0
  base_configuration = local.base_arm
  # ARM naming requires location extension typically
  name               = "${var.ENVIRONMENT_CONFIGURATION.opensuse156arm_minion.name}${var.PLATFORM_LOCATION_CONFIGURATION.extension}"
  image              = "opensuse156armo"
  provider_settings = {
    mac            = var.ENVIRONMENT_CONFIGURATION.opensuse156arm_minion.mac
    overwrite_fqdn = "${var.ENVIRONMENT_CONFIGURATION.name_prefix}${var.ENVIRONMENT_CONFIGURATION.opensuse156arm_minion.name}.${var.PLATFORM_LOCATION_CONFIGURATION.domain}"
    memory         = 2048
    vcpu           = 2
    xslt           = file("../../susemanager-ci/terracumber_config/tf_files/common/tune-aarch64.xslt")
  }
  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "./salt/controller/id_ed25519.pub"
}

# -------------------------------------------------------------------
# 8. RETAIL / INFRASTRUCTURE (Buildhosts, Terminals, Monitoring)
# -------------------------------------------------------------------
module "sles15sp6_buildhost" {
  providers = { libvirt = libvirt.host_retail }
  source             = "../build_host"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles15sp6_buildhost", null) != null ? 1 : 0
  base_configuration = local.base_retail
  name               = var.ENVIRONMENT_CONFIGURATION.sles15sp6_buildhost.name
  image              = "sles15sp6o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.sles15sp6_buildhost.mac
    memory = 2048
    vcpu   = 2
  }
  use_os_released_updates = false
  ssh_key_path            = "./salt/controller/id_ed25519.pub"
}

module "sles15sp6_terminal" {
  providers = { libvirt = libvirt.host_retail }
  source             = "../pxe_boot"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles15sp6_buildhost", null) != null ? 1 : 0
  base_configuration = local.base_retail
  name               = "sles15sp6-terminal"
  image              = "sles15sp6o"
  provider_settings = {
    memory       = 2048
    vcpu         = 2
    manufacturer = "HP"
    product      = "ProLiant DL360 Gen9"
  }
  private_ip   = 6
  private_name = "sle15sp6terminal"
}

# -------------------------------------------------------------------
# 9. SSH MINIONS (Example of mapping to correct base)
# -------------------------------------------------------------------
module "sles15sp4_sshminion" {
  providers = { libvirt = libvirt.host_new_sle }
  source             = "../sshminion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles15sp4_sshminion", null) != null ? 1 : 0
  base_configuration = local.base_new_sle
  name               = var.ENVIRONMENT_CONFIGURATION.sles15sp4_sshminion.name
  image              = "sles15sp4o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.sles15sp4_sshminion.mac
    memory = 4096
  }
  use_os_released_updates = false
  ssh_key_path            = "./salt/controller/id_ed25519.pub"
}

# (Add other SSH minions similarly mapped to their respective hosts)

# -------------------------------------------------------------------
# 10. CONTROLLER
# -------------------------------------------------------------------
module "controller" {
  source             = "../controller"
  # Controller usually resides on the Default/Core host
  base_configuration = local.base_default
  name               = var.ENVIRONMENT_CONFIGURATION.controller.name
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.controller.mac
    memory = 16384
    vcpu   = 8
  }
  swap_file_size = null

  cc_ptf_username = var.SCC_PTF_USER
  cc_ptf_password = var.SCC_PTF_PASSWORD

  git_username      = var.GIT_USER
  git_password      = var.GIT_PASSWORD
  git_repo          = var.CUCUMBER_GITREPO
  branch            = var.CUCUMBER_BRANCH
  git_profiles_repo = "https://github.com/uyuni-project/uyuni.git#:testsuite/features/profiles/temporary"

  server_configuration = local.server_config
  proxy_configuration  = local.proxy_config

  # --- CONFIGURATION AGGREGATION ---
  # Pass configured minion objects to the controller.
  # Use ternary check to pass empty config if minion module wasn't created (count=0)

  sle12sp5_minion_configuration = length(module.sles12sp5_minion) > 0 ? module.sles12sp5_minion[0].configuration : local.empty_minion_config

  sle15sp3_minion_configuration = length(module.sles15sp3_minion) > 0 ? module.sles15sp3_minion[0].configuration : local.empty_minion_config
  sle15sp4_minion_configuration = length(module.sles15sp4_minion) > 0 ? module.sles15sp4_minion[0].configuration : local.empty_minion_config
  sle15sp5_minion_configuration = length(module.sles15sp5_minion) > 0 ? module.sles15sp5_minion[0].configuration : local.empty_minion_config
  sle15sp6_minion_configuration = length(module.sles15sp6_minion) > 0 ? module.sles15sp6_minion[0].configuration : local.empty_minion_config
  sle15sp7_minion_configuration = length(module.sles15sp7_minion) > 0 ? module.sles15sp7_minion[0].configuration : local.empty_minion_config

  slemicro55_minion_configuration = length(module.slemicro55_minion) > 0 ? module.slemicro55_minion[0].configuration : local.empty_minion_config
  slmicro60_minion_configuration  = length(module.slmicro60_minion) > 0 ? module.slmicro60_minion[0].configuration : local.empty_minion_config

  alma9_minion_configuration   = length(module.alma9_minion) > 0   ? module.alma9_minion[0].configuration   : local.empty_minion_config
  rocky9_minion_configuration  = length(module.rocky9_minion) > 0  ? module.rocky9_minion[0].configuration  : local.empty_minion_config
  centos7_minion_configuration = length(module.centos7_minion) > 0 ? module.centos7_minion[0].configuration : local.empty_minion_config
  oracle9_minion_configuration = length(module.oracle9_minion) > 0 ? module.oracle9_minion[0].configuration : local.empty_minion_config

  ubuntu2204_minion_configuration = length(module.ubuntu2204_minion) > 0 ? module.ubuntu2204_minion[0].configuration : local.empty_minion_config
  debian12_minion_configuration   = length(module.debian12_minion) > 0   ? module.debian12_minion[0].configuration   : local.empty_minion_config

  opensuse156arm_minion_configuration = length(module.opensuse156arm_minion) > 0 ? module.opensuse156arm_minion[0].configuration : local.empty_minion_config

  sle15sp6_buildhost_configuration = length(module.sles15sp6_buildhost) > 0 ? module.sles15sp6_buildhost[0].configuration : local.empty_minion_config
  sle15sp6_terminal_configuration  = length(module.sles15sp6_terminal) > 0 ? module.sles15sp6_terminal[0].configuration : local.empty_terminal_config

  # SSH Minions
  sle15sp4_sshminion_configuration = length(module.sles15sp4_sshminion) > 0 ? module.sles15sp4_sshminion[0].configuration : local.empty_minion_config
}

output "controller_configuration" {
  value = module.controller.configuration
}

output "server_configuration" {
  value = local.server_config
}