terraform {
  required_providers {
    feilong = {
      source = "bischoff/feilong"
    }
  }
}

module "base_s390" {
  source = "../../../backend_modules/feilong/base"

  name_prefix     = var.name_prefix
  domain          = var.domain
  product_version = var.product_version

  testsuite = true
}

module "sles15sp5s390_minion" {
  source             = "../../../backend_modules/feilong/host"
  count              = var.sles15sp5s390_minion_configuration != null ? 1 : 0
  base_configuration = module.base_s390.configuration

  name  = var.sles15sp5s390_minion_configuration.name
  image = "s15s5-minimal-2part-xfs"

  provider_settings = {
    userid     = var.sles15sp5s390_minion_configuration.userid
    os_version = "sles15.5"
    mac        = var.sles15sp5s390_minion_configuration.mac
    ssh_user   = "sles"
    vswitch    = "VSUMA"
  }

  use_os_released_updates = false
  ssh_key_path            = "./salt/controller/id_ed25519.pub"
}

module "sles15sp5s390_sshminion" {
  source             = "../../../backend_modules/feilong/host"
  count              = var.sles15sp5s390_sshminion_configuration != null ? 1 : 0
  base_configuration = module.base_s390.configuration

  name  = var.sles15sp5s390_sshminion_configuration.name
  image = "s15s5-minimal-2part-xfs"

  provider_settings = {
    userid     = var.sles15sp5s390_sshminion_configuration.userid
    os_version = "sles15.5"
    mac        = var.sles15sp5s390_sshminion_configuration.mac
    ssh_user   = "sles"
    vswitch    = "VSUMA"
  }

  use_os_released_updates = false
  ssh_key_path            = "./salt/controller/id_ed25519.pub"
}
