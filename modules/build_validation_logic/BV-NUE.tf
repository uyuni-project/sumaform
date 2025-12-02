terraform {
  required_version = ">= 1.6.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3"
    }
    feilong = {
      source  = "bischoff/feilong"
      version = "0.0.6"
    }
  }
}

# -------------------------------------------------------------------
# 1. PROVIDERS
# -------------------------------------------------------------------

# Main Hypervisor (NUE Local)
provider "libvirt" {
  uri = "qemu+tcp://${var.ENVIRONMENT_CONFIGURATION.base_core["hypervisor"]}/system"
}

# Shared ARM Hypervisor (Remote, common to all locations)
provider "libvirt" {
  alias = "suma-arm"
  uri   = "qemu+tcp://suma-arm.mgr.suse.de/system"
}

provider "feilong" {
  connector   = "https://feilong.mgr.suse.de"
  admin_token = var.ZVM_ADMIN_TOKEN
  local_user  = "jenkins@jenkins-worker.mgr.suse.de"
}

# -------------------------------------------------------------------
# 2. BASE CONFIGURATIONS
# -------------------------------------------------------------------

# Base Core: Loads ALL x86_64 images on the local NUE hypervisor
module "base_core" {
  source = "./modules/base"

  cc_username     = var.SCC_USER
  cc_password     = var.SCC_PASSWORD
  product_version = var.PRODUCT_VERSION != null ? var.PRODUCT_VERSION : var.ENVIRONMENT_CONFIGURATION.product_version
  name_prefix     = var.ENVIRONMENT_CONFIGURATION.name_prefix
  use_avahi       = false
  domain          = var.PLATFORM_LOCATION_CONFIGURATION[var.LOCATION].domain

  # Images for all Intel/AMD minions
  images = [
    "sles12sp5o",
    "sles15sp3o", "sles15sp4o", "sles15sp5o", "sles15sp6o", "sles15sp7o",
    "slemicro51-ign", "slemicro52-ign", "slemicro53-ign", "slemicro54-ign", "slemicro55o",
    "slmicro60o", "slmicro61o",
    "almalinux8o", "almalinux9o",
    "amazonlinux2023o",
    "centos7o",
    "libertylinux9o",
    "oraclelinux9o",
    "rocky8o", "rocky9o",
    "ubuntu2204o", "ubuntu2404o",
    "debian12o",
    "opensuse155o", "opensuse156o"
  ]

  mirror            = var.PLATFORM_LOCATION_CONFIGURATION[var.LOCATION].mirror
  use_mirror_images = true
  testsuite         = true

  provider_settings = {
    pool               = var.ENVIRONMENT_CONFIGURATION.base_core["pool"]
    bridge             = var.ENVIRONMENT_CONFIGURATION.base_core["bridge"]
    additional_network = var.ENVIRONMENT_CONFIGURATION.base_core["additional_network"]
  }
}

# Base ARM: Loads ARM images on the shared remote hypervisor
module "base_arm" {
  providers = {
    libvirt = libvirt.suma-arm
  }

  source = "./modules/base"

  cc_username     = var.SCC_USER
  cc_password     = var.SCC_PASSWORD
  product_version = var.PRODUCT_VERSION != null ? var.PRODUCT_VERSION : var.ENVIRONMENT_CONFIGURATION.product_version
  name_prefix     = var.ENVIRONMENT_CONFIGURATION.name_prefix
  use_avahi       = false
  domain          = var.PLATFORM_LOCATION_CONFIGURATION[var.LOCATION].domain

  images          = ["opensuse156armo"]

  mirror            = var.PLATFORM_LOCATION_CONFIGURATION[var.LOCATION].mirror
  use_mirror_images = true
  testsuite         = true

  provider_settings = {
    pool   = "ssd"
    bridge = "br1"
  }
}

# -------------------------------------------------------------------
# 3. SERVER INFRASTRUCTURE
# -------------------------------------------------------------------
module "server_containerized" {
  source             = "./modules/server_containerized"
  base_configuration = module.base_core.configuration
  name               = var.ENVIRONMENT_CONFIGURATION.server_containerized.name
  image              = var.BASE_OS != null ? var.BASE_OS : var.ENVIRONMENT_CONFIGURATION.server_base_os

  provider_settings = {
    mac    = var.ENVIRONMENT_CONFIGURATION.server_containerized.mac
    memory = 40960
    vcpu   = 10
  }

  runtime              = "podman"
  container_repository = var.SERVER_CONTAINER_REPOSITORY
  container_image      = var.SERVER_CONTAINER_IMAGE
  container_tag        = "latest"
  main_disk_size       = 100
  repository_disk_size = 3072
  database_disk_size   = 150

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
}

# -------------------------------------------------------------------
# 4. SHARED LOGIC INTEGRATION
# -------------------------------------------------------------------
module "bv_logic" {
  source = "./modules/build_validation_logic"

  # --- PROVIDER MAPPING ---
  # Plug the default provider for everything EXCEPT ARM
  providers = {
    libvirt.host_old_sle = libvirt
    libvirt.host_new_sle = libvirt
    libvirt.host_res     = libvirt
    libvirt.host_debian  = libvirt
    libvirt.host_retail  = libvirt
    # Plug the specific ARM provider here
    libvirt.host_arm     = libvirt.suma-arm
  }

  # --- BASE MAPPING ---
  # Map roles to base_core, except ARM
  base_configurations = {
    default = module.base_core.configuration
    old_sle = module.base_core.configuration
    new_sle = module.base_core.configuration
    res     = module.base_core.configuration
    debian  = module.base_core.configuration
    retail  = module.base_core.configuration
    # Map ARM to the specific base module defined above
    arm     = module.base_arm.configuration
  }

  # --- VARIABLES ---
  ENVIRONMENT_CONFIGURATION       = var.ENVIRONMENT_CONFIGURATION
  PLATFORM_LOCATION_CONFIGURATION = var.PLATFORM_LOCATION_CONFIGURATION[var.LOCATION]
  LOCATION                        = var.LOCATION
  product_version                 = var.PRODUCT_VERSION != null ? var.PRODUCT_VERSION : var.ENVIRONMENT_CONFIGURATION.product_version

  SCC_USER         = var.SCC_USER
  SCC_PASSWORD     = var.SCC_PASSWORD
  SCC_PTF_USER     = var.SCC_PTF_USER
  SCC_PTF_PASSWORD = var.SCC_PTF_PASSWORD

  GIT_USER          = var.GIT_USER
  GIT_PASSWORD      = var.GIT_PASSWORD
  CUCUMBER_GITREPO  = var.CUCUMBER_GITREPO
  CUCUMBER_BRANCH   = var.CUCUMBER_BRANCH

  SERVER_CONTAINER_REPOSITORY = var.SERVER_CONTAINER_REPOSITORY
  SERVER_CONTAINER_IMAGE      = var.SERVER_CONTAINER_IMAGE
  PROXY_CONTAINER_REPOSITORY  = var.PROXY_CONTAINER_REPOSITORY
  BASE_OS                     = var.BASE_OS
}

output "configuration" {
  value = {
    controller = module.bv_logic.controller_configuration
    server     = module.bv_logic.server_configuration
  }
}