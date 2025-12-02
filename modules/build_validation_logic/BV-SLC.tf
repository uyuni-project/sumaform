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
# 1. PROVIDERS (Distributed Infrastructure)
# -------------------------------------------------------------------

# Core Hypervisor (Caladan)
provider "libvirt" {
  uri = "qemu+tcp://caladan.mgr.slc1.suse.org/system"
}

# Old SLE Host (Tatooine)
provider "libvirt" {
  alias = "tatooine"
  uri   = "qemu+tcp://tatooine.mgr.slc1.suse.org/system"
}

# New SLE Host (Florina)
provider "libvirt" {
  alias = "florina"
  uri   = "qemu+tcp://florina.mgr.slc1.suse.org/system"
}

# Retail/Infrastructure Host (Terminus)
provider "libvirt" {
  alias = "terminus"
  uri   = "qemu+tcp://terminus.mgr.slc1.suse.org/system"
}

# Debian/Ubuntu Host (Trantor)
provider "libvirt" {
  alias = "trantor"
  uri   = "qemu+tcp://trantor.mgr.slc1.suse.org/system"
}

# ARM Host (Shared)
provider "libvirt" {
  alias = "suma-arm"
  uri   = "qemu+tcp://suma-arm.mgr.suse.de/system"
}

provider "feilong" {
  connector   = "https://feilong.mgr.suse.de"
  admin_token = var.ZVM_ADMIN_TOKEN
  local_user  = "jenkins@jenkins-worker.mgr.slc1.suse.org"
}

# -------------------------------------------------------------------
# 2. DISTRIBUTED BASE CONFIGURATIONS
# -------------------------------------------------------------------

# Base Core (Caladan): Core Infra + Main Testsuite images
module "base_core" {
  source = "./modules/base"

  cc_username       = var.SCC_USER
  cc_password       = var.SCC_PASSWORD
  product_version   = var.PRODUCT_VERSION != null ? var.PRODUCT_VERSION : var.ENVIRONMENT_CONFIGURATION.product_version
  name_prefix       = var.ENVIRONMENT_CONFIGURATION.name_prefix
  use_avahi         = false
  domain            = var.PLATFORM_LOCATION_CONFIGURATION[var.LOCATION].domain

  images            = ["sles15sp4o", "opensuse155o", "opensuse156o", "slemicro55o", "sles15sp5o"]

  mirror            = var.PLATFORM_LOCATION_CONFIGURATION[var.LOCATION].mirror
  use_mirror_images = true
  testsuite         = true

  provider_settings = {
    pool        = "ssd"
    bridge      = "br1"
  }
}

# Base Old SLE (Tatooine): SLES 12
module "base_old_sle" {
  providers = { libvirt = libvirt.tatooine }
  source    = "./modules/base"

  cc_username       = var.SCC_USER
  cc_password       = var.SCC_PASSWORD
  product_version   = var.PRODUCT_VERSION != null ? var.PRODUCT_VERSION : var.ENVIRONMENT_CONFIGURATION.product_version
  name_prefix       = var.ENVIRONMENT_CONFIGURATION.name_prefix
  use_avahi         = false
  domain            = var.PLATFORM_LOCATION_CONFIGURATION[var.LOCATION].domain

  images            = ["sles12sp5o","sles15sp3o", "sles15sp4o"]

  mirror            = var.PLATFORM_LOCATION_CONFIGURATION[var.LOCATION].mirror
  use_mirror_images = true
  testsuite         = true

  provider_settings = {
    pool        = "ssd"
    bridge      = "br1"
  }
}

# Base RES (Tatooine): EL and Liberty
module "base_res" {
  providers = { libvirt = libvirt.tatooine }
  source    = "./modules/base"

  cc_username       = var.SCC_USER
  cc_password       = var.SCC_PASSWORD
  product_version   = var.PRODUCT_VERSION != null ? var.PRODUCT_VERSION : var.ENVIRONMENT_CONFIGURATION.product_version
  name_prefix       = var.ENVIRONMENT_CONFIGURATION.name_prefix
  use_avahi         = false
  domain            = var.PLATFORM_LOCATION_CONFIGURATION[var.LOCATION].domain

  images            = ["almalinux8o", "almalinux9o", "centos7o", "oraclelinux9o", "rocky8o", "rocky9o", "libertylinux9o"]

  mirror            = var.PLATFORM_LOCATION_CONFIGURATION[var.LOCATION].mirror
  use_mirror_images = true
  testsuite         = true

  provider_settings = {
    pool        = "ssd"
    bridge      = "br1"
  }
}

# Base New SLE (Florina): SLES 15 + Micro
module "base_new_sle" {
  providers = { libvirt = libvirt.florina }
  source    = "./modules/base"

