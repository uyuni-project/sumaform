variable "testsuite-branch" {
  default = {
    "4.0-released"   = "Manager-4.0"
    "4.0-nightly"    = "Manager-4.0"
    "4.1-released"   = "Manager-4.1"
    "4.1-nightly"    = "Manager-4.1"
    "4.2-released"   = "Manager-4.2"
    "4.2-nightly"    = "Manager-4.2"
    "4.3-released"   = "Manager-4.3"
    "4.3-nightly"    = "Manager-4.3"
    "4.4-released"   = "Manager-4.4
    "4.4-nightly"    = "Manager-4.4
    "4.4-beta"       = "master
    "head"           = "master"
    "uyuni-master"   = "master"
    "uyuni-released" = "master"
    "uyuni-pr"       = "master"
  }
}

module "controller" {
  source = "../host"

  base_configuration            = var.base_configuration
  name                          = var.name
  additional_repos              = var.additional_repos
  additional_repos_only         = var.additional_repos_only
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
    mirror       = var.no_mirror == true ? null :  var.base_configuration["mirror"]

    server        = var.server_configuration["hostname"]
    proxy         = var.proxy_configuration["hostname"]
    client        = length(var.client_configuration["hostnames"]) > 0 ? var.client_configuration["hostnames"][0] : null
    minion        = length(var.minion_configuration["hostnames"]) > 0 ? var.minion_configuration["hostnames"][0] : null
    build_host    = length(var.buildhost_configuration["hostnames"]) > 0 ? var.buildhost_configuration["hostnames"][0] : null
    redhat_minion = length(var.redhat_configuration["hostnames"]) > 0 ? var.redhat_configuration["hostnames"][0] : null
    debian_minion = length(var.debian_configuration["hostnames"]) > 0 ? var.debian_configuration["hostnames"][0] : null
    ssh_minion    = length(var.sshminion_configuration["hostnames"]) > 0 ? var.sshminion_configuration["hostnames"][0] : null
    pxeboot_mac   = var.pxeboot_configuration["macaddr"]
    kvm_host      = length(var.kvmhost_configuration["hostnames"]) > 0 ? var.kvmhost_configuration["hostnames"][0] : null
    xen_host      = length(var.xenhost_configuration["hostnames"]) > 0 ? var.xenhost_configuration["hostnames"][0] : null

    git_profiles_repo        = var.git_profiles_repo == "default" ? "https://github.com/uyuni-project/uyuni.git#:testsuite/features/profiles" : var.git_profiles_repo
    no_auth_registry         = var.no_auth_registry
    auth_registry            = var.auth_registry
    auth_registry_username   = var.auth_registry_username
    auth_registry_password   = var.auth_registry_password
    server_http_proxy        = var.server_http_proxy
    custom_download_endpoint = var.custom_download_endpoint
    pxeboot_image            = var.pxeboot_configuration["image"]
    is_using_build_image     = var.is_using_build_image

