terraform {
  required_version = ">= 1.6.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3"
      configuration_aliases = [
        libvirt.host_old_sle, # For SLES 12
        libvirt.host_new_sle, # For SLES 15/Micro
        libvirt.host_res,     # For Alma/Rocky/CentOS/Oracle
        libvirt.host_debian,  # For Ubuntu/Debian
        libvirt.host_retail   # For Proxy/BuildHosts/Terminals
      ]
    }
    feilong = {
      source  = "bischoff/feilong"
      version = "0.0.6"
    }
  }
}

locals {
  base_core = var.base_configurations["default"]
  base_old_sle = lookup(var.base_configurations, "old_sle", local.base_core)
  base_new_sle = lookup(var.base_configurations, "new_sle", local.base_core)
  base_res     = lookup(var.base_configurations, "res",     local.base_core)
  base_debian  = lookup(var.base_configurations, "debian",  local.base_core)
  base_retail  = lookup(var.base_configurations, "retail",  local.base_core)

  server_configuration = length(module.server_containerized) > 0 ? module.server_containerized[0].configuration : module.server[0].configuration
  proxy_configuration  = length(module.proxy_containerized) > 0 ? module.proxy_containerized[0].configuration : module.proxy[0].configuration
  product_version      = var.PRODUCT_VERSION != null ? var.PRODUCT_VERSION : var.ENVIRONMENT_CONFIGURATION.product_version
  empty_minion_config = {
    ids          = []
    hostnames    = []
    macaddrs     = []
    private_macs = []
    ipaddrs      = []
  }
  empty_terminal_config = {
    private_mac  = null
    private_ip   = null
    private_name = null
    image        = null
  }
}

provider "libvirt" {
  alias = "suma-arm"
  uri   = "qemu+tcp://suma-arm.mgr.suse.de/system"
}

provider "feilong" {
  connector   = "https://feilong.mgr.suse.de"
  admin_token = var.ZVM_ADMIN_TOKEN
  local_user  = "jenkins@jenkins-worker.mgr.suse.de"
}

module "base_arm" {
  providers = {
    libvirt = libvirt.suma-arm
  }

  source = "../modules/base"

  cc_username     = var.SCC_USER
  cc_password     = var.SCC_PASSWORD
  product_version = local.product_version
  name_prefix     = var.ENVIRONMENT_CONFIGURATION.name_prefix
  use_avahi       = false
  domain          = var.PLATFORM_LOCATION_CONFIGURATION[var.LOCATION].domain
  images          = ["opensuse156armo"]

  mirror            = var.PLATFORM_LOCATION_CONFIGURATION[var.LOCATION].mirror
  use_mirror_images = true

  testsuite = true

  provider_settings = {
    pool   = "ssd"
    bridge = "br1"
  }
}

module "base_s390" {
  source = "../../backend_modules/feilong/base"

  name_prefix     = var.ENVIRONMENT_CONFIGURATION.name_prefix
  domain          = var.PLATFORM_LOCATION_CONFIGURATION[var.LOCATION].domain
  product_version = local.product_version

  testsuite = true
}

module "server" {
  count               = lookup(var.ENVIRONMENT_CONFIGURATION, "server", null) != null ? 1 : 0

  source             = "../modules/server"
  base_configuration = local.base_core.configuration
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
  ssh_key_path                   = "../../salt/controller/id_ed25519.pub"
  from_email                     = "root@suse.de"
  accept_all_ssl_protocols       = true

  //server_additional_repos

}

module "server_containerized" {
  source             = "../modules/server_containerized"
  count               = lookup(var.ENVIRONMENT_CONFIGURATION, "server_containerized", null) != null ? 1 : 0
  base_configuration = local.base_core.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.server_containerized.name
  image              = var.BASE_OS != null ? var.BASE_OS : var.ENVIRONMENT_CONFIGURATION.server_containerized.image
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
  ssh_key_path                   = "../../salt/controller/id_ed25519.pub"
  from_email                     = "root@suse.de"
  provision                      = true

  //server_additional_repos

}

module "proxy" {
  providers = { libvirt = libvirt.host_retail }
  source               = "../modules/proxy"
  count               = lookup(var.ENVIRONMENT_CONFIGURATION, "proxy", null) != null ? 1 : 0
  base_configuration   = local.base_retail.configuration
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
  ssh_key_path              = "../../salt/controller/id_ed25519.pub"

  //proxy_additional_repos

}

module "proxy_containerized" {
  providers = { libvirt = libvirt.host_retail }
  source             = "../modules/proxy_containerized"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "proxy_containerized", null) != null ? 1 : 0
  base_configuration = local.base_retail.configuration
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
  ssh_key_path         = "../../salt/controller/id_ed25519.pub"
  provision            = true

  //proxy_additional_repos

}