  cc_username       = var.SCC_USER
  cc_password       = var.SCC_PASSWORD
  product_version   = var.PRODUCT_VERSION != null ? var.PRODUCT_VERSION : var.ENVIRONMENT_CONFIGURATION.product_version
  name_prefix       = var.ENVIRONMENT_CONFIGURATION.name_prefix
  use_avahi         = false
  domain            = var.PLATFORM_LOCATION_CONFIGURATION[var.LOCATION].domain

  images            = ["sles15sp5o", "sles15sp6o", "sles15sp7o",
    "slemicro51-ign", "slemicro52-ign", "slemicro53-ign", "slemicro54-ign", "slemicro55o",
    "slmicro60o", "slmicro61o"]

  mirror            = var.PLATFORM_LOCATION_CONFIGURATION[var.LOCATION].mirror
  use_mirror_images = true
  testsuite         = true

  provider_settings = {
    pool        = "ssd"
    bridge      = "br1"
  }
}

# Base Retail (Terminus): Infrastructure components
module "base_retail" {
  providers = { libvirt = libvirt.terminus }
  source    = "./modules/base"

  cc_username       = var.SCC_USER
  cc_password       = var.SCC_PASSWORD
  product_version   = var.PRODUCT_VERSION != null ? var.PRODUCT_VERSION : var.ENVIRONMENT_CONFIGURATION.product_version
  name_prefix       = var.ENVIRONMENT_CONFIGURATION.name_prefix
  use_avahi         = false
  domain            = var.PLATFORM_LOCATION_CONFIGURATION[var.LOCATION].domain

  images            = ["sles12sp5o", "sles15sp6o", "sles15sp7o", "opensuse155o", "opensuse156o", "slemicro55o"]

  mirror            = var.PLATFORM_LOCATION_CONFIGURATION[var.LOCATION].mirror
  use_mirror_images = true
  testsuite         = true

  provider_settings = {
    pool               = "ssd"
    bridge             = "br1"
    additional_network = "192.168.50.0/24" # SLC Specific Network
  }
}

# Base Debian (Trantor)
module "base_debian" {
  providers = { libvirt = libvirt.trantor }
  source    = "./modules/base"

  cc_username       = var.SCC_USER
  cc_password       = var.SCC_PASSWORD
  product_version   = var.PRODUCT_VERSION != null ? var.PRODUCT_VERSION : var.ENVIRONMENT_CONFIGURATION.product_version
  name_prefix       = var.ENVIRONMENT_CONFIGURATION.name_prefix
  use_avahi         = false
  domain            = var.PLATFORM_LOCATION_CONFIGURATION[var.LOCATION].domain

  images            = ["ubuntu2004o", "ubuntu2204o", "ubuntu2404o", "debian12o"]

  mirror            = var.PLATFORM_LOCATION_CONFIGURATION[var.LOCATION].mirror
  use_mirror_images = true
  testsuite         = true

  provider_settings = {
    pool        = "ssd"
    bridge      = "br1"
  }
}

# Base ARM (Suma-ARM)
module "base_arm" {
  providers = { libvirt = libvirt.suma-arm }
  source    = "./modules/base"

  cc_username       = var.SCC_USER
  cc_password       = var.SCC_PASSWORD
  product_version   = var.PRODUCT_VERSION != null ? var.PRODUCT_VERSION : var.ENVIRONMENT_CONFIGURATION.product_version
  name_prefix       = var.ENVIRONMENT_CONFIGURATION.name_prefix
  use_avahi         = false
  domain            = var.PLATFORM_LOCATION_CONFIGURATION[var.LOCATION].domain

  images            = ["opensuse156armo"]

  mirror            = var.PLATFORM_LOCATION_CONFIGURATION[var.LOCATION].mirror
  use_mirror_images = true
  testsuite         = true

  provider_settings = {
    pool   = "ssd"
    bridge = "br0" # Specific bridge for ARM host
  }
}

# -------------------------------------------------------------------
# 3. SHARED LOGIC INTEGRATION
# -------------------------------------------------------------------
module "bv_logic" {
  source = "./modules/build_validation_logic"

  # --- PROVIDER MAPPING ---
  # Plug the specific hardware providers into the logic slots
  providers = {
    libvirt.host_old_sle = libvirt.tatooine
    libvirt.host_new_sle = libvirt.florina
    libvirt.host_res     = libvirt.tatooine
    libvirt.host_debian  = libvirt.trantor
    libvirt.host_retail  = libvirt.terminus
    libvirt.host_arm     = libvirt.suma-arm
  }

  # --- BASE MAPPING ---
  # Map roles to the specific distributed bases
  base_configurations = {
    default = module.base_core.configuration
    old_sle = module.base_old_sle.configuration
    new_sle = module.base_new_sle.configuration
    res     = module.base_res.configuration
    debian  = module.base_debian.configuration
    retail  = module.base_retail.configuration
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

# -------------------------------------------------------------------
# 4. OUTPUTS
# -------------------------------------------------------------------
output "configuration" {
  value = {
    controller = module.bv_logic.controller_configuration
    server     = module.bv_logic.server_configuration
  }
}