    sle11sp4_minion      = length(var.sle11sp4_minion_configuration["hostnames"]) > 0 ? var.sle11sp4_minion_configuration["hostnames"][0] : null
    sle11sp4_sshminion   = length(var.sle11sp4_sshminion_configuration["hostnames"]) > 0 ? var.sle11sp4_sshminion_configuration["hostnames"][0] : null
    sle11sp4_client      = length(var.sle11sp4_client_configuration["hostnames"]) > 0 ? var.sle11sp4_client_configuration["hostnames"][0] : null
    sle12sp4_minion      = length(var.sle12sp4_minion_configuration["hostnames"]) > 0 ? var.sle12sp4_minion_configuration["hostnames"][0] : null
    sle12sp4_sshminion   = length(var.sle12sp4_sshminion_configuration["hostnames"]) > 0 ? var.sle12sp4_sshminion_configuration["hostnames"][0] : null
    sle12sp4_client      = length(var.sle12sp4_client_configuration["hostnames"]) > 0 ? var.sle12sp4_client_configuration["hostnames"][0] : null
    sle12sp5_minion      = length(var.sle12sp5_minion_configuration["hostnames"]) > 0 ? var.sle12sp5_minion_configuration["hostnames"][0] : null
    sle12sp5_sshminion   = length(var.sle12sp5_sshminion_configuration["hostnames"]) > 0 ? var.sle12sp5_sshminion_configuration["hostnames"][0] : null
    sle12sp5_client      = length(var.sle12sp5_client_configuration["hostnames"]) > 0 ? var.sle12sp5_client_configuration["hostnames"][0] : null
    sle15_minion         = length(var.sle15_minion_configuration["hostnames"]) > 0 ? var.sle15_minion_configuration["hostnames"][0] : null
    sle15_sshminion      = length(var.sle15_sshminion_configuration["hostnames"]) > 0 ? var.sle15_sshminion_configuration["hostnames"][0] : null
    sle15_client         = length(var.sle15_client_configuration["hostnames"]) > 0 ? var.sle15_client_configuration["hostnames"][0] : null
    sle15sp1_minion      = length(var.sle15sp1_minion_configuration["hostnames"]) > 0 ? var.sle15sp1_minion_configuration["hostnames"][0] : null
    sle15sp1_sshminion   = length(var.sle15sp1_sshminion_configuration["hostnames"]) > 0 ? var.sle15sp1_sshminion_configuration["hostnames"][0] : null
    sle15sp1_client      = length(var.sle15sp1_client_configuration["hostnames"]) > 0 ? var.sle15sp1_client_configuration["hostnames"][0] : null
    sle15sp2_minion      = length(var.sle15sp2_minion_configuration["hostnames"]) > 0 ? var.sle15sp2_minion_configuration["hostnames"][0] : null
    sle15sp2_sshminion   = length(var.sle15sp2_sshminion_configuration["hostnames"]) > 0 ? var.sle15sp2_sshminion_configuration["hostnames"][0] : null
    sle15sp2_client      = length(var.sle15sp2_client_configuration["hostnames"]) > 0 ? var.sle15sp2_client_configuration["hostnames"][0] : null
    sle15sp3_minion      = length(var.sle15sp3_minion_configuration["hostnames"]) > 0 ? var.sle15sp3_minion_configuration["hostnames"][0] : null
    sle15sp3_sshminion   = length(var.sle15sp3_sshminion_configuration["hostnames"]) > 0 ? var.sle15sp3_sshminion_configuration["hostnames"][0] : null
    sle15sp3_client      = length(var.sle15sp3_client_configuration["hostnames"]) > 0 ? var.sle15sp3_client_configuration["hostnames"][0] : null
    sle15sp4_minion      = length(var.sle15sp4_minion_configuration["hostnames"]) > 0 ? var.sle15sp4_minion_configuration["hostnames"][0] : null
    sle15sp4_sshminion   = length(var.sle15sp4_sshminion_configuration["hostnames"]) > 0 ? var.sle15sp4_sshminion_configuration["hostnames"][0] : null
    slemicro52_minion    = length(var.slemicro52_minion_configuration["hostnames"]) > 0 ? var.slemicro52_minion_configuration["hostnames"][0] : null
    slemicro52_sshminion = length(var.slemicro52_sshminion_configuration["hostnames"]) > 0 ? var.slemicro52_sshminion_configuration["hostnames"][0] : null
    sle15sp4_client      = length(var.sle15sp4_client_configuration["hostnames"]) > 0 ? var.sle15sp4_client_configuration["hostnames"][0] : null
    centos6_minion       = length(var.centos6_minion_configuration["hostnames"]) > 0 ? var.centos6_minion_configuration["hostnames"][0] : null
    centos6_sshminion    = length(var.centos6_sshminion_configuration["hostnames"]) > 0 ? var.centos6_sshminion_configuration["hostnames"][0] : null
    centos6_client       = length(var.centos6_client_configuration["hostnames"]) > 0 ? var.centos6_client_configuration["hostnames"][0] : null
    centos7_minion       = length(var.centos7_minion_configuration["hostnames"]) > 0 ? var.centos7_minion_configuration["hostnames"][0] : null
    centos7_sshminion    = length(var.centos7_sshminion_configuration["hostnames"]) > 0 ? var.centos7_sshminion_configuration["hostnames"][0] : null
    centos7_client       = length(var.centos7_client_configuration["hostnames"]) > 0 ? var.centos7_client_configuration["hostnames"][0] : null
    rocky8_minion       = length(var.rocky8_minion_configuration["hostnames"]) > 0 ? var.rocky8_minion_configuration["hostnames"][0] : null
    rocky8_sshminion    = length(var.rocky8_sshminion_configuration["hostnames"]) > 0 ? var.rocky8_sshminion_configuration["hostnames"][0] : null
    ubuntu1604_minion    = length(var.ubuntu1604_minion_configuration["hostnames"]) > 0 ? var.ubuntu1604_minion_configuration["hostnames"][0] : null
    ubuntu1604_sshminion = length(var.ubuntu1604_sshminion_configuration["hostnames"]) > 0 ? var.ubuntu1604_sshminion_configuration["hostnames"][0] : null
    ubuntu1804_minion    = length(var.ubuntu1804_minion_configuration["hostnames"]) > 0 ? var.ubuntu1804_minion_configuration["hostnames"][0] : null
    ubuntu1804_sshminion = length(var.ubuntu1804_sshminion_configuration["hostnames"]) > 0 ? var.ubuntu1804_sshminion_configuration["hostnames"][0] : null
    ubuntu2004_minion    = length(var.ubuntu2004_minion_configuration["hostnames"]) > 0 ? var.ubuntu2004_minion_configuration["hostnames"][0] : null
    ubuntu2004_sshminion = length(var.ubuntu2004_sshminion_configuration["hostnames"]) > 0 ? var.ubuntu2004_sshminion_configuration["hostnames"][0] : null
    ubuntu2204_minion    = length(var.ubuntu2204_minion_configuration["hostnames"]) > 0 ? var.ubuntu2204_minion_configuration["hostnames"][0] : null
    ubuntu2204_sshminion = length(var.ubuntu2204_sshminion_configuration["hostnames"]) > 0 ? var.ubuntu2204_sshminion_configuration["hostnames"][0] : null
    debian9_minion       = length(var.debian9_minion_configuration["hostnames"]) > 0 ? var.debian9_minion_configuration["hostnames"][0] : null
    debian9_sshminion    = length(var.debian9_sshminion_configuration["hostnames"]) > 0 ? var.debian9_sshminion_configuration["hostnames"][0] : null
    debian10_minion      = length(var.debian10_minion_configuration["hostnames"]) > 0 ? var.debian10_minion_configuration["hostnames"][0] : null
    debian10_sshminion   = length(var.debian10_sshminion_configuration["hostnames"]) > 0 ? var.debian10_sshminion_configuration["hostnames"][0] : null
    debian11_minion      = length(var.debian11_minion_configuration["hostnames"]) > 0 ? var.debian11_minion_configuration["hostnames"][0] : null
    debian11_sshminion   = length(var.debian11_sshminion_configuration["hostnames"]) > 0 ? var.debian11_sshminion_configuration["hostnames"][0] : null
    sle11sp4_buildhost    = length(var.sle11sp4_buildhost_configuration["hostnames"]) > 0 ? var.sle11sp4_buildhost_configuration["hostnames"][0] : null
    sle11sp3_terminal_mac = var.sle11sp3_terminal_configuration["macaddr"]
    sle12sp5_buildhost    = length(var.sle12sp5_buildhost_configuration["hostnames"]) > 0 ? var.sle12sp5_buildhost_configuration["hostnames"][0] : null
    sle12sp5_terminal_mac = var.sle12sp5_terminal_configuration["macaddr"]
    sle15sp3_buildhost    = length(var.sle15sp3_buildhost_configuration["hostnames"]) > 0 ? var.sle15sp3_buildhost_configuration["hostnames"][0] : null
    sle15sp3_terminal_mac = var.sle15sp3_terminal_configuration["macaddr"]
    sle15sp4_buildhost    = length(var.sle15sp4_buildhost_configuration["hostnames"]) > 0 ? var.sle15sp4_buildhost_configuration["hostnames"][0] : null
    sle15sp4_terminal_mac = var.sle15sp4_terminal_configuration["macaddr"]
    opensuse154arm_minion = length(var.opensuse154arm_minion_configuration["hostnames"]) > 0 ? var.opensuse154arm_minion_configuration["hostnames"][0] : null
  }


  image   = "opensuse154o"
  provider_settings = var.provider_settings
}

output "configuration" {
  value = {
    id       = length(module.controller.configuration["ids"]) > 0 ? module.controller.configuration["ids"][0] : null
    hostname = length(module.controller.configuration["hostnames"]) > 0 ? module.controller.configuration["hostnames"][0] : null
    branch   = var.branch == "default" ? var.testsuite-branch[var.server_configuration["product_version"]] : var.branch
  }
}