module "sles12sp5_minion" {
  providers = { libvirt = libvirt.host_old_sle }
  source             = "../modules/minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles12sp5_minion", null) != null ? 1 : 0
  base_configuration = local.base_old_sle.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.sles12sp5_minion.name
  image              = "sles12sp5o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.sles12sp5_minion.mac
    memory = 4096
  }
  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "sles15sp3_minion" {
  providers = { libvirt = libvirt.host_new_sle }
  source             = "../modules/minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles15sp3_minion", null) != null ? 1 : 0
  base_configuration = local.base_new_sle.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.sles15sp3_minion.name
  image              = "sles15sp3o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.sles15sp3_minion.mac
    memory = 4096
  }


  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "sles15sp4_minion" {
  providers = { libvirt = libvirt.host_new_sle }
  source             = "../modules/minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles15sp4_minion", null) != null ? 1 : 0
  base_configuration = local.base_new_sle.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.sles15sp4_minion.name
  image              = "sles15sp4o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.sles15sp4_minion.mac
    memory = 4096
  }

  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "sles15sp5_minion" {
  providers = { libvirt = libvirt.host_new_sle }
  source             = "../modules/minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles15sp5_minion", null) != null ? 1 : 0
  base_configuration = local.base_new_sle.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.sles15sp5_minion.name
  image              = "sles15sp5o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.sles15sp5_minion.mac
    memory = 4096
  }

  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "sles15sp6_minion" {
  providers = { libvirt = libvirt.host_new_sle }
  source             = "../modules/minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles15sp6_minion", null) != null ? 1 : 0
  base_configuration = local.base_new_sle.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.sles15sp6_minion.name
  image              = "sles15sp6o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.sles15sp6_minion.mac
    memory = 4096
  }

  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "sles15sp7_minion" {
  providers = { libvirt = libvirt.host_new_sle }
  source             = "../modules/minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles15sp7_minion", null) != null ? 1 : 0
  base_configuration = local.base_new_sle.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.sles15sp7_minion.name
  image              = "sles15sp7o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.sles15sp7_minion.mac
    memory = 4096
  }

  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "alma8_minion" {
  providers = { libvirt = libvirt.host_res }
  source             = "../modules/minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "alma8_minion", null) != null ? 1 : 0
  base_configuration = local.base_res.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.alma8_minion.name
  image              = "almalinux8o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.alma8_minion.mac
    memory = 4096
  }
  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "alma9_minion" {
  providers = { libvirt = libvirt.host_res }
  source             = "../modules/minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "alma9_minion", null) != null ? 1 : 0
  base_configuration = local.base_res.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.alma9_minion.name
  image              = "almalinux9o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.alma9_minion.mac
    memory = 4096
  }
  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "amazon2023_minion" {
  providers = { libvirt = libvirt.host_res }
  source             = "../modules/minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "amazon2023_minion", null) != null ? 1 : 0
  base_configuration = local.base_res.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.amazon2023_minion.name
  image              = "amazonlinux2023o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.amazon2023_minion.mac
    memory = 4096
  }
  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "centos7_minion" {
  providers = { libvirt = libvirt.host_res }
  source             = "../modules/minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "centos7_minion", null) != null ? 1 : 0
  base_configuration = local.base_res.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.centos7_minion.name
  image              = "centos7o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.centos7_minion.mac
    memory = 4096
  }
  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "liberty9_minion" {
  providers = { libvirt = libvirt.host_res }
  source             = "../modules/minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "liberty9_minion", null) != null ? 1 : 0
  base_configuration = local.base_res.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.liberty9_minion.name
  image              = "libertylinux9o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.liberty9_minion.mac
    memory = 4096
  }
  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

// module "openeuler2403_minion" {
//   providers = { libvirt = libvirt.host_retail }
//   source
//       = "../modules/minion"
//   count              = lookup(var.ENVIRONMENT_CONFIGURATION, "openeuler2403_minion", null) != null ? 1 : 0
//   base_configuration = local.base_core.configuration
//   name               = var.ENVIRONMENT_CONFIGURATION.openeuler2403_minion.name
//   image              = "openeuler2403o"
//   provider_settings = {
//     mac                = var.ENVIRONMENT_CONFIGURATION.openeuler2403_minion.mac
//     memory             = 4096
//   }
//   auto_connect_to_master  = false
//
//   use_os_released_updates = false
//   ssh_key_path            = "../../salt/controller/id_ed25519.pub"
// }

module "oracle9_minion" {
  providers = { libvirt = libvirt.host_res }
  source             = "../modules/minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "oracle9_minion", null) != null ? 1 : 0
  base_configuration = local.base_res.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.oracle9_minion.name
  image              = "oraclelinux9o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.oracle9_minion.mac
    memory = 4096
  }
  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "rocky8_minion" {
  providers = { libvirt = libvirt.host_res }
  source             = "../modules/minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "rocky8_minion", null) != null ? 1 : 0
  base_configuration = local.base_res.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.rocky8_minion.name
  image              = "rocky8o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.rocky8_minion.mac
    memory = 4096
  }
  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "rocky9_minion" {
  providers = { libvirt = libvirt.host_res }
  source             = "../modules/minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "rocky9_minion", null) != null ? 1 : 0
  base_configuration = local.base_res.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.rocky9_minion.name
  image              = "rocky9o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.rocky9_minion.mac
    memory = 4096
  }
  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "ubuntu2204_minion" {
  providers = { libvirt = libvirt.host_debian }
  source             = "../modules/minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "ubuntu2204_minion", null) != null ? 1 : 0
  base_configuration = local.base_debian.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.ubuntu2204_minion.name
  image              = "ubuntu2204o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.ubuntu2204_minion.mac
    memory = 4096
  }
  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "ubuntu2404_minion" {
  providers = { libvirt = libvirt.host_debian }
  source             = "../modules/minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "ubuntu2404_minion", null) != null ? 1 : 0
  base_configuration = local.base_debian.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.ubuntu2404_minion.name
  image              = "ubuntu2404o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.ubuntu2404_minion.mac
    memory = 4096
  }
  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "debian12_minion" {
  providers = { libvirt = libvirt.host_debian }
  source             = "../modules/minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "debian12_minion", null) != null ? 1 : 0
  base_configuration = local.base_debian.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.debian12_minion.name
  image              = "debian12o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.debian12_minion.mac
    memory = 4096
  }

  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "opensuse156arm_minion" {
  providers = {
    libvirt = libvirt.suma-arm
  }
  source             = "../modules/minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "opensuse156arm_minion", null) != null ? 1 : 0
  base_configuration = local.base_arm.configuration
  name               = "${var.ENVIRONMENT_CONFIGURATION.opensuse156arm_minion.name}${var.PLATFORM_LOCATION_CONFIGURATION[var.LOCATION].extension}"
  image              = "opensuse156armo"
  provider_settings = {
    mac            = var.ENVIRONMENT_CONFIGURATION.opensuse156arm_minion.mac
    overwrite_fqdn = "${var.ENVIRONMENT_CONFIGURATION.name_prefix}${var.ENVIRONMENT_CONFIGURATION.opensuse156arm_minion.name}.${var.PLATFORM_LOCATION_CONFIGURATION[var.LOCATION].domain}"
    memory         = 2048
    vcpu           = 2
    xslt           = file("../../susemanager-ci/terracumber_config/tf_files/common/tune-aarch64.xslt")
  }
  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "sles15sp5s390_minion" {
  source             = "../../backend_modules/feilong/host"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles15sp5s390_minion", null) != null ? 1 : 0
  base_configuration = local.base_s390.configuration

  name  = var.ENVIRONMENT_CONFIGURATION.sles15sp5s390_minion.name
  image = "s15s5-minimal-2part-xfs"

  provider_settings = {
    userid   = var.ENVIRONMENT_CONFIGURATION.sles15sp5s390_minion.userid
    mac      = var.ENVIRONMENT_CONFIGURATION.sles15sp5s390_minion.mac
    ssh_user = "sles"
    vswitch  = "VSUMA"
  }

  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

// This is an x86_64 SLES 15 SP5 minion (like sles15sp5-minion),
// dedicated to testing migration from OS Salt to Salt bundle
module "salt_migration_minion" {
  source             = "../modules/minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "salt_migration_minion", null) != null ? 1 : 0
  base_configuration = local.base_core.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.salt_migration_minion.name
  image              = "sles15sp5o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.salt_migration_minion.mac
    memory = 4096
  }
  server_configuration    = local.server_configuration
  auto_connect_to_master  = true
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
  install_salt_bundle     = false
}

module "slemicro51_minion" {
  providers = { libvirt = libvirt.host_new_sle }
  source             = "../modules/minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "slemicro51_minion", null) != null ? 1 : 0
  base_configuration = local.base_new_sle.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.slemicro51_minion.name
  image              = "slemicro51-ign"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.slemicro51_minion.mac
    memory = 2048
  }

  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"

  // WORKAROUND: Does not work in sumaform, yet
  install_salt_bundle = false
}

