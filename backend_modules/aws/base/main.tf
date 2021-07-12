locals {
  availability_zone = lookup(var.provider_settings, "availability_zone", null)
  region            = lookup(var.provider_settings, "region", null)
  ssh_allowed_ips   = lookup(var.provider_settings, "ssh_allowed_ips", [])
  name_prefix       = var.name_prefix

  key_name = lookup(var.provider_settings, "key_name", null)
  key_file = lookup(var.provider_settings, "key_file", null)

  create_network                       = lookup(var.provider_settings, "create_network", true)
  public_subnet_id                     = lookup(var.provider_settings, "public_subnet_id", null)
  private_subnet_id                    = lookup(var.provider_settings, "private_subnet_id", null)
  private_additional_subnet_id         = lookup(var.provider_settings, "private_additional_subnet_id", null)
  public_security_group_id             = lookup(var.provider_settings, "public_security_group_id", null)
  private_security_group_id            = lookup(var.provider_settings, "private_security_group_id", null)
  private_additional_security_group_id = lookup(var.provider_settings, "private_additional_security_group_id", null)
  bastion_host                         = lookup(var.provider_settings, "bastion_host", null)

  additional_network = lookup(var.provider_settings, "additional_network", "172.16.2.0/24")
}

data "aws_ami" "opensuse152" {
  most_recent = true
  name_regex  = "^openSUSE-Leap-15-2-v"
  owners      = ["679593333241"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "sles15" {
  most_recent = true
  name_regex  = "^suse-sles-15-byos-v"
  owners      = ["013907871322"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "sles15sp1" {
  most_recent = true
  name_regex  = "^suse-sles-15-sp1-byos-v"
  owners      = ["013907871322"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "sles15sp2o" {
  most_recent = true
  name_regex  = "^suse-sles-15-sp2-byos-v"
  owners      = ["013907871322"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "sles12sp5" {
  most_recent = true
  name_regex  = "^suse-sles-12-sp5-byos-v"
  owners      = ["013907871322"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "sles12sp4" {
  most_recent = true
  name_regex  = "^suse-sles-12-sp4-byos-v"
  owners      = ["013907871322"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "sles12sp3" {
  most_recent = true
  name_regex  = "^suse-sles-12-sp3-byos-v"
  owners      = ["013907871322"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "sles12sp2" {
  most_recent = true
  name_regex  = "^suse-sles-12-sp2-byos-v"
  owners      = ["013907871322"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "sles11sp4" {
  most_recent = true
  name_regex  = "^suse-sles-11-sp4-byos-v"
  owners      = ["013907871322"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "centos7" {
  most_recent = true
  name_regex  = "^CentOS Linux 7 x86_64 HVM EBS"
  owners      = ["679593333241"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "centos6" {
  most_recent = true
  name_regex  = "^CentOS Linux 6 x86_64 HVM EBS"
  owners      = ["679593333241"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "ubuntu2004" {
  most_recent = true
  name_regex  = "^ubuntu/images/hvm-ssd/ubuntu-focal-20.04"
  owners      = ["679593333241"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "ubuntu1804" {
  most_recent = true
  name_regex  = "^ubuntu/images/hvm-ssd/ubuntu-bionic-18.04"
  owners      = ["679593333241"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "ubuntu1604" {
  most_recent = true
  name_regex  = "^ubuntu/images/hvm-ssd/ubuntu-xenial-16.04"
  owners      = ["679593333241"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "rhel8" {
  most_recent = true
  name_regex  = "^RHEL-8.2.0_HVM-"
  owners      = ["309956199498"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "rhel7" {
  most_recent = true
  name_regex  = "^RHEL-7.7_HVM-"
  owners      = ["309956199498"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

module "network" {
  source = "../network"

  availability_zone  = local.availability_zone
  region             = local.region
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

    region            = local.region
    availability_zone = local.availability_zone

    key_name = local.key_name
    key_file = local.key_file
    ami_info = {
      opensuse152 = { ami = data.aws_ami.opensuse152.image_id },
      sles15      = { ami = data.aws_ami.sles15.image_id },
      sles15sp1   = { ami = data.aws_ami.sles15sp1.image_id },
      sles15sp2o   = { ami = data.aws_ami.sles15sp2o.image_id },
      sles12sp5   = { ami = data.aws_ami.sles12sp5.image_id },
      sles12sp4   = { ami = data.aws_ami.sles12sp4.image_id },
      sles12sp3   = { ami = data.aws_ami.sles12sp3.image_id },
      sles12sp2   = { ami = data.aws_ami.sles12sp2.image_id },
      sles11sp4   = { ami = data.aws_ami.sles11sp4.image_id },
      centos7     = { ami = data.aws_ami.centos7.image_id, ssh_user = "centos" },
      centos6     = { ami = data.aws_ami.centos6.image_id, ssh_user = "centos" },
      ubuntu2004  = { ami = data.aws_ami.ubuntu2004.image_id, ssh_user = "ubuntu" },
      ubuntu1804  = { ami = data.aws_ami.ubuntu1804.image_id, ssh_user = "ubuntu" },
      ubuntu1604  = { ami = data.aws_ami.ubuntu1604.image_id, ssh_user = "ubuntu" },
      rhel8       = { ami = data.aws_ami.rhel8.image_id},
      rhel7       = { ami = data.aws_ami.rhel7.image_id},
    }
    },
    local.create_network ? module.network.configuration : {
      public_subnet_id                     = local.public_subnet_id
      private_subnet_id                    = local.private_subnet_id
      private_additional_subnet_id         = local.private_additional_subnet_id
      public_security_group_id             = local.public_security_group_id
      private_security_group_id            = local.private_security_group_id
      private_additional_security_group_id = local.private_additional_security_group_id
  })
}

module "bastion" {
  source                        = "../host"
  quantity                      = local.create_network ? 1 : 0
  base_configuration            = local.configuration_output
  image                         = "opensuse152"
  name                          = "bastion"
  connect_to_additional_network = true
  provider_settings = {
    instance_type   = "t2.micro"
    public_instance = true
  }
}

output "configuration" {
  value = merge(local.configuration_output, {
    bastion_host = local.create_network ? (length(module.bastion.configuration.public_names) > 0 ? module.bastion.configuration.public_names[0] : null) : local.bastion_host
  })
}
