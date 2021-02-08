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

data "azurerm_platform_image" "opensuse152" {
  location  = "France Central"
  publisher = "suse"
  offer     = "opensuse-leap"
  sku       = "15-2"
}

data "azurerm_platform_image" "sles15sp2" {
  location  = local.location
  publisher = "suse"
  offer     = "sles-15-sp2-byos"
  sku       = "gen1"
}

data "azurerm_platform_image" "suma41" {
  location  = local.location
  publisher = "suse"
  offer     = "manager-server-4-1-byos"
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
    #availability_zone = local.availability_zone

    public_key_location = local.public_key_location
    key_file = local.key_file
    resource_group_name = module.network.configuration.resource_group_name
    platform_image_info = {
      opensuse152 = { platform_image = data.azurerm_platform_image.opensuse152 },
      sles15sp2   = { platform_image = data.azurerm_platform_image.sles15sp2 },
      suma41 = { platform_image = data.azurerm_platform_image.suma41 },
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
  image                         = "opensuse152"
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