module "slemicro52_minion" {
  providers = { libvirt = libvirt.host_new_sle }
  source             = "../modules/minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "slemicro52_minion", null) != null ? 1 : 0
  base_configuration = local.base_new_sle.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.slemicro52_minion.name
  image              = "slemicro52-ign"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.slemicro52_minion.mac
    memory = 2048
  }

  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"

  // WORKAROUND: Does not work in sumaform, yet
  install_salt_bundle = false
}

module "slemicro53_minion" {
  providers = { libvirt = libvirt.host_new_sle }
  source             = "../modules/minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "slemicro53_minion", null) != null ? 1 : 0
  base_configuration = local.base_new_sle.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.slemicro53_minion.name
  image              = "slemicro53-ign"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.slemicro53_minion.mac
    memory = 2048
  }

  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"

  // WORKAROUND: Does not work in sumaform, yet
  install_salt_bundle = false
}

module "slemicro54_minion" {
  providers = { libvirt = libvirt.host_new_sle }
  source             = "../modules/minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "slemicro54_minion", null) != null ? 1 : 0
  base_configuration = local.base_new_sle.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.slemicro54_minion.name
  image              = "slemicro54-ign"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.slemicro54_minion.mac
    memory = 2048
  }

  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"

  // WORKAROUND: Does not work in sumaform, yet
  install_salt_bundle = false
}

module "slemicro55_minion" {
  providers = { libvirt = libvirt.host_new_sle }
  source             = "../modules/minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "slemicro55_minion", null) != null ? 1 : 0
  base_configuration = local.base_new_sle.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.slemicro55_minion.name
  image              = "slemicro55o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.slemicro55_minion.mac
    memory = 2048
  }

  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"

  // WORKAROUND: Does not work in sumaform, yet

  install_salt_bundle = false
}

module "slmicro60_minion" {
  providers = { libvirt = libvirt.host_new_sle }
  source             = "../modules/minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "slmicro60_minion", null) != null ? 1 : 0
  base_configuration = local.base_new_sle.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.slmicro60_minion.name
  image              = "slmicro60o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.slmicro60_minion.mac
    memory = 2048
  }

  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "slmicro61_minion" {
  providers = { libvirt = libvirt.host_new_sle }
  source             = "../modules/minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "slmicro61_minion", null) != null ? 1 : 0
  base_configuration = local.base_new_sle.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.slmicro61_minion.name
  image              = "slmicro61o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.slmicro61_minion.mac
    memory = 2048
  }

  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "sles12sp5_sshminion" {
  providers = { libvirt = libvirt.host_old_sle }
  source             = "../modules/sshminion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles12sp5_sshminion", null) != null ? 1 : 0
  base_configuration = local.base_old_sle.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.sles12sp5_sshminion.name
  image              = "sles12sp5o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.sles12sp5_sshminion.mac
    memory = 4096
  }

  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
  gpg_keys                = ["default/gpg_keys/galaxy.key"]
}

