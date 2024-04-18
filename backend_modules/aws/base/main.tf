locals {
  availability_zone = lookup(var.provider_settings, "availability_zone", null)
  region            = lookup(var.provider_settings, "region", null)
  ssh_allowed_ips   = lookup(var.provider_settings, "ssh_allowed_ips", [])
  name_prefix       = var.name_prefix

  key_name = lookup(var.provider_settings, "key_name", null)
  key_file = lookup(var.provider_settings, "key_file", null)

  create_network                       = lookup(var.provider_settings, "create_network", true)
  create_private_network               = lookup(var.provider_settings, "create_private_network", true)
  create_additional_network            = lookup(var.provider_settings, "create_additional_network", true)
  create_db_network                    = lookup(var.provider_settings, "create_db_network", false)
  public_subnet_id                     = lookup(var.provider_settings, "public_subnet_id", null)
  private_subnet_id                    = lookup(var.provider_settings, "private_subnet_id", null)
  private_additional_subnet_id         = lookup(var.provider_settings, "private_additional_subnet_id", null)
  db_private_subnet_name               = lookup(var.provider_settings, "db_private_subnet_name", null)
  public_security_group_id             = lookup(var.provider_settings, "public_security_group_id", null)
  private_security_group_id            = lookup(var.provider_settings, "private_security_group_id", null)
  private_additional_security_group_id = lookup(var.provider_settings, "private_additional_security_group_id", null)
  vpc_id                               = lookup(var.provider_settings, "vpc_id", null)
  bastion_host                         = lookup(var.provider_settings, "bastion_host", null)
  route53_domain                       = lookup(var.provider_settings, "route53_domain", null)

  additional_network = lookup(var.provider_settings, "additional_network", "172.16.2.0/24")
  private_network    = lookup(var.provider_settings, "private_network", "172.16.1.0/24")
}

module "network" {
  source = "../network"

  availability_zone         = local.availability_zone
  region                    = local.region
  ssh_allowed_ips           = local.ssh_allowed_ips
  name_prefix               = local.name_prefix
  create_network            = local.create_network
  create_private_network    = local.create_private_network
  create_additional_network = local.create_additional_network
  create_db_network         = local.create_db_network
  private_network           = local.private_network
  additional_network        = local.additional_network
  public_subnet_id          = local.public_subnet_id
  vpc_id                    = local.vpc_id
  route53_domain            = local.route53_domain
}

locals {
  configuration_output = merge({
    cc_username              = var.cc_username
    cc_password              = var.cc_password
    timezone                 = var.timezone
    use_ntp                  = var.use_ntp
    ssh_key_path             = var.ssh_key_path
    mirror                   = var.mirror
    use_mirror_images        = var.use_mirror_images
    use_avahi                = var.use_avahi
    domain                   = var.domain
    name_prefix              = var.name_prefix
    use_shared_resources     = var.use_shared_resources
    testsuite                = var.testsuite
    additional_network       = local.additional_network

    region            = local.region
    availability_zone = local.availability_zone

    key_name = local.key_name
    key_file = local.key_file
    iam_instance_profile = length(aws_iam_instance_profile.metering_full_access_instance_profile) > 0 ? aws_iam_instance_profile.metering_full_access_instance_profile[0].name : null
    ami_info = {
      opensuse155o         = { ami = data.aws_ami.opensuse155o.image_id },
      sles15sp2o           = { ami = data.aws_ami.sles15sp2o.image_id },
      sles15sp3o           = { ami = data.aws_ami.sles15sp3o.image_id },
      sles15sp4o           = { ami = data.aws_ami.sles15sp4o.image_id },
      sles15sp5o           = { ami = data.aws_ami.sles15sp5o.image_id },
      slemicro54           = { ami = data.aws_ami.slemicro54-ign.image_id },
      slemicro55           = { ami = data.aws_ami.slemicro55-ign.image_id },
      sles15sp5-paygo      = { ami = data.aws_ami.sles15sp5-paygo.image_id },
      slesforsap15sp5-paygo= { ami = data.aws_ami.slesforsap15sp5-paygo.image_id },
      suma-server-43-byos  = { ami = data.aws_ami.suma-server-43-byos.image_id },
      suma-server-43-ltd-paygo = { ami = data.aws_ami.suma-server-43-ltd-paygo.image_id },
      suma-server-43-llc-paygo = { ami = data.aws_ami.suma-server-43-llc-paygo.image_id },
      suma-proxy-43-byos   = { ami = data.aws_ami.suma-proxy-43-byos.image_id },
      sles12sp5            = { ami = data.aws_ami.sles12sp5.image_id },
      sles12sp5-paygo      = { ami = data.aws_ami.sles12sp5-paygo.image_id },
      rocky8               = { ami = data.aws_ami.rocky8.image_id, ssh_user = "rocky" },
      debian11             = { ami = data.aws_ami.debian11.image_id, ssh_user= "admin" },
      ubuntu2204           = { ami = data.aws_ami.ubuntu2204.image_id, ssh_user = "ubuntu" },
      ubuntu2004           = { ami = data.aws_ami.ubuntu2004.image_id, ssh_user = "ubuntu" },
      rhel8                = { ami = data.aws_ami.rhel8.image_id},
      rhel9                = { ami = data.aws_ami.rhel9.image_id},
    }
    },
    module.network.configuration,
    !local.create_network ? {
      public_subnet_id                     = local.public_subnet_id
      db_private_subnet_name               = local.db_private_subnet_name
      public_security_group_id             = local.public_security_group_id
    } : {},
    !local.create_private_network ? {
      private_subnet_id                    = local.private_subnet_id
      private_security_group_id            = local.private_security_group_id
    } : {},
    !local.create_additional_network ? {
      private_additional_subnet_id         = local.private_additional_subnet_id
      private_additional_security_group_id = local.private_additional_security_group_id
    } : {})
}

module "bastion" {
  source                        = "../host"
  quantity                      = local.create_network ? 1 : 0
  base_configuration            = local.configuration_output
  image                         = lookup(var.provider_settings, "bastion_image", "opensuse155o")
  name                          = "bastion"
  provider_settings = {
    instance_type   = "t3a.micro"
    public_instance = true
    instance_with_eip = var.use_eip_bastion
    overwrite_fqdn    = local.bastion_host
  }
}

output "configuration" {
  value = merge(local.configuration_output, {
    bastion_host = local.create_network ? (length(module.bastion.configuration.public_names) > 0 ? module.bastion.configuration.public_names[0] : null) : local.bastion_host
  })
}
