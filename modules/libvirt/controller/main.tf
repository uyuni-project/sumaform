variable "testsuite-branch" {
  default = {
    "3.2-released"   = "Manager-3.2"
    "3.2-nightly"    = "Manager-3.2"
    "4.0-released"   = "Manager-4.0"
    "4.0-nightly"    = "Manager-4.0"
    "head"           = "master"
    "uyuni-master"   = "master"
    "uyuni-released" = "master"
  }
}

module "controller" {
  source = "../host"

  base_configuration            = var.base_configuration
  name                          = var.name
  additional_repos              = var.additional_repos
  additional_packages           = var.additional_packages
  swap_file_size                = var.swap_file_size
  ssh_key_path                  = var.ssh_key_path
  ipv6                          = var.ipv6
  connect_to_base_network       = true
  connect_to_additional_network = false
  roles                         = ["controller"]
  grains = {
    cc_username  = var.base_configuration["cc_username"]
    cc_password  = var.base_configuration["cc_password"]
    git_username = var.git_username
    git_password = var.git_password
    git_repo     = var.git_repo
    branch       = var.branch == "default" ? var.testsuite-branch[var.server_configuration["product_version"]] : var.branch
    mirror       = var.base_configuration["mirror"]

    server        = var.server_configuration["hostname"]
    proxy         = var.proxy_configuration["hostname"]
    client        = length(var.client_configuration["hostnames"]) > 0 ? var.client_configuration["hostnames"][0] : null
    minion        = length(var.minion_configuration["hostnames"]) > 0 ? var.minion_configuration["hostnames"][0] : null
    centos_minion = length(var.centos_configuration["hostnames"]) > 0 ? var.centos_configuration["hostnames"][0] : null
    ubuntu_minion = length(var.ubuntu_configuration["hostnames"]) > 0 ? var.ubuntu_configuration["hostnames"][0] : null
    ssh_minion    = length(var.sshminion_configuration["hostnames"]) > 0 ? var.sshminion_configuration["hostnames"][0] : null
    kvm_host      = length(var.kvmhost_configuration["hostnames"]) > 0 ? var.kvmhost_configuration["hostnames"][0] : null
    pxeboot_mac   = var.pxeboot_configuration["macaddr"]

    git_profiles_repo = var.git_profiles_repo == "default" ? "https://github.com/uyuni-project/uyuni.git#:testsuite/features/profiles" : var.git_profiles_repo
    portus_uri        = var.portus_uri
    portus_username   = var.portus_username
    portus_password   = var.portus_password
    server_http_proxy = var.server_http_proxy

    sle11sp4_minion      = length(var.sle11sp4_minion_configuration["hostnames"]) > 0 ? var.sle11sp4_minion_configuration["hostnames"][0] : null
    sle11sp4_sshminion   = length(var.sle11sp4_sshminion_configuration["hostnames"]) > 0 ? var.sle11sp4_sshminion_configuration["hostnames"][0] : null
    sle11sp4_client      = length(var.sle11sp4_client_configuration["hostnames"]) > 0 ? var.sle11sp4_client_configuration["hostnames"][0] : null
    sle12sp4_minion      = length(var.sle12sp4_minion_configuration["hostnames"]) > 0 ? var.sle12sp4_minion_configuration["hostnames"][0] : null
    sle12sp4_sshminion   = length(var.sle12sp4_sshminion_configuration["hostnames"]) > 0 ? var.sle12sp4_sshminion_configuration["hostnames"][0] : null
    sle12sp4_client      = length(var.sle12sp4_client_configuration["hostnames"]) > 0 ? var.sle12sp4_client_configuration["hostnames"][0] : null
    sle15_minion         = length(var.sle15_minion_configuration["hostnames"]) > 0 ? var.sle15_minion_configuration["hostnames"][0] : null
    sle15_sshminion      = length(var.sle15_sshminion_configuration["hostnames"]) > 0 ? var.sle15_sshminion_configuration["hostnames"][0] : null
    sle15_client         = length(var.sle15_client_configuration["hostnames"]) > 0 ? var.sle15_client_configuration["hostnames"][0] : null
    sle15sp1_minion      = length(var.sle15sp1_minion_configuration["hostnames"]) > 0 ? var.sle15sp1_minion_configuration["hostnames"][0] : null
    sle15sp1_sshminion   = length(var.sle15sp1_sshminion_configuration["hostnames"]) > 0 ? var.sle15sp1_sshminion_configuration["hostnames"][0] : null
    sle15sp1_client      = length(var.sle15sp1_client_configuration["hostnames"]) > 0 ? var.sle15sp1_client_configuration["hostnames"][0] : null
    centos6_minion       = length(var.centos6_minion_configuration["hostnames"]) > 0 ? var.centos6_minion_configuration["hostnames"][0] : null
    centos6_sshminion    = length(var.centos6_sshminion_configuration["hostnames"]) > 0 ? var.centos6_sshminion_configuration["hostnames"][0] : null
    centos6_client       = length(var.centos6_client_configuration["hostnames"]) > 0 ? var.centos6_client_configuration["hostnames"][0] : null
    centos7_minion       = length(var.centos7_minion_configuration["hostnames"]) > 0 ? var.centos7_minion_configuration["hostnames"][0] : null
    centos7_sshminion    = length(var.centos7_sshminion_configuration["hostnames"]) > 0 ? var.centos7_sshminion_configuration["hostnames"][0] : null
    centos7_client       = length(var.centos7_client_configuration["hostnames"]) > 0 ? var.centos7_client_configuration["hostnames"][0] : null
    ubuntu1604_minion    = length(var.ubuntu1604_minion_configuration["hostnames"]) > 0 ? var.ubuntu1604_minion_configuration["hostnames"][0] : null
    ubuntu1604_sshminion = length(var.ubuntu1604_sshminion_configuration["hostnames"]) > 0 ? var.ubuntu1604_sshminion_configuration["hostnames"][0] : null
    ubuntu1804_minion    = length(var.ubuntu1804_minion_configuration["hostnames"]) > 0 ? var.ubuntu1804_minion_configuration["hostnames"][0] : null
    ubuntu1804_sshminion = length(var.ubuntu1804_sshminion_configuration["hostnames"]) > 0 ? var.ubuntu1804_sshminion_configuration["hostnames"][0] : null
  }


  // Provider-specific variables
  image   = "opensuse150"
  vcpu    = var.vcpu
  memory  = var.memory
  running = var.running
  mac     = var.mac
}