module "sles15sp3_sshminion" {
  providers = { libvirt = libvirt.host_new_sle }
  source             = "../modules/sshminion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles15sp3_sshminion", null) != null ? 1 : 0
  base_configuration = local.base_new_sle.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.sles15sp3_sshminion.name
  image              = "sles15sp3o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.sles15sp3_sshminion.mac
    memory = 4096
  }
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "sles15sp4_sshminion" {
  providers = { libvirt = libvirt.host_new_sle }
  source             = "../modules/sshminion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles15sp4_sshminion", null) != null ? 1 : 0
  base_configuration = local.base_new_sle.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.sles15sp4_sshminion.name
  image              = "sles15sp4o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.sles15sp4_sshminion.mac
    memory = 4096
  }
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "sles15sp5_sshminion" {
  providers = { libvirt = libvirt.host_new_sle }
  source             = "../modules/sshminion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles15sp5_sshminion", null) != null ? 1 : 0
  base_configuration = local.base_new_sle.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.sles15sp5_sshminion.name
  image              = "sles15sp5o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.sles15sp5_sshminion.mac
    memory = 4096
  }
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "sles15sp6_sshminion" {
  providers = { libvirt = libvirt.host_new_sle }
  source             = "../modules/sshminion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles15sp6_sshminion", null) != null ? 1 : 0
  base_configuration = local.base_new_sle.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.sles15sp6_sshminion.name
  image              = "sles15sp6o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.sles15sp6_sshminion.mac
    memory = 4096
  }

  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "sles15sp7_sshminion" {
  providers = { libvirt = libvirt.host_new_sle }
  source             = "../modules/sshminion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles15sp7_sshminion", null) != null ? 1 : 0
  base_configuration = local.base_new_sle.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.sles15sp7_sshminion.name
  image              = "sles15sp7o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.sles15sp7_sshminion.mac
    memory = 4096
  }
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "alma8_sshminion" {
  providers = { libvirt = libvirt.host_res }
  source             = "../modules/sshminion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "alma8_sshminion", null) != null ? 1 : 0
  base_configuration = local.base_res.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.alma8_sshminion.name
  image              = "almalinux8o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.alma8_sshminion.mac
    memory = 4096
  }
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "alma9_sshminion" {
  providers = { libvirt = libvirt.host_res }
  source             = "../modules/sshminion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "alma9_sshminion", null) != null ? 1 : 0
  base_configuration = local.base_res.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.alma9_sshminion.name
  image              = "almalinux9o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.alma9_sshminion.mac
    memory = 4096
  }
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "amazon2023_sshminion" {
  providers = { libvirt = libvirt.host_res }
  source             = "../modules/sshminion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "amazon2023_sshminion", null) != null ? 1 : 0
  base_configuration = local.base_res.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.amazon2023_sshminion.name
  image              = "amazonlinux2023o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.amazon2023_sshminion.mac
    memory = 4096
  }
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "centos7_sshminion" {
  providers = { libvirt = libvirt.host_res }
  source             = "../modules/sshminion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "centos7_sshminion", null) != null ? 1 : 0
  base_configuration = local.base_res.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.centos7_sshminion.name
  image              = "centos7o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.centos7_sshminion.mac
    memory = 4096
  }
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}


module "liberty9_sshminion" {
  providers = { libvirt = libvirt.host_res }
  source             = "../modules/sshminion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "liberty9_sshminion", null) != null ? 1 : 0
  base_configuration = local.base_res.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.liberty9_sshminion.name
  image              = "libertylinux9o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.liberty9_sshminion.mac
    memory = 4096
  }
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

// module "openeuler2403_sshminion" {
//   providers = { libvirt = libvirt.host_res }
//   source
//   = "../modules/sshminion"
//   count              = lookup(var.ENVIRONMENT_CONFIGURATION, "openeuler2403_sshminion", null) != null ? 1 : 0
//   base_configuration = local.base_res.configuration
//   name               = var.ENVIRONMENT_CONFIGURATION.openeuler2403_sshminion.name
//   image              = "openeuler2403o"
//   provider_settings = {
//     mac                = var.ENVIRONMENT_CONFIGURATION.openeuler2403_sshminion.mac
//     memory             = 4096
//   }
//   use_os_released_updates = false
//
//   ssh_key_path            = "../../salt/controller/id_ed25519.pub"
// }

