variable "base_configuration" {
  description = "use module.base.configuration, see the main.tf example file"
}

variable "name" {
  description = "hostname, without the domain part"
  type        = string
}

variable "git_username" {
  description = "username for GitHub"
  type        = string
}

variable "git_password" {
  description = "password for GitHub"
  type        = string
}

variable "git_repo" {
  description = "Git repo clone URL"
  default     = "default"
}

variable "branch" {
  description = "Leave default for automatic selection or specify an existing branch of spacewalk"
  default     = "default"
}

variable "server_configuration" {
  description = "use module.<SERVER_NAME>.configuration, see main.tf.libvirt-testsuite.example"
}

variable "proxy_configuration" {
  description = "use module.<PROXY_NAME>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostname = null
  }
}

variable "client_configuration" {
  description = "use module.<CLIENT_NAME>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    ids       = []
    hostnames = []
  }
}

variable "minion_configuration" {
  description = "use module.<MINION_NAME>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    ids       = []
    hostnames = []
  }
}

variable "slemicro_minion_configuration" {
  description = "use module.<SLE_MICRO_MINION_NAME>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    ids       = []
    hostnames = []
  }
}

variable "buildhost_configuration" {
  description = "use module.<BUILDHOST_NAME>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sshminion_configuration" {
  description = "use module.<SSHMINION_NAME>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "redhat_configuration" {
  description = "use module.<REDHAT_NAME>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "debian_configuration" {
  description = "use module.<DEBIAN_NAME>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "pxeboot_configuration" {
  description = "use module.<PXEBOOT_NAME>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    private_mac = null
    private_ip = null
    private_name = null
    image = null
  }
}

