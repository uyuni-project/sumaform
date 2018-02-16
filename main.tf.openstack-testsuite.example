provider "openstack" {
  version = "~> 1.2"

  user_name   = ...
  password    = ...

  // below are valid values to target the SUSE internal "ECP" Cloud
  // for the SUSE Manager project. Adapt as needed
  auth_url    = "https://engcloud.prv.suse.net:5000/v3"
  domain_name = "ldap_users"
  tenant_id   = "609ad0b07a414b40bd4884768bf6ac89"
}

module "base" {
  source = "./modules/openstack/base"

  cc_username = "UC7"
  cc_password = ...

  // optional parameters with defaults below
  // name_prefix = ""
  // timezone = "Europe/Berlin"

  // uncomment the following if you are targeting the SUSE internal "ECP" Cloud
  // mirror = "mirror.tf.local"
  // use_shared_resources = true
}

module "srv" {
  source = "./modules/openstack/suse_manager"
  base_configuration = "${module.base.configuration}"
  version = "3.1-nightly"
  name = "srv"
  image = "sles12sp3"
  for_development_only = false
  for_testsuite_only = true
  auto_accept = false
  ssh_key_path = "./salt/controller/id_rsa.pub"
}

module "cli-sles12sp3" {
  source = "./modules/openstack/client"
  base_configuration = "${module.base.configuration}"
  version = "3.1-nightly"
  name = "cli-sles12sp3"
  image = "sles12sp3"
  server_configuration = { hostname = "srv.tf.local" }
  for_development_only = false
  for_testsuite_only = true
  ssh_key_path = "./salt/controller/id_rsa.pub"
}

module "min-sles12sp3" {
  source = "./modules/openstack/minion"
  base_configuration = "${module.base.configuration}"
  version = "3.1-nightly"
  name = "min-sles12sp3"
  image = "sles12sp3"
  server_configuration = { hostname = "srv.tf.local" }
  for_development_only = false
  for_testsuite_only = true
  ssh_key_path = "./salt/controller/id_rsa.pub"
}

# optional
module "minssh-sles12sp3" {
  source = "./modules/openstack/host"
  base_configuration = "${module.base.configuration}"
  version = "3.1-nightly"
  name = "minssh-sles12sp3"
  image = "sles12sp3"
  ssh_key_path = "./salt/controller/id_rsa.pub"
  gpg_keys = ["default/gpg_keys/galaxy.key"]
}

# optional
module "min-centos7" {
  source = "./modules/openstack/minion"
  base_configuration = "${module.base.configuration}"
  version = "3.1-nightly"
  name = "min-centos7"
  image = "centos7"
  server_configuration = { hostname = "srv.tf.local" }
  for_development_only = false
  for_testsuite_only = true
  ssh_key_path = "./salt/controller/id_rsa.pub"
}

module "ctl" {
  source = "./modules/openstack/controller"
  base_configuration = "${module.base.configuration}"
  name = "ctl"
  server_configuration = "${module.srv.configuration}"
  client_configuration = "${module.cli-sles12sp3.configuration}"
  minion_configuration = "${module.min-sles12sp3.configuration}"
  centos_configuration = "${module.min-centos7.configuration}"         // optional
  minionssh_configuration = "${module.minssh-sles12sp3.configuration}" // optional
  branch = "default"
  git_username = "<YOUR_USERNAME>"
  git_password = "<YOUR_PASSWORD>"
}
