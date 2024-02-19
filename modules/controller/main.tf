variable "testsuite-branch" {
  default = {
    "4.2-released"   = "Manager-4.2"
    "4.2-nightly"    = "Manager-4.2"
    "4.3-released"   = "Manager-4.3"
    "4.3-nightly"    = "Manager-4.3"
    "4.3-pr"         = "Manager-4.3"
    "4.3-VM-released"= "Manager-4.3"
    "4.3-VM-nightly"         = "Manager-4.3"
    "4.3-beta"       = "master"
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

    server            = var.server_configuration["hostname"]
    proxy             = var.proxy_configuration["hostname"]
    client            = length(var.client_configuration["hostnames"]) > 0 ? var.client_configuration["hostnames"][0] : null
    minion            = length(var.minion_configuration["hostnames"]) > 0 ? var.minion_configuration["hostnames"][0] : null
    build_host        = length(var.buildhost_configuration["hostnames"]) > 0 ? var.buildhost_configuration["hostnames"][0] : null
    redhat_minion     = length(var.redhat_configuration["hostnames"]) > 0 ? var.redhat_configuration["hostnames"][0] : null
    debian_minion     = length(var.debian_configuration["hostnames"]) > 0 ? var.debian_configuration["hostnames"][0] : null
    ssh_minion        = length(var.sshminion_configuration["hostnames"]) > 0 ? var.sshminion_configuration["hostnames"][0] : null
    pxeboot_mac       = var.pxeboot_configuration["macaddr"]
    kvm_host          = length(var.kvmhost_configuration["hostnames"]) > 0 ? var.kvmhost_configuration["hostnames"][0] : null
    monitoring_server = length(var.monitoringserver_configuration["hostnames"]) > 0 ? var.monitoringserver_configuration["hostnames"][0] : null

    git_profiles_repo         = var.git_profiles_repo == "default" ? "https://github.com/uyuni-project/uyuni.git#:testsuite/features/profiles" : var.git_profiles_repo
    no_auth_registry          = var.no_auth_registry
    auth_registry             = var.auth_registry
    auth_registry_username    = var.auth_registry_username
    auth_registry_password    = var.auth_registry_password
    server_http_proxy         = var.server_http_proxy
    custom_download_endpoint  = var.custom_download_endpoint
    pxeboot_image             = var.pxeboot_configuration["image"]
    is_using_paygo_server     = var.is_using_paygo_server
    is_using_build_image      = var.is_using_build_image
    is_using_scc_repositories = var.is_using_scc_repositories
    server_instance_id        = var.server_instance_id
    container_runtime         = lookup(var.server_configuration, "runtime", null)
    catch_timeout_message     = var.catch_timeout_message

    sle12sp5_paygo_minion    = length(var.sle12sp5_paygo_minion_configuration["hostnames"]) > 0 ? var.sle12sp5_paygo_minion_configuration["hostnames"][0] : null
    sle15sp5_paygo_minion    = length(var.sle15sp5_paygo_minion_configuration["hostnames"]) > 0 ? var.sle15sp5_paygo_minion_configuration["hostnames"][0] : null
    sleforsap15sp5_paygo_minion = length(var.sleforsap15sp5_paygo_minion_configuration["hostnames"]) > 0 ? var.sleforsap15sp5_paygo_minion_configuration["hostnames"][0] : null
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
    sle15sp4_client      = length(var.sle15sp4_client_configuration["hostnames"]) > 0 ? var.sle15sp4_client_configuration["hostnames"][0] : null
    sle15sp4_minion      = length(var.sle15sp4_minion_configuration["hostnames"]) > 0 ? var.sle15sp4_minion_configuration["hostnames"][0] : null
    sle15sp4_sshminion   = length(var.sle15sp4_sshminion_configuration["hostnames"]) > 0 ? var.sle15sp4_sshminion_configuration["hostnames"][0] : null
    sle15sp4_byos_minion = length(var.sle15sp4_byos_minion_configuration["hostnames"]) > 0 ? var.sle15sp4_byos_minion_configuration["hostnames"][0] : null
    sle15sp5_client      = length(var.sle15sp5_client_configuration["hostnames"]) > 0 ? var.sle15sp5_client_configuration["hostnames"][0] : null
    sle15sp5_minion      = length(var.sle15sp5_minion_configuration["hostnames"]) > 0 ? var.sle15sp5_minion_configuration["hostnames"][0] : null
    sle15sp5_sshminion   = length(var.sle15sp5_sshminion_configuration["hostnames"]) > 0 ? var.sle15sp5_sshminion_configuration["hostnames"][0] : null
    slemicro51_minion    = length(var.slemicro51_minion_configuration["hostnames"]) > 0 ? var.slemicro51_minion_configuration["hostnames"][0] : null
    slemicro51_sshminion = length(var.slemicro51_sshminion_configuration["hostnames"]) > 0 ? var.slemicro51_sshminion_configuration["hostnames"][0] : null
    slemicro52_minion    = length(var.slemicro52_minion_configuration["hostnames"]) > 0 ? var.slemicro52_minion_configuration["hostnames"][0] : null
    slemicro52_sshminion = length(var.slemicro52_sshminion_configuration["hostnames"]) > 0 ? var.slemicro52_sshminion_configuration["hostnames"][0] : null
    slemicro53_minion    = length(var.slemicro53_minion_configuration["hostnames"]) > 0 ? var.slemicro53_minion_configuration["hostnames"][0] : null
    slemicro53_sshminion = length(var.slemicro53_sshminion_configuration["hostnames"]) > 0 ? var.slemicro53_sshminion_configuration["hostnames"][0] : null
    slemicro54_minion    = length(var.slemicro54_minion_configuration["hostnames"]) > 0 ? var.slemicro54_minion_configuration["hostnames"][0] : null
    slemicro54_sshminion = length(var.slemicro54_sshminion_configuration["hostnames"]) > 0 ? var.slemicro54_sshminion_configuration["hostnames"][0] : null
    slemicro55_minion    = length(var.slemicro55_minion_configuration["hostnames"]) > 0 ? var.slemicro55_minion_configuration["hostnames"][0] : null
    slemicro55_sshminion = length(var.slemicro55_sshminion_configuration["hostnames"]) > 0 ? var.slemicro55_sshminion_configuration["hostnames"][0] : null
    centos7_minion       = length(var.centos7_minion_configuration["hostnames"]) > 0 ? var.centos7_minion_configuration["hostnames"][0] : null
    centos7_sshminion    = length(var.centos7_sshminion_configuration["hostnames"]) > 0 ? var.centos7_sshminion_configuration["hostnames"][0] : null
    centos7_client       = length(var.centos7_client_configuration["hostnames"]) > 0 ? var.centos7_client_configuration["hostnames"][0] : null
    alma8_minion         = length(var.alma8_minion_configuration["hostnames"]) > 0 ? var.alma8_minion_configuration["hostnames"][0] : null
    alma8_sshminion      = length(var.alma8_sshminion_configuration["hostnames"]) > 0 ? var.alma8_sshminion_configuration["hostnames"][0] : null
    alma9_minion         = length(var.alma9_minion_configuration["hostnames"]) > 0 ? var.alma9_minion_configuration["hostnames"][0] : null
    alma9_sshminion      = length(var.alma9_sshminion_configuration["hostnames"]) > 0 ? var.alma9_sshminion_configuration["hostnames"][0] : null
    liberty9_minion      = length(var.liberty9_minion_configuration["hostnames"]) > 0 ? var.liberty9_minion_configuration["hostnames"][0] : null
    liberty9_sshminion   = length(var.liberty9_sshminion_configuration["hostnames"]) > 0 ? var.liberty9_sshminion_configuration["hostnames"][0] : null
    oracle9_minion       = length(var.oracle9_minion_configuration["hostnames"]) > 0 ? var.oracle9_minion_configuration["hostnames"][0] : null
    oracle9_sshminion    = length(var.oracle9_sshminion_configuration["hostnames"]) > 0 ? var.oracle9_sshminion_configuration["hostnames"][0] : null
    rhel9_minion         = length(var.rhel9_minion_configuration["hostnames"]) > 0 ? var.rhel9_minion_configuration["hostnames"][0] : null
    rhel9_sshminion      = length(var.rhel9_sshminion_configuration["hostnames"]) > 0 ? var.rhel9_sshminion_configuration["hostnames"][0] : null
    rocky8_minion        = length(var.rocky8_minion_configuration["hostnames"]) > 0 ? var.rocky8_minion_configuration["hostnames"][0] : null
    rocky8_sshminion     = length(var.rocky8_sshminion_configuration["hostnames"]) > 0 ? var.rocky8_sshminion_configuration["hostnames"][0] : null
    rocky9_minion        = length(var.rocky9_minion_configuration["hostnames"]) > 0 ? var.rocky9_minion_configuration["hostnames"][0] : null
    rocky9_sshminion     = length(var.rocky9_sshminion_configuration["hostnames"]) > 0 ? var.rocky9_sshminion_configuration["hostnames"][0] : null
    ubuntu2004_minion    = length(var.ubuntu2004_minion_configuration["hostnames"]) > 0 ? var.ubuntu2004_minion_configuration["hostnames"][0] : null
    ubuntu2004_sshminion = length(var.ubuntu2004_sshminion_configuration["hostnames"]) > 0 ? var.ubuntu2004_sshminion_configuration["hostnames"][0] : null
    ubuntu2204_minion    = length(var.ubuntu2204_minion_configuration["hostnames"]) > 0 ? var.ubuntu2204_minion_configuration["hostnames"][0] : null
    ubuntu2204_sshminion = length(var.ubuntu2204_sshminion_configuration["hostnames"]) > 0 ? var.ubuntu2204_sshminion_configuration["hostnames"][0] : null
    debian10_minion      = length(var.debian10_minion_configuration["hostnames"]) > 0 ? var.debian10_minion_configuration["hostnames"][0] : null
    debian10_sshminion   = length(var.debian10_sshminion_configuration["hostnames"]) > 0 ? var.debian10_sshminion_configuration["hostnames"][0] : null
    debian11_minion      = length(var.debian11_minion_configuration["hostnames"]) > 0 ? var.debian11_minion_configuration["hostnames"][0] : null
    debian11_sshminion   = length(var.debian11_sshminion_configuration["hostnames"]) > 0 ? var.debian11_sshminion_configuration["hostnames"][0] : null
    debian12_minion      = length(var.debian12_minion_configuration["hostnames"]) > 0 ? var.debian12_minion_configuration["hostnames"][0] : null
    debian12_sshminion   = length(var.debian12_sshminion_configuration["hostnames"]) > 0 ? var.debian12_sshminion_configuration["hostnames"][0] : null
    sle11sp4_buildhost    = length(var.sle11sp4_buildhost_configuration["hostnames"]) > 0 ? var.sle11sp4_buildhost_configuration["hostnames"][0] : null
    sle11sp3_terminal_mac = var.sle11sp3_terminal_configuration["macaddr"]
    sle12sp5_buildhost    = length(var.sle12sp5_buildhost_configuration["hostnames"]) > 0 ? var.sle12sp5_buildhost_configuration["hostnames"][0] : null
    sle12sp5_terminal_mac = var.sle12sp5_terminal_configuration["macaddr"]
    sle15sp3_buildhost    = length(var.sle15sp3_buildhost_configuration["hostnames"]) > 0 ? var.sle15sp3_buildhost_configuration["hostnames"][0] : null
    sle15sp3_terminal_mac = var.sle15sp3_terminal_configuration["macaddr"]
    sle15sp4_buildhost    = length(var.sle15sp4_buildhost_configuration["hostnames"]) > 0 ? var.sle15sp4_buildhost_configuration["hostnames"][0] : null
    sle15sp4_terminal_mac = var.sle15sp4_terminal_configuration["macaddr"]
    opensuse154arm_minion    = length(var.opensuse154arm_minion_configuration["hostnames"]) > 0 ? var.opensuse154arm_minion_configuration["hostnames"][0] : null
    opensuse154arm_sshminion = length(var.opensuse154arm_sshminion_configuration["hostnames"]) > 0 ? var.opensuse154arm_sshminion_configuration["hostnames"][0] : null
    opensuse155arm_minion    = length(var.opensuse155arm_minion_configuration["hostnames"]) > 0 ? var.opensuse155arm_minion_configuration["hostnames"][0] : null
    opensuse155arm_sshminion = length(var.opensuse155arm_sshminion_configuration["hostnames"]) > 0 ? var.opensuse155arm_sshminion_configuration["hostnames"][0] : null
    sle15sp5s390_minion    = length(var.sle15sp5s390_minion_configuration["hostnames"]) > 0 ? var.sle15sp5s390_minion_configuration["hostnames"][0] : null
    sle15sp5s390_sshminion = length(var.sle15sp5s390_sshminion_configuration["hostnames"]) > 0 ? var.sle15sp5s390_sshminion_configuration["hostnames"][0] : null
    salt_migration_minion = length(var.salt_migration_minion_configuration["hostnames"]) > 0 ? var.salt_migration_minion_configuration["hostnames"][0] : null
  }

  image   = "opensuse155o"
  provider_settings = var.provider_settings
}

output "configuration" {
  value = {
    id       = length(module.controller.configuration["ids"]) > 0 ? module.controller.configuration["ids"][0] : null
    hostname = length(module.controller.configuration["hostnames"]) > 0 ? module.controller.configuration["hostnames"][0] : null
    branch   = var.branch == "default" ? var.testsuite-branch[var.server_configuration["product_version"]] : var.branch
  }
}