module "oracle9_sshminion" {
  providers = { libvirt = libvirt.host_res }
  source             = "../modules/sshminion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "oracle9_sshminion", null) != null ? 1 : 0
  base_configuration = local.base_res.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.oracle9_sshminion.name
  image              = "oraclelinux9o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.oracle9_sshminion.mac
    memory = 4096
  }
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "rocky8_sshminion" {
  providers = { libvirt = libvirt.host_res }
  source             = "../modules/sshminion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "rocky8_sshminion", null) != null ? 1 : 0
  base_configuration = local.base_res.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.rocky8_sshminion.name
  image              = "rocky8o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.rocky8_sshminion.mac
    memory = 4096

  }
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "rocky9_sshminion" {
  providers = { libvirt = libvirt.host_res }
  source             = "../modules/sshminion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "rocky9_sshminion", null) != null ? 1 : 0
  base_configuration = local.base_res.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.rocky9_sshminion.name
  image              = "rocky9o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.rocky9_sshminion.mac
    memory = 4096
  }
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "ubuntu2204_sshminion" {
  providers = { libvirt = libvirt.host_debian }
  source             = "../modules/sshminion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "ubuntu2204_sshminion", null) != null ? 1 : 0
  base_configuration = local.base_debian.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.ubuntu2204_sshminion.name
  image              = "ubuntu2204o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.ubuntu2204_sshminion.mac
    memory = 4096
  }
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "ubuntu2404_sshminion" {
  providers = { libvirt = libvirt.host_debian }
  source             = "../modules/sshminion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "ubuntu2404_sshminion", null) != null ? 1 : 0
  base_configuration = local.base_debian.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.ubuntu2404_sshminion.name
  image              = "ubuntu2404o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.ubuntu2404_sshminion.mac
    memory = 4096
  }
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "debian12_sshminion" {
  providers = { libvirt = libvirt.host_debian }
  source             = "../modules/sshminion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "debian12_sshminion", null) != null ? 1 : 0
  base_configuration = local.base_debian.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.debian12_sshminion.name
  image              = "debian12o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.debian12_sshminion.mac
    memory = 4096
  }
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "opensuse156arm_sshminion" {
  providers = {
    libvirt = libvirt.suma-arm
  }
  source             = "../modules/sshminion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "opensuse156arm_sshminion", null) != null ? 1 : 0
  base_configuration = local.base_arm.configuration
  name               = "${var.ENVIRONMENT_CONFIGURATION.opensuse156arm_sshminion.name}${var.PLATFORM_LOCATION_CONFIGURATION[var.LOCATION].extension}"
  image              = "opensuse156armo"
  provider_settings = {
    mac            = var.ENVIRONMENT_CONFIGURATION.opensuse156arm_sshminion.mac
    overwrite_fqdn = "${var.ENVIRONMENT_CONFIGURATION.name_prefix}${var.ENVIRONMENT_CONFIGURATION.opensuse156arm_sshminion.name}.${var.PLATFORM_LOCATION_CONFIGURATION[var.LOCATION].domain}"
    memory         = 2048
    vcpu           = 2
    xslt           = file("../../susemanager-ci/terracumber_config/tf_files/common/tune-aarch64.xslt")
  }
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "sles15sp5s390_sshminion" {
  providers = { libvirt = libvirt.host_retail }
  source             = "../../backend_modules/feilong/host"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles15sp5s390_sshminion", null) != null ? 1 : 0
  base_configuration = local.base_s390.configuration

  name  = var.ENVIRONMENT_CONFIGURATION.sles15sp5s390_sshminion.name
  image = "s15s5-minimal-2part-xfs"

  provider_settings = {
    userid   = var.ENVIRONMENT_CONFIGURATION.sles15sp5s390_sshminion.userid
    mac      = var.ENVIRONMENT_CONFIGURATION.sles15sp5s390_sshminion.mac
    ssh_user = "sles"
    vswitch  = "VSUMA"
  }

  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "sles12sp5_client" {
  providers = { libvirt = libvirt.host_old_sle }
  source             = "../modules/client"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles12sp5_client", null) != null ? 1 : 0
  base_configuration = local.base_old_sle.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.sles12sp5_client.name
  image              = "sles12sp5o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.sles12sp5_client.mac
    memory = 4096
  }
  server_configuration    = local.proxy_configuration
  auto_register           = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "sles15sp3_client" {
  providers = { libvirt = libvirt.host_new_sle }
  source             = "../modules/client"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles15sp3_client", null) != null ? 1 : 0
  base_configuration = local.base_new_sle.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.sles15sp3_client.name
  image              = "sles15sp3o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.sles15sp3_client.mac
    memory = 4096
  }
  server_configuration    = local.proxy_configuration
  auto_register           = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "sles15sp4_client" {
  providers = { libvirt = libvirt.host_new_sle }
  source             = "../modules/client"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles15sp4_client", null) != null ? 1 : 0
  base_configuration = local.base_new_sle.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.sles15sp4_client.name
  image              = "sles15sp4o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.sles15sp4_client.mac
    memory = 4096
  }
  server_configuration    = local.proxy_configuration
  auto_register           = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "sles15sp5_client" {
  providers = { libvirt = libvirt.host_new_sle }
  source             = "../modules/client"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles15sp5_client", null) != null ? 1 : 0
  base_configuration = local.base_new_sle.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.sles15sp5_client.name
  image              = "sles15sp5o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.sles15sp5_client.mac
    memory = 4096
  }
  server_configuration    = local.proxy_configuration
  auto_register           = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "sles15sp6_client" {
  providers = { libvirt = libvirt.host_new_sle }
  source             = "../modules/client"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles15sp6_client", null) != null ? 1 : 0
  base_configuration = local.base_new_sle.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.sles15sp6_client.name
  image              = "sles15sp6o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.sles15sp6_client.mac
    memory = 4096
  }
  server_configuration    = local.proxy_configuration
  auto_register           = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "sles15sp7_client" {
  providers = { libvirt = libvirt.host_new_sle }
  source             = "../modules/client"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles15sp7_client", null) != null ? 1 : 0
  base_configuration = local.base_new_sle.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.sles15sp7_client.name
  image              = "sles15sp7o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.sles15sp7_client.mac
    memory = 4096
  }
  server_configuration    = local.proxy_configuration
  auto_register           = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "centos7_client" {
  providers = { libvirt = libvirt.host_res }
  source             = "../modules/client"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "centos7_client", null) != null ? 1 : 0
  base_configuration = local.base_res.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.centos7_client.name
  image              = "centos7o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.centos7_client.mac
    memory = 4096
  }
  server_configuration    = local.proxy_configuration
  auto_register           = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"

  additional_packages = [ "venv-salt-minion" ]
  install_salt_bundle = true
}

//  WORKAROUND until https://bugzilla.suse.com/show_bug.cgi?id=1208045 gets fixed
// module "slemicro51_sshminion" {
//   providers = { libvirt = libvirt.new_sle }
//   source             = "../modules/sshminion"
//   count              = lookup(var.ENVIRONMENT_CONFIGURATION, "slemicro51_sshminion", null) != null ? 1 : 0
//   base_configuration = local.base_new_sle.configuration
//   name               = var.ENVIRONMENT_CONFIGURATION.slemicro51_sshminion.name
//   image              = "slemicro51-ign"
//   provider_settings = {
//     mac                = var.ENVIRONMENT_CONFIGURATION.slemicro51_sshminion.mac
//     memory             = 2048
//   }
//   use_os_released_updates = false
//
//   ssh_key_path            = "../../salt/controller/id_ed25519.pub"
// }

//  WORKAROUND until https://bugzilla.suse.com/show_bug.cgi?id=1208045 gets fixed
// module "slemicro52_sshminion" {
//   providers = { libvirt = libvirt.new_sle }
//   source             = "../modules/sshminion"
//   count              = lookup(var.ENVIRONMENT_CONFIGURATION, "slemicro52_sshminion", null) != null ? 1 : 0
//   base_configuration = local.base_new_sle.configuration
//   name               = var.ENVIRONMENT_CONFIGURATION.slemicro52_sshminion.name
//   image              = "slemicro52-ign"
//   provider_settings = {
//     mac                = var.ENVIRONMENT_CONFIGURATION.slemicro52_sshminion.mac
//     memory             = 2048
//   }
//   use_os_released_updates = false
//
//   ssh_key_path            = "../../salt/controller/id_ed25519.pub"
// }

