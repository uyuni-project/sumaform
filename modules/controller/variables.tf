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
  default     = 4096
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

variable "portus_uri" {
  description = "URI of portus server, see README_ADVANCED.md"
  default     = null
}

variable "portus_username" {
  description = "username on portus server, see README_ADVANCED.md"
  default     = null
}

variable "portus_password" {
  description = "password on portus server, see README_ADVANCED.md"
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