variable "kvmhost_configuration" {
  description = "use module.<VIRTHOST_NAME>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "monitoringserver_configuration" {
  description = "use module.<VIRTHOST_NAME>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle12sp5_paygo_minion_configuration" {
  description = "use module.<SLE12SP5_PAYGO_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle15sp4_byos_minion_configuration" {
  description = "use module.<SLE15SP4_BYOS_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle15sp5_paygo_minion_configuration" {
  description = "use module.<SLE15SP5_PAYGO_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle15sp6_paygo_minion_configuration" {
  description = "use module.<SLE15SP6_PAYGO_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sleforsap15sp5_paygo_minion_configuration" {
  description = "use module.<SLEFORSAP15SP5_PAYGO_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle12sp5_minion_configuration" {
  description = "use module.<SLE12SP5_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle12sp5_sshminion_configuration" {
  description = "use module.<SLE12SP5_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle12sp5_client_configuration" {
  description = "use module.<SLE12SP5_CLIENT>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle15sp2_minion_configuration" {
  description = "use module.<SLE15SP2_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle15sp2_sshminion_configuration" {
  description = "use module.<SLE15SP2_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle15sp2_client_configuration" {
  description = "use module.<SLE15SP2_CLIENT>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle15sp3_minion_configuration" {
  description = "use module.<SLE15SP3_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle15sp3_sshminion_configuration" {
  description = "use module.<SLE15SP3_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle15sp3_client_configuration" {
  description = "use module.<SLE15SP3_CLIENT>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle15sp4_minion_configuration" {
  description = "use module.<SLE15SP4_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle15sp4_sshminion_configuration" {
  description = "use module.<SLE15SP4_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle15sp4_client_configuration" {
  description = "use module.<SLE15SP4_CLIENT>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle15sp5_minion_configuration" {
  description = "use module.<SLE15SP5_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle15sp5_sshminion_configuration" {
  description = "use module.<SLE15SP5_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle15sp5_client_configuration" {
  description = "use module.<SLE15SP5_CLIENT>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle15sp6_minion_configuration" {
  description = "use module.<SLE15SP6_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle15sp6_sshminion_configuration" {
  description = "use module.<SLE15SP6_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle15sp6_client_configuration" {
  description = "use module.<SLE15SP6_CLIENT>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "slemicro51_minion_configuration" {
  description = "use module.<SLEMICRO51_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "slemicro51_sshminion_configuration" {
  description = "use module.<SLEMICRO51_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "slemicro52_minion_configuration" {
  description = "use module.<SLEMICRO52_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "slemicro52_sshminion_configuration" {
  description = "use module.<SLEMICRO52_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "slemicro53_minion_configuration" {
  description = "use module.<SLEMICRO53_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "slemicro53_sshminion_configuration" {
  description = "use module.<SLEMICRO53_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "slemicro54_minion_configuration" {
  description = "use module.<SLEMICRO54_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "slemicro54_sshminion_configuration" {
  description = "use module.<SLEMICRO54_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "slemicro55_minion_configuration" {
  description = "use module.<SLEMICRO55_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "slemicro55_sshminion_configuration" {
  description = "use module.<SLEMICRO55_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "slmicro60_minion_configuration" {
  description = "use module.<SLMICRO60_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "slmicro60_sshminion_configuration" {
  description = "use module.<SLMICRO60_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "centos7_minion_configuration" {
  description = "use module.<CENTOS7_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "centos7_sshminion_configuration" {
  description = "use module.<CENTOS7_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "centos7_client_configuration" {
  description = "use module.<CENTOS7_CLIENT>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "liberty9_minion_configuration" {
  description = "use module.<LIBERTY9_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "liberty9_sshminion_configuration" {
  description = "use module.<LIBERTY9_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "rocky8_minion_configuration" {
  description = "use module.<ROCKY8_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "rocky8_sshminion_configuration" {
  description = "use module.<ROCKY8_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "rocky9_minion_configuration" {
  description = "use module.<ROCKY9_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "rocky9_sshminion_configuration" {
  description = "use module.<ROCKY9_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "rhel9_minion_configuration" {
  description = "use module.<RHEL9_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "alma8_minion_configuration" {
  description = "use module.<ALMA8_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "alma8_sshminion_configuration" {
  description = "use module.<ALMA8_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "alma9_minion_configuration" {
  description = "use module.<ALMA9_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "alma9_sshminion_configuration" {
  description = "use module.<ALMA9_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "oracle9_minion_configuration" {
  description = "use module.<ORACLE9_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "oracle9_sshminion_configuration" {
  description = "use module.<ORACLE9_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "rhel9_sshminion_configuration" {
  description = "use module.<RHEL9_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "ubuntu2004_minion_configuration" {
  description = "use module.<UBUNTU2004_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "ubuntu2004_sshminion_configuration" {
  description = "use module.<UBUNTU2004_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "ubuntu2204_minion_configuration" {
  description = "use module.<UBUNTU2204_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "ubuntu2204_sshminion_configuration" {
  description = "use module.<UBUNTU2204_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "ubuntu2404_minion_configuration" {
  description = "use module.<UBUNTU2404_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "ubuntu2404_sshminion_configuration" {
  description = "use module.<UBUNTU2404_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "debian11_minion_configuration" {
  description = "use module.<DEBIAN11_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "debian11_sshminion_configuration" {
  description = "use module.<DEBIAN11_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "debian12_minion_configuration" {
  description = "use module.<DEBIAN12_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "debian12_sshminion_configuration" {
  description = "use module.<DEBIAN12_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle15sp4_buildhost_configuration" {
  description = "use module.<SLE15SP4_BUILDHOST>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle15sp4_terminal_configuration" {
  description = "use module.<SLE15SP4_TERMINAL>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    private_mac = null
    private_ip = null
    private_name = null
    image = null
  }
}

variable "sle15sp3_buildhost_configuration" {
  description = "use module.<SLE15SP3_BUILDHOST>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle15sp3_terminal_configuration" {
  description = "use module.<SLE15SP3_TERMINAL>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    private_mac = null
    private_ip = null
    private_name = null
    image = null
  }
}

variable "sle12sp5_buildhost_configuration" {
  description = "use module.<SLE12SP5_BUILDHOST>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle12sp5_terminal_configuration" {
  description = "use module.<SLE12SP5_TERMINAL>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    private_mac = null
    private_ip = null
    private_name = null
    image = null
  }
}

variable "opensuse155arm_minion_configuration" {
  description = "use module.<OPENSUSE155ARM_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "opensuse155arm_sshminion_configuration" {
  description = "use module.<OPENSUSE155ARM_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "opensuse156arm_minion_configuration" {
  description = "use module.<OPENSUSE156ARM_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "opensuse156arm_sshminion_configuration" {
  description = "use module.<OPENSUSE156ARM_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle15sp5s390_minion_configuration" {
  description = "use module.<SLE15SP5S390_MINION>.configuration"
  default = {
    hostnames = []
  }
}

variable "sle15sp5s390_sshminion_configuration" {
  description = "use module.<SLE15SP5S390_SSHMINION>.configuration"
  default = {
    hostnames = []
  }
}

variable "salt_migration_minion_configuration" {
  description = "use module.<SALT_MIGRATION_MINION>.configuration"
  default = {
    hostnames = []
  }
}

variable "additional_repos" {
  description = "extra repositories in the form {label = url}, see README_ADVANCED.md"
  default     = {}
}

variable "additional_repos_only" {
  description = "whether to exclusively use additional repos"
  default     = false
}

variable "additional_packages" {
  description = "extra packages to install, see README_ADVANCED.md"
  default     = []
}

variable "swap_file_size" {
  description = "Swap file size in MiB, or 0 for none"
  default     = 0
}

variable "ssh_key_path" {
  description = "path of additional pub ssh key you want to use to access VMs, see README_ADVANCED.md"
  default     = null
}

variable "ipv6" {
  description = "IPv6 tuning: enable it, accept the RAs"
  default = {
    enable    = true
    accept_ra = true
  }
}

variable "git_profiles_repo" {
  description = "URL of git repository with alternate Docker and Kiwi profiles, see README_ADVANCED.md"
  default     = "default"
}

variable "no_auth_registry" {
  description = "URI of container registry server, see README_ADVANCED.md"
  default     = null
}

variable "auth_registry" {
  description = "URI of authenticated registry, see README_ADVANCED.md"
  default     = null
}

variable "auth_registry_username" {
  description = "username on registry, see README_ADVANCED.md"
  default     = null
}

variable "auth_registry_password" {
  description = "password on registry, see README_ADVANCED.md"
  default     = null
}

variable "server_http_proxy" {
  description = "Hostname and port used by the server as the HTTP proxy to reach the outside network"
  default     = null
}

variable "custom_download_endpoint" {
  description = "URL (protocol, domain name and port) of custom download endpoint for packages"
  default     = null
}

variable "provider_settings" {
  description = "Map of provider-specific settings, see the backend-specific README file"
  default     = {}
}

variable "no_mirror" {
  description = "Ignore mirror even if base configuration has one set"
  default     = false
}

variable "catch_timeout_message" {
  description = "Enable the mechanism to catch the timeout message shown by a server overloaded"
  default     = false
}

variable "beta_enabled" {
  description = "Enable the mechanism to take into account beta channels"
  default     = false
}

variable "is_using_paygo_server" {
  description = "Specify to controller that server image is a paygo image"
  default     = false
}

variable "is_using_build_image" {
description = "Specify to controller that server image is a build image"
default     = false
}

variable "is_using_scc_repositories" {
  description = "Specify to controller that server and proxy are using SCC repository and not internal repositories"
  default     = false
}

variable "server_instance_id" {
  description = "Server instance ID"
  default     = null
}

variable "product_version" {
  description = "A valid SUSE Manager version (eg. 4.3-nightly, head) see README_ADVANCED.md"
  default     = "released"
}