//  WORKAROUND until https://bugzilla.suse.com/show_bug.cgi?id=1208045 gets fixed
// module "slemicro53_sshminion" {
//   providers = { libvirt = libvirt.new_sle }
//   source             = "../modules/sshminion"
//   count              = lookup(var.ENVIRONMENT_CONFIGURATION, "slemicro53_sshminion", null) != null ? 1 : 0
//   base_configuration = local.base_new_sle.configuration
//   name               = var.ENVIRONMENT_CONFIGURATION.slemicro53_sshminion.name
//   image              = "slemicro53-ign"
//   provider_settings = {
//     mac                = var.ENVIRONMENT_CONFIGURATION.slemicro53_sshminion.mac
//     memory             = 2048
//   }
//   use_os_released_updates = false
//
//   ssh_key_path            = "../../salt/controller/id_ed25519.pub"
// }

//  WORKAROUND until https://bugzilla.suse.com/show_bug.cgi?id=1208045 gets fixed
// module "slemicro54_sshminion" {
//   providers = { libvirt = libvirt.host_new_sle }
//   source             = "../modules/sshminion"
//   count              = lookup(var.ENVIRONMENT_CONFIGURATION, "slemicro54_sshminion", null) != null ? 1 : 0
//   base_configuration = local.base_new_sle.configuration
//   name               = var.ENVIRONMENT_CONFIGURATION.slemicro54_sshminion.name
//   image              = "slemicro54-ign"
//   provider_settings = {
//     mac                = var.ENVIRONMENT_CONFIGURATION.slemicro54_sshminion.mac
//     memory             = 2048
//   }
//   use_os_released_updates = false
//
//   ssh_key_path            = "../../salt/controller/id_ed25519.pub"
//
//
//
//}

//  WORKAROUND until https://bugzilla.suse.com/show_bug.cgi?id=1208045 gets fixed
// module "slemicro55_sshminion" {
//   providers = { libvirt = libvirt.host_new_sle }
//   source             = "../modules/sshminion"
//   count              = lookup(var.ENVIRONMENT_CONFIGURATION, "slemicro55_sshminion", null) != null ? 1 : 0
//   base_configuration = local.base_new_sle.configuration
//   name               = var.ENVIRONMENT_CONFIGURATION.slemicro55_sshminion.name
//   image              = "slemicro55o"
//   provider_settings = {
//     mac                = var.ENVIRONMENT_CONFIGURATION.slemicro55_sshminion.mac
//     memory             = 2048
//   }
//   use_os_released_updates = false
//
//   ssh_key_path            = "../../salt/controller/id_ed25519.pub"
//
//
//}

//  WORKAROUND until https://bugzilla.suse.com/show_bug.cgi?id=1208045 gets fixed
// module "slmicro60_sshminion" {
//   providers = { libvirt = libvirt.host_new_sle }
//   source             = "../modules/sshminion"
//   count              = lookup(var.ENVIRONMENT_CONFIGURATION, "slmicro60_sshminion", null) != null ? 1 : 0
//   base_configuration = local.base_new_sle.configuration
//   name               = var.ENVIRONMENT_CONFIGURATION.slmicro60_sshminion.name
//   image              = "slmicro60o"
//   provider_settings = {
//     mac                = var.ENVIRONMENT_CONFIGURATION.slmicro60_sshminion.mac
//     memory             = 2048
//   }
//   use_os_released_updates = false
//
//   ssh_key_path            = "../../salt/controller/id_ed25519.pub"
//
//
//}

//  WORKAROUND until https://bugzilla.suse.com/show_bug.cgi?id=1208045 gets fixed
// module "slmicro61_sshminion" {
//   providers = { libvirt = libvirt.host_retail }
//   source             = "../modules/sshminion"
//   count              = lookup(var.ENVIRONMENT_CONFIGURATION, "slmicro61_sshminion", null) != null ? 1 : 0
//   base_configuration = local.base_new_sle.configuration
//   name               = var.ENVIRONMENT_CONFIGURATION.slmicro61_sshminion.name
//   image              = "slmicro61o"
//   provider_settings = {
//     mac                = var.ENVIRONMENT_CONFIGURATION.slmicro61_sshminion.mac
//     memory             = 2048
//   }
//   use_os_released_updates = false
//
//   ssh_key_path            = "../../salt/controller/id_ed25519.pub"
//
//
//}

module "sles15sp6_buildhost" {
  providers = { libvirt = libvirt.host_retail }
  source             = "../modules/build_host"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles15sp6_buildhost", null) != null ? 1 : 0
  base_configuration = local.base_retail.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.sles15sp6_buildhost.name
  image              = "sles15sp6o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.sles15sp6_buildhost.mac
    memory = 2048
    vcpu   = 2
  }
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"

}

module "sles15sp7_buildhost" {
  providers = { libvirt = libvirt.host_retail }
  source             = "../modules/build_host"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles15sp7_buildhost", null) != null ? 1 : 0
  base_configuration = local.base_retail.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.sles15sp7_buildhost.name
  image              = "sles15sp7o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.sles15sp7_buildhost.mac
    memory = 2048
    vcpu   = 2
  }
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"

}

module "sles15sp6_terminal" {
  providers = { libvirt = libvirt.host_retail }
  source             = "../modules/pxe_boot"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles15sp6_buildhost", null) != null ? 1 : 0
  base_configuration = local.base_retail.configuration
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

module "sles15sp7_terminal" {
  providers = { libvirt = libvirt.host_retail }
  source             = "../modules/pxe_boot"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "sles15sp7_buildhost", null) != null ? 1 : 0
  base_configuration = local.base_retail.configuration
  name               = "sles15sp7-terminal"
  image              = "sles15sp7o"
  provider_settings = {
    memory       = 2048
    vcpu         = 2
    manufacturer = "HP"
    product      = "ProLiant DL580 Gen9"
  }
  private_ip   = 7
  private_name = "sle15sp7terminal"
}

