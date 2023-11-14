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
    macaddr = null
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

variable "sle11sp4_minion_configuration" {
  description = "use module.<SLE11SP4_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle11sp4_sshminion_configuration" {
  description = "use module.<SLE11SP4_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle11sp4_client_configuration" {
  description = "use module.<SLE11SP4_CLIENT>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle12sp4_minion_configuration" {
  description = "use module.<SLE12SP4_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle12sp4_sshminion_configuration" {
  description = "use module.<SLE12SP4_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle12sp4_client_configuration" {
  description = "use module.<SLE12SP4_CLIENT>.configuration, see main.tf.libvirt-testsuite.example"
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

variable "sle15_minion_configuration" {
  description = "use module.<SLE15_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle15_sshminion_configuration" {
  description = "use module.<SLE15_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle15_client_configuration" {
  description = "use module.<SLE15_CLIENT>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle15sp1_minion_configuration" {
  description = "use module.<SLE15SP1_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle15sp1_sshminion_configuration" {
  description = "use module.<SLE15SP1_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle15sp1_client_configuration" {
  description = "use module.<SLE15SP1_CLIENT>.configuration, see main.tf.libvirt-testsuite.example"
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

variable "debian10_minion_configuration" {
  description = "use module.<DEBIAN10_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "debian10_sshminion_configuration" {
  description = "use module.<DEBIAN10_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
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
    macaddr = null
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
    macaddr = null
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
    macaddr = null
    image = null
  }
}

variable "sle11sp4_buildhost_configuration" {
  description = "use module.<SLE11SP4_BUILDHOST>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle11sp3_terminal_configuration" {
  description = "use module.<SLE11SP3_TERMINAL>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    macaddr = null
    image = null
  }
}

variable "opensuse154arm_minion_configuration" {
  description = "use module.<OPENSUSE154ARM_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "opensuse154arm_sshminion_configuration" {
  description = "use module.<OPENSUSE154ARM_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
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

variable "is_using_build_image" {
description = "Specify to controller that server image is a build image"
default     = false
}

variable "is_using_scc_repositories" {
  description = "Specify to controller that server and proxy are using SCC repository and not internal repositories"
  default     = false
}

variable "nested_vm_host" {
  description = "Hostname for a nested VM if it is used, see README_TESTING.md"
  type        = string
  default     = "min-nested"
}

variable "nested_vm_mac" {
  description = "MAC address for a nested VM if it is used, see README_TESTING.md"
  type        = string
  default     = ""
}
