locals {
  name_prefix                          = var.name_prefix

  create_network                       = lookup(var.provider_settings, "create_network", true)
  location                             = lookup(var.provider_settings, "location", null)
  ssh_allowed_ips                      = lookup(var.provider_settings, "ssh_allowed_ips", [])
  additional_network                   = lookup(var.provider_settings, "additional_network", "172.16.2.0/24")

  public_subnet_id                     = lookup(var.provider_settings, "public_subnet_id", null)
  private_subnet_id                    = lookup(var.provider_settings, "private_subnet_id", null)
  private_additional_subnet_id         = lookup(var.provider_settings, "private_additional_subnet_id", null)
  public_security_group_id             = lookup(var.provider_settings, "public_security_group_id", null)
  private_security_group_id            = lookup(var.provider_settings, "private_security_group_id", null)
  private_additional_security_group_id = lookup(var.provider_settings, "private_additional_security_group_id", null)
  bastion_host                         = lookup(var.provider_settings, "bastion_host", null)
  public_key_location = lookup(var.provider_settings, "public_key_location", null)
  key_file = lookup(var.provider_settings, "key_file", null)
}

data "azurerm_platform_image" "opensuse152o" {
  location  = local.location
  publisher = "suse"
  offer     = "opensuse-leap"
  sku       = "15-2-gen2"
}

data "azurerm_platform_image" "opensuse153o" {
  location  = local.location
  publisher = "suse"
  offer     = "opensuse-leap-15-3"
  sku       = "gen1"
}

data "azurerm_platform_image" "sles15" {
  location  = local.location
  publisher = "suse"
  offer     = "SLES-BYOS"
  sku       = "15"
}

data "azurerm_platform_image" "sles12sp3" {
  location  = local.location
  publisher = "suse"
  offer     = "SLES-BYOS"
  sku       = "12-SP3"
}

data "azurerm_platform_image" "sles12sp4" {
  location  = local.location
  publisher = "suse"
  offer     = "SLES-BYOS"
  sku       = "12-SP4"
}

data "azurerm_platform_image" "sles11sp4" {
  location  = local.location
  publisher = "suse"
  offer     = "SLES-BYOS"
  sku       = "11-SP4"
}

data "azurerm_platform_image" "sles15sp1o" {
  location  = local.location
  publisher = "suse"
  offer     = "sles-15-sp1-byos"
  sku       = "gen1"
}

data "azurerm_platform_image" "sles15sp2o" {
  location  = local.location
  publisher = "suse"
  offer     = "sles-15-sp2-byos"
  sku       = "gen1"
}

data "azurerm_platform_image" "sles15sp3o" {
  location  = local.location
  publisher = "suse"
  offer     = "sles-15-sp3-byos"
  sku       = "gen1"
}

data "azurerm_platform_image" "centos6" {
  location  = local.location
  publisher = "OpenLogic"
  offer     = "CentOS"
  sku       = "6.10"
}

data "azurerm_platform_image" "centos7" {
  location  = local.location
  publisher = "OpenLogic"
  offer     = "CentOS-LVM"
  sku       = "7-LVM"
}

data "azurerm_platform_image" "rhel7" {
  location  = local.location
  publisher = "RedHat"
  offer     = "RHEL"
  sku       = "7-LVM"
}

data "azurerm_platform_image" "rhel8" {
  location  = local.location
  publisher = "RedHat"
  offer     = "RHEL"
  sku       = "8-LVM"
}

data "azurerm_platform_image" "rhel9" {
  location  = local.location
  publisher = "RedHat"
  offer     = "RHEL"
  sku       = "9-LVM"
}

data "azurerm_platform_image" "ubuntu1604" {
  location  = local.location
  publisher = "cognosys"
  offer     = "ubuntu-1604-lts"
  sku       = "ubuntu-16-04-lts"
}

data "azurerm_platform_image" "ubuntu1804" {
  location  = local.location
  publisher = "cognosys"
  offer     = "ubuntu-1804-lts"
  sku       = "ubuntu-18-04-lts"
}

data "azurerm_platform_image" "ubuntu2004" {
  location  = local.location
  publisher = "cognosys"
  offer     = "ubuntu-20-04-lts"
  sku       = "ubuntu-20-04-lts"
}

data "azurerm_platform_image" "suma41" {
  location  = local.location
  publisher = "suse"
  offer     = "manager-server-4-1-byos"
  sku       = "gen1"
}

data "azurerm_platform_image" "suma42" {
  location  = local.location
  publisher = "suse"
  offer     = "manager-server-4-2-byos"
  sku       = "gen1"
}

module "network" {
  source = "../network"

  location           = local.location
  ssh_allowed_ips    = local.ssh_allowed_ips
  name_prefix        = local.name_prefix
  create_network     = local.create_network
  additional_network = local.additional_network
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

    additional_network = local.additional_network

    location            = local.location

    public_key_location = local.public_key_location
    key_file = local.key_file
    resource_group_name = module.network.configuration.resource_group_name
    platform_image_info = {
      opensuse153o = { platform_image = data.azurerm_platform_image.opensuse153o },
      opensuse152o = { platform_image = data.azurerm_platform_image.opensuse152o },
      sles15       = { platform_image = data.azurerm_platform_image.sles15 },
      sles15sp1o   = { platform_image = data.azurerm_platform_image.sles15sp1o },
      sles15sp2o   = { platform_image = data.azurerm_platform_image.sles15sp2o },
      sles15sp3o   = { platform_image = data.azurerm_platform_image.sles15sp3o },
      sles12sp4    = { platform_image = data.azurerm_platform_image.sles12sp4 },
      sles12sp3    = { platform_image = data.azurerm_platform_image.sles12sp3 },
      sles11sp4    = { platform_image = data.azurerm_platform_image.sles11sp4 },
      centos6      = { platform_image = data.azurerm_platform_image.centos6 },
      centos7      = { platform_image = data.azurerm_platform_image.centos7 },
      ubuntu2004   = { platform_image = data.azurerm_platform_image.ubuntu2004 },
      ubuntu1804   = { platform_image = data.azurerm_platform_image.ubuntu1804 },
      ubuntu1604   = { platform_image = data.azurerm_platform_image.ubuntu1604 },
      rhel9        = { platform_image = data.azurerm_platform_image.rhel9 },
      rhel8        = { platform_image = data.azurerm_platform_image.rhel8 },
      rhel7        = { platform_image = data.azurerm_platform_image.rhel7 },
      suma41       = { platform_image = data.azurerm_platform_image.suma41 },
      suma42       = { platform_image = data.azurerm_platform_image.suma42 }

    }
    },
    local.create_network ? module.network.configuration : {
      public_subnet_id                     = local.public_subnet_id
      private_subnet_id                    = local.private_subnet_id
      private_additional_subnet_id         = local.private_additional_subnet_id
      public_security_group_id             = local.public_security_group_id
      private_security_group_id            = local.private_security_group_id
      private_additional_security_group_id = local.private_additional_security_group_id
  },
  )
}

 module "bastion" {
  source                        = "../host"
  quantity                      = local.create_network ? 1 : 0
  base_configuration            = local.configuration_output
  image                         = "opensuse152o"
  name                          = "bastion"
  connect_to_additional_network = true
  provider_settings = {
    vm_size = "Standard_B1s"
    public_instance = true
  }
}

output "configuration" {
     value = merge(local.configuration_output, {
    bastion_host = local.create_network ? (length(module.bastion.configuration.public_names) > 0 ? module.bastion.configuration.public_names[0] : null) : local.bastion_host
  })
}