module "dhcp_dns" {
  providers = { libvirt = libvirt.host_retail }
  source             = "../modules/dhcp_dns"
  count = (
  length(module.proxy_containerized) > 0 &&
  try(var.ENVIRONMENT_CONFIGURATION.base_core["additional_network"], null) != null
  ) ? 1 : 0
  base_configuration = local.base_retail.configuration
  name               = "dhcp-dns"
  image              = "opensuse155o"
  private_hosts = concat(
    module.proxy_containerized[*].configuration,
    module.sles15sp6_terminal[*].configuration,
    module.sles15sp7_terminal[*].configuration
  )
  hypervisor = {
    host        = var.ENVIRONMENT_CONFIGURATION.base_core.hypervisor
    user        = "root"
    private_key = file("~/.ssh/id_ed25519")
  }
}

module "monitoring_server" {
  providers = { libvirt = libvirt.host_retail }

  source             = "../modules/minion"
  count              = lookup(var.ENVIRONMENT_CONFIGURATION, "monitoring_server", null) != null ? 1 : 0
  base_configuration = local.base_retail.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.monitoring_server.name
  image              = "sles15sp7o"
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.monitoring_server.mac
    memory = 2048
  }

  auto_connect_to_master  = false
  use_os_released_updates = false
  ssh_key_path            = "../../salt/controller/id_ed25519.pub"
}

