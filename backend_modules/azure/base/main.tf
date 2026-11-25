locals {
  name_prefix = var.name_prefix

  create_network     = lookup(var.provider_settings, "create_network", true)
  location           = lookup(var.provider_settings, "location", null)
  ssh_allowed_ips    = lookup(var.provider_settings, "ssh_allowed_ips", [])
  additional_network = lookup(var.provider_settings, "additional_network", "172.16.2.0/24")

  public_subnet_id             = lookup(var.provider_settings, "public_subnet_id", null)
  private_subnet_id            = lookup(var.provider_settings, "private_subnet_id", null)
  private_additional_subnet_id = lookup(var.provider_settings, "private_additional_subnet_id", null)
  bastion_host                 = lookup(var.provider_settings, "bastion_host", null)
  public_key_location          = lookup(var.provider_settings, "public_key_location", null)
  key_file                     = lookup(var.provider_settings, "key_file", null)
  disk_encryption_set_id       = lookup(var.provider_settings, "disk_encryption_set_id", null)
  resource_group_name          = lookup(var.provider_settings, "resource_group_name", null)

  // client tools repositories, used by cloud-init to install venv-salt-minion
  tools_repo = "https://download.opensuse.org/repositories/systemsmanagement:/Uyuni:/Stable:"
}

// Azure only publishes the latest Leap 16 minor release under this offer
data "azurerm_platform_image" "opensuse160o" {
  location  = local.location
  publisher = "susellc"
  offer     = "opensuse-leap-x86-64"
  sku       = "gen1"
}

data "azurerm_platform_image" "sles12sp5o" {
  location  = local.location
  publisher = "suse"
  offer     = "sles-12-sp5-byos"
  sku       = "gen2"
}

data "azurerm_platform_image" "sles15sp5o" {
  location  = local.location
  publisher = "suse"
  offer     = "sles-15-sp5-byos"
  sku       = "gen2"
}

data "azurerm_platform_image" "sles15sp6o" {
  location  = local.location
  publisher = "suse"
  offer     = "sles-15-sp6-byos"
  sku       = "gen2"
}

data "azurerm_platform_image" "sles15sp7o" {
  location  = local.location
  publisher = "suse"
  offer     = "sles-15-sp7-byos"
  sku       = "gen2"
}

data "azurerm_platform_image" "rhel8" {
  location  = local.location
  publisher = "RedHat"
  offer     = "RHEL"
  sku       = "8-lvm-gen2"
}

data "azurerm_platform_image" "rhel9" {
  location  = local.location
  publisher = "RedHat"
  offer     = "RHEL"
  sku       = "9-lvm-gen2"
}

data "azurerm_platform_image" "ubuntu2204" {
  location  = local.location
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-jammy"
  sku       = "22_04-lts-gen2"
}

data "azurerm_platform_image" "ubuntu2404" {
  location  = local.location
  publisher = "Canonical"
  offer     = "ubuntu-24_04-lts"
  sku       = "server"
}


module "network" {
  source = "../network"

  location            = local.location
  ssh_allowed_ips     = local.ssh_allowed_ips
  name_prefix         = local.name_prefix
  create_network      = local.create_network
  additional_network  = local.additional_network
  resource_group_name = local.resource_group_name
}

locals {
  configuration_output = merge({
    cc_username          = var.cc_username
    cc_password          = var.cc_password
    timezone             = var.timezone
    use_ntp              = var.use_ntp
    ssh_key_path         = var.ssh_key_path
    mirror               = var.mirror
    use_mirror_images    = var.use_mirror_images
    use_avahi            = var.use_avahi
    domain               = var.domain
    name_prefix          = var.name_prefix
    use_shared_resources = var.use_shared_resources
    testsuite            = var.testsuite
    product_version      = var.product_version

    additional_network = local.additional_network

    location = local.location

    public_key_location = local.public_key_location
    key_file            = local.key_file
    // opt-in customer-managed keys, disks use platform-managed encryption otherwise
    disk_encryption_set_id = local.disk_encryption_set_id
    platform_image_info = {
      opensuse160o = { platform_image = data.azurerm_platform_image.opensuse160o, tools_repo = "${local.tools_repo}/openSUSE_Leap_16-Uyuni-Client-Tools/openSUSE_Leap_16.0/" },
      sles15sp5o   = { platform_image = data.azurerm_platform_image.sles15sp5o, tools_repo = "${local.tools_repo}/SLE15-Uyuni-Client-Tools/SLE_15/" },
      sles15sp6o   = { platform_image = data.azurerm_platform_image.sles15sp6o, tools_repo = "${local.tools_repo}/SLE15-Uyuni-Client-Tools/SLE_15/" },
      sles15sp7o   = { platform_image = data.azurerm_platform_image.sles15sp7o, tools_repo = "${local.tools_repo}/SLE15-Uyuni-Client-Tools/SLE_15/" },
      sles12sp5o   = { platform_image = data.azurerm_platform_image.sles12sp5o, tools_repo = "${local.tools_repo}/SLE12-Uyuni-Client-Tools/SLE_12/" },
      ubuntu2204   = { platform_image = data.azurerm_platform_image.ubuntu2204, tools_repo = "${local.tools_repo}/Ubuntu2204-Uyuni-Client-Tools/xUbuntu_22.04/" },
      ubuntu2404   = { platform_image = data.azurerm_platform_image.ubuntu2404, tools_repo = "${local.tools_repo}/Ubuntu2404-Uyuni-Client-Tools/xUbuntu_24.04/" },
      rhel9        = { platform_image = data.azurerm_platform_image.rhel9, tools_repo = "${local.tools_repo}/EL9-Uyuni-Client-Tools/EL_9/" },
      rhel8        = { platform_image = data.azurerm_platform_image.rhel8, tools_repo = "${local.tools_repo}/EL8-Uyuni-Client-Tools/EL_8/" },
    }
    },
    module.network.configuration,
    local.create_network ? {} : {
      public_subnet_id             = local.public_subnet_id
      private_subnet_id            = local.private_subnet_id
      private_additional_subnet_id = local.private_additional_subnet_id
    },
  )
}

module "bastion" {
  source                        = "../host"
  quantity                      = local.create_network ? 1 : 0
  base_configuration            = local.configuration_output
  image                         = "opensuse160o"
  name                          = "bastion"
  main_disk_size                = 50
  connect_to_additional_network = true
  provider_settings = {
    vm_size         = "Standard_B1s"
    public_instance = true
  }
}

output "configuration" {
  value = merge(local.configuration_output, {
    bastion_host = local.create_network ? (length(module.bastion.configuration.public_names) > 0 ? module.bastion.configuration.public_names[0] : null) : local.bastion_host
  })
}
