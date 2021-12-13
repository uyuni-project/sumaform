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

variable "xenhost_configuration" {
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

variable "centos6_minion_configuration" {
  description = "use module.<CENTOS6_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "centos6_sshminion_configuration" {
  description = "use module.<CENTOS6_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "centos6_client_configuration" {
  description = "use module.<CENTOS6_CLIENT>.configuration, see main.tf.libvirt-testsuite.example"
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

variable "centos8_minion_configuration" {
  description = "use module.<CENTOS8_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "centos8_sshminion_configuration" {
  description = "use module.<CENTOS8_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "ubuntu1604_minion_configuration" {
  description = "use module.<UBUNTU1604_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "ubuntu1604_sshminion_configuration" {
  description = "use module.<UBUNTU1604_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "ubuntu1804_minion_configuration" {
  description = "use module.<UBUNTU1804_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "ubuntu1804_sshminion_configuration" {
  description = "use module.<UBUNTU1804_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
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

variable "debian9_minion_configuration" {
  description = "use module.<DEBIAN9_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "debian9_sshminion_configuration" {
  description = "use module.<DEBIAN9_SSHMINION>.configuration, see main.tf.libvirt-testsuite.example"
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

variable "sle15sp3_buildhost_configuration" {
  description = "use module.<SLE15SP3_BUILDHOST>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "sle15sp3_terminal_configuration" {
  description = "use module.<SLE15SP3_TERMINAL>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    macaddrs = []
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
    macaddrs = []
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
    macaddrs = []
  }
}

variable "opensuse153arm_minion_configuration" {
  description = "use module.<OPENSUSE153ARM_MINION>.configuration, see main.tf.libvirt-testsuite.example"
  default = {
    hostnames = []
  }
}

variable "additional_repos" {
  description = "extra repositories in the form {label = url}, see README_ADVANCED.md"
  default     = {}
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

variable "provider_settings" {
  description = "Map of provider-specific settings, see the backend-specific README file"
  default     = {}
}

variable "no_mirror" {
  description = "Ignore mirror even if base configuration has one set"
  default     = false
}
