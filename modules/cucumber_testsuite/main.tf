provider "libvirt" {
  uri = var.provider_settings["libvirt"]["uri"]
}

module "base" {
  source = "../libvirt/base"

  cc_username = var.cc_username
  cc_password = var.cc_password
  use_avahi   = var.use_avahi
  domain      = var.domain
  name_prefix = var.name_prefix
  images      = var.images
  mirror = var.mirror
  use_shared_resources = var.use_shared_resources
  testsuite   = true

  pool               = lookup(var.provider_settings["libvirt"], "pool", null)
  network_name       = lookup(var.provider_settings["libvirt"], "network_name", "default")
  bridge             = lookup(var.provider_settings["libvirt"], "bridge", null)
  additional_network = lookup(var.provider_settings["libvirt"], "additional_network", null)
}

module "srv" {
  source                         = "../libvirt/suse_manager"
  base_configuration             = module.base.configuration
  product_version                = var.product_version
  name                           = "srv"
  auto_accept                    = false
  disable_firewall               = false
  allow_postgres_connections     = false
  skip_changelog_import          = false
  browser_side_less              = false
  create_first_user              = false
  mgr_sync_autologin             = false
  create_sample_channel          = false
  create_sample_activation_key   = false
  create_sample_bootstrap_script = false
  publish_private_ssl_key        = false
  disable_download_tokens        = false
  monitored                      = true
  use_os_released_updates        = true
  ssh_key_path                   = "./salt/controller/id_rsa.pub"
  from_email                     = var.from_email

  mac    = lookup(local.macs, "srv", "")
  memory = 8192
  vcpu   = 8
}

locals {
  server_full_name = "${var.name_prefix}srv.${var.domain}"
  macs = lookup(var.provider_settings["libvirt"], "macs", {})
}

module "pxy" {
  source = "../libvirt/suse_manager_proxy"

  quantity = var.proxy ? 1 : 0

  base_configuration = module.base.configuration
  product_version    = var.product_version
  name               = "pxy"

  server_configuration      = { hostname = local.server_full_name, username = "admin", password = "admin" }
  auto_register             = false
  auto_connect_to_master    = false
  download_private_ssl_key  = false
  auto_configure            = false
  generate_bootstrap_script = false
  publish_private_ssl_key   = false
  use_os_released_updates   = true
  ssh_key_path              = "./salt/controller/id_rsa.pub"

  mac    = lookup(local.macs, "pxy", null)
  memory = 2048
  vcpu   = 2
}

locals {
  proxy_full_name       = "${var.name_prefix}pxy.${var.domain}"
  minimal_configuration = { hostname = var.proxy ? local.proxy_full_name : local.server_full_name }
}

module "cli-sles12sp4" {
  source             = "../libvirt/client"
  base_configuration = module.base.configuration
  product_version    = var.product_version
  name               = "cli-sles12sp4"
  image              = "sles12sp4"

  server_configuration = local.minimal_configuration

  auto_register           = false
  use_os_released_updates = true
  ssh_key_path            = "./salt/controller/id_rsa.pub"

  mac = lookup(local.macs, "cli-sles12sp4", null)
}

module "min-sles12sp4" {
  source             = "../libvirt/minion"
  base_configuration = module.base.configuration
  product_version    = var.product_version
  name               = "min-sles12sp4"
  image              = "sles12sp4"

  server_configuration = local.minimal_configuration

  auto_connect_to_master  = false
  use_os_released_updates = true
  ssh_key_path            = "./salt/controller/id_rsa.pub"
  avahi_reflector         = var.use_avahi

  mac = lookup(local.macs, "min-sles12sp4", null)
}

module "minssh-sles12sp4" {
  source = "../libvirt/minionssh"

  quantity = contains(var.optional_clients, "minssh-sles12sp4") ? 1 : 0

  base_configuration = module.base.configuration
  product_version    = var.product_version
  name               = "minssh-sles12sp4"
  image              = "sles12sp4"

  use_os_released_updates = true
  ssh_key_path            = "./salt/controller/id_rsa.pub"
  gpg_keys                = ["default/gpg_keys/galaxy.key"]

  mac = lookup(local.macs, "minssh-sles12sp4", null)
}

module "min-centos7" {
  source = "../libvirt/minion"

  quantity = contains(var.optional_clients, "min-centos7") ? 1 : 0

  base_configuration = module.base.configuration
  product_version    = var.product_version
  name               = "min-centos7"
  image              = "centos7"

  server_configuration   = local.minimal_configuration
  auto_connect_to_master = false
  ssh_key_path           = "./salt/controller/id_rsa.pub"


  mac = lookup(local.macs, "min-centos7", null)
}

module "min-ubuntu1804" {
  source = "../libvirt/minion"

  quantity = contains(var.optional_clients, "min-ubuntu1804") ? 1 : 0

  base_configuration     = module.base.configuration
  product_version        = var.product_version
  name                   = "min-ubuntu1804"
  image                  = "ubuntu1804"
  server_configuration   = local.minimal_configuration
  auto_connect_to_master = false
  ssh_key_path           = "./salt/controller/id_rsa.pub"

  mac = lookup(local.macs, "min-ubuntu1804", null)
}

module "min-pxeboot" {
  source = "../libvirt/pxe_boot"

  quantity = contains(var.optional_clients, "min-pxeboot") ? 1 : 0

  base_configuration = module.base.configuration
  name               = "min-pxeboot"
  image              = "sles12sp3"
}

module "min-kvm" {
  source = "../libvirt/virthost"

  quantity = contains(var.optional_clients, "min-kvm") ? 1 : 0

  base_configuration   = module.base.configuration
  product_version      = var.product_version
  name                 = "min-kvm"
  image                = "sles15sp1"
  ssh_key_path         = "./salt/controller/id_rsa.pub"
  server_configuration = local.minimal_configuration

  auto_connect_to_master = false

  mac = lookup(local.macs, "min-kvm", null)
}

module "ctl" {
  source = "../libvirt/controller"
  name   = "ctl"

  base_configuration      = module.base.configuration
  server_configuration    = module.srv.configuration
  client_configuration    = module.cli-sles12sp4.configuration
  minion_configuration    = module.min-sles12sp4.configuration
  centos_configuration    = contains(var.optional_clients, "min-centos7") ? module.min-centos7.configuration : {hostname = "null", ids=null}
  ubuntu_configuration    = contains(var.optional_clients, "min-ubuntu1804") ? module.min-ubuntu1804.configuration : {hostname = "null", ids=null}
  minionssh_configuration = contains(var.optional_clients, "min-minssh-sles12sp4") ? module.minssh-sles12sp4.configuration : {hostname = "null", ids=null}
  pxeboot_configuration   = contains(var.optional_clients, "min-pxeboot") ? module.min-pxeboot.configuration : {hostname = "null",ids=null}
  kvmhost_configuration   = contains(var.optional_clients, "min-kvm") ? module.min-kvm.configuration : {hostname = "null",ids=null}

  git_username      = var.git_username
  git_password      = var.git_password
  server_http_proxy = var.server_http_proxy

  mac    = lookup(local.macs, "ctl", null)
  memory = 4096
  vcpu   = 4
}