module "controller" {
  source             = "../modules/controller"
  base_configuration = local.base_core.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.controller.name
  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.controller.mac
    memory = 16384
    vcpu   = 8
  }
  swap_file_size = null
  beta_enabled   = false

  cc_ptf_username = var.SCC_PTF_USER
  cc_ptf_password = var.SCC_PTF_PASSWORD

  // Cucumber repository configuration for the controller
  git_username      = var.GIT_USER
  git_password      = var.GIT_PASSWORD
  git_repo          = var.CUCUMBER_GITREPO
  branch            = var.CUCUMBER_BRANCH
  git_profiles_repo = "https://github.com/uyuni-project/uyuni.git#:testsuite/features/profiles/temporary"

  server_configuration = local.server_configuration
  proxy_configuration  = local.proxy_configuration

  sle12sp5_minion_configuration    = length(module.sles12sp5_minion) > 0 ? module.sles12sp5_minion[0].configuration : local.empty_minion_config
  sle12sp5_sshminion_configuration = length(module.sles12sp5_sshminion) > 0 ? module.sles12sp5_sshminion[0].configuration : local.empty_minion_config

  sle15sp3_minion_configuration    = length(module.sles15sp3_minion) > 0 ? module.sles15sp3_minion[0].configuration : local.empty_minion_config
  sle15sp3_sshminion_configuration = length(module.sles15sp3_sshminion) > 0 ? module.sles15sp3_sshminion[0].configuration : local.empty_minion_config

  sle15sp4_minion_configuration    = length(module.sles15sp4_minion) > 0 ? module.sles15sp4_minion[0].configuration : local.empty_minion_config
  sle15sp4_sshminion_configuration = length(module.sles15sp4_sshminion) > 0 ? module.sles15sp4_sshminion[0].configuration : local.empty_minion_config

  sle15sp5_minion_configuration    = length(module.sles15sp5_minion) > 0 ? module.sles15sp5_minion[0].configuration : local.empty_minion_config
  sle15sp5_sshminion_configuration = length(module.sles15sp5_sshminion) > 0 ? module.sles15sp5_sshminion[0].configuration : local.empty_minion_config

  sle15sp6_minion_configuration    = length(module.sles15sp6_minion) > 0 ? module.sles15sp6_minion[0].configuration : local.empty_minion_config
  sle15sp6_sshminion_configuration = length(module.sles15sp6_sshminion) > 0 ? module.sles15sp6_sshminion[0].configuration : local.empty_minion_config

  sle15sp7_minion_configuration    = length(module.sles15sp7_minion) > 0 ? module.sles15sp7_minion[0].configuration : local.empty_minion_config
  sle15sp7_sshminion_configuration = length(module.sles15sp7_sshminion) > 0 ? module.sles15sp7_sshminion[0].configuration : local.empty_minion_config

  sle12sp5_client_configuration    = length(module.sles12sp5_client) > 0 ? module.sles12sp5_client[0].configuration : local.empty_minion_config
  sle15sp3_client_configuration    = length(module.sles15sp3_client) > 0 ? module.sles15sp3_client[0].configuration : local.empty_minion_config
  sle15sp4_client_configuration    = length(module.sles15sp4_client) > 0 ? module.sles15sp4_client[0].configuration : local.empty_minion_config
  sle15sp5_client_configuration    = length(module.sles15sp5_client) > 0 ? module.sles15sp5_client[0].configuration : local.empty_minion_config
  sle15sp6_client_configuration    = length(module.sles15sp6_client) > 0 ? module.sles15sp6_client[0].configuration : local.empty_minion_config
  sle15sp7_client_configuration    = length(module.sles15sp7_client) > 0 ? module.sles15sp7_client[0].configuration : local.empty_minion_config
  centos7_client_configuration     = length(module.centos7_client) > 0 ? module.centos7_client[0].configuration : local.empty_minion_config

  alma8_minion_configuration    = length(module.alma8_minion) > 0 ? module.alma8_minion[0].configuration : local.empty_minion_config
  alma8_sshminion_configuration = length(module.alma8_sshminion) > 0 ? module.alma8_sshminion[0].configuration : local.empty_minion_config

  alma9_minion_configuration    = length(module.alma9_minion) > 0 ? module.alma9_minion[0].configuration : local.empty_minion_config
  alma9_sshminion_configuration = length(module.alma9_sshminion) > 0 ? module.alma9_sshminion[0].configuration : local.empty_minion_config

  amazon2023_minion_configuration    = length(module.amazon2023_minion) > 0 ? module.amazon2023_minion[0].configuration : local.empty_minion_config
  amazon2023_sshminion_configuration = length(module.amazon2023_sshminion) > 0 ? module.amazon2023_sshminion[0].configuration : local.empty_minion_config

  centos7_minion_configuration    = length(module.centos7_minion) > 0 ? module.centos7_minion[0].configuration : local.empty_minion_config
  centos7_sshminion_configuration = length(module.centos7_sshminion) > 0 ? module.centos7_sshminion[0].configuration : local.empty_minion_config

  liberty9_minion_configuration    = length(module.liberty9_minion) > 0 ? module.liberty9_minion[0].configuration : local.empty_minion_config
  liberty9_sshminion_configuration = length(module.liberty9_sshminion) > 0 ? module.liberty9_sshminion[0].configuration : local.empty_minion_config

  oracle9_minion_configuration    = length(module.oracle9_minion) > 0 ? module.oracle9_minion[0].configuration : local.empty_minion_config
  oracle9_sshminion_configuration = length(module.oracle9_sshminion) > 0 ? module.oracle9_sshminion[0].configuration : local.empty_minion_config

  rocky8_minion_configuration    = length(module.rocky8_minion) > 0 ? module.rocky8_minion[0].configuration : local.empty_minion_config
  rocky8_sshminion_configuration = length(module.rocky8_sshminion) > 0 ? module.rocky8_sshminion[0].configuration : local.empty_minion_config

  rocky9_minion_configuration    = length(module.rocky9_minion) > 0 ? module.rocky9_minion[0].configuration : local.empty_minion_config
  rocky9_sshminion_configuration = length(module.rocky9_sshminion) > 0 ? module.rocky9_sshminion[0].configuration : local.empty_minion_config

  ubuntu2204_minion_configuration    = length(module.ubuntu2204_minion) > 0 ? module.ubuntu2204_minion[0].configuration : local.empty_minion_config
  ubuntu2204_sshminion_configuration = length(module.ubuntu2204_sshminion) > 0 ? module.ubuntu2204_sshminion[0].configuration : local.empty_minion_config

  ubuntu2404_minion_configuration    = length(module.ubuntu2404_minion) > 0 ? module.ubuntu2404_minion[0].configuration : local.empty_minion_config
  ubuntu2404_sshminion_configuration = length(module.ubuntu2404_sshminion) > 0 ? module.ubuntu2404_sshminion[0].configuration : local.empty_minion_config

  debian12_minion_configuration    = length(module.debian12_minion) > 0 ? module.debian12_minion[0].configuration : local.empty_minion_config
  debian12_sshminion_configuration = length(module.debian12_sshminion) > 0 ? module.debian12_sshminion[0].configuration : local.empty_minion_config

  opensuse156arm_minion_configuration    = length(module.opensuse156arm_minion) > 0 ? module.opensuse156arm_minion[0].configuration : local.empty_minion_config
  opensuse156arm_sshminion_configuration = length(module.opensuse156arm_sshminion) > 0 ? module.opensuse156arm_sshminion[0].configuration : local.empty_minion_config

  sle15sp5s390_minion_configuration    = length(module.sles15sp5s390_minion) > 0 ? module.sles15sp5s390_minion[0].configuration : local.empty_minion_config
  sle15sp5s390_sshminion_configuration = length(module.sles15sp5s390_sshminion) > 0 ? module.sles15sp5s390_sshminion[0].configuration : local.empty_minion_config

  salt_migration_minion_configuration = length(module.salt_migration_minion) > 0 ? module.salt_migration_minion[0].configuration : local.empty_minion_config

  slemicro51_minion_configuration = length(module.slemicro51_minion) > 0 ? module.slemicro51_minion[0].configuration : local.empty_minion_config
  slemicro52_minion_configuration = length(module.slemicro52_minion) > 0 ? module.slemicro52_minion[0].configuration : local.empty_minion_config
  slemicro53_minion_configuration = length(module.slemicro53_minion) > 0 ? module.slemicro53_minion[0].configuration : local.empty_minion_config
  slemicro54_minion_configuration = length(module.slemicro54_minion) > 0 ? module.slemicro54_minion[0].configuration : local.empty_minion_config
  slemicro55_minion_configuration = length(module.slemicro55_minion) > 0 ? module.slemicro55_minion[0].configuration : local.empty_minion_config
  slmicro60_minion_configuration  = length(module.slmicro60_minion) > 0 ? module.slmicro60_minion[0].configuration : local.empty_minion_config
  slmicro61_minion_configuration  = length(module.slmicro61_minion) > 0 ? module.slmicro61_minion[0].configuration : local.empty_minion_config

  sle15sp6_buildhost_configuration = length(module.sles15sp6_buildhost) > 0 ? module.sles15sp6_buildhost[0].configuration : local.empty_minion_config
  sle15sp7_buildhost_configuration = length(module.sles15sp7_buildhost) > 0 ? module.sles15sp7_buildhost[0].configuration : local.empty_minion_config

  sle15sp6_terminal_configuration = length(module.sles15sp6_terminal) > 0 ? module.sles15sp6_terminal[0].configuration : local.empty_terminal_config
  sle15sp7_terminal_configuration = length(module.sles15sp7_terminal) > 0 ? module.sles15sp7_terminal[0].configuration : local.empty_terminal_config

  monitoringserver_configuration = length(module.monitoring_server) > 0 ? module.monitoring_server[0].configuration : local.empty_minion_config
}

output "configuration" {
  value = {
    controller           = module.controller.configuration
    server_configuration = local.server_configuration
  }
}