variable "base_configuration" {
  description = "use module.base.configuration, see the main.tf example file"
}

variable "name" {
  description = "hostname, without the domain part"
  type        = string
}

variable "product_version" {
  description = "A valid SUSE Manager version (eg. 3.2-nightly, head) see README_ADVANCED.md"
  default     = "released"
}

variable "server_configuration" {
  description = "use module.<SERVER_NAME>.configuration, see the main.tf example file"
}

variable "activation_key" {
  description = "an Activation Key to be used when onboarding this minion"
  default     = null
}

variable "auto_connect_to_master" {
  description = "whether this minion should automatically connect to the Salt Master upon deployment"
  default     = true
}

variable "use_os_released_updates" {
  description = "Apply all updates from SUSE Linux Enterprise repos"
  default     = false
}

variable "use_os_unreleased_updates" {
  description = "Apply all updates from SUSE Linux Enterprise unreleased (Test) repos"
  default     = false
}

variable "additional_repos" {
  description = "extra repositories used for installation {label = url}"
  default     = {}
}

variable "additional_packages" {
  description = "extra packages which should be installed"
  default     = []
}

variable "ssh_key_path" {
  description = "path of additional pub ssh key you want to use to access VMs, see README_ADVANCED.md"
  default     = null
}

variable "quantity" {
  description = "number of hosts like this one"
  default     = 1
}

variable "gpg_keys" {
  description = "salt/ relative paths of gpg keys that you want to add to your VMs, see README_ADVANCED.md"
  default     = []
}

variable "ipv6" {
  description = "IPv6 tuning: enable it, accept the RAs"
  default = {
    enable    = true
    accept_ra = true
  }
}

variable "hvm_disk_image" {
  description = "URL to the disk image to use for KVM guests"
  default     = "https://download.opensuse.org/distribution/leap/15.3/appliances/openSUSE-Leap-15.3-JeOS.x86_64-OpenStack-Cloud.qcow2"
}

variable "hvm_disk_image_hash" {
  description = "Hash of the HVM disk image, either a URL or the hash itself. See salt's file.managed source_hash documentations"
  default     = "https://download.opensuse.org/distribution/leap/15.3/appliances/openSUSE-Leap-15.3-JeOS.x86_64-OpenStack-Cloud.qcow2.sha256"
}

variable "xen_disk_image" {
  description = "URL to the disk image to use for Xen PV guests"
  default     = "https://download.opensuse.org/distribution/leap/15.3/appliances/openSUSE-Leap-15.3-JeOS.x86_64-15.3-kvm-and-xen-Current.qcow2"
}

variable "xen_disk_image_hash" {
  description = "Hash of the Xen PV disk image, either a URL or the hash itself. See salt's file.managed source_hash documentations"
  default     = "https://download.opensuse.org/distribution/leap/15.3/appliances/openSUSE-Leap-15.3-JeOS.x86_64-15.3-kvm-and-xen-Current.qcow2.sha256"
}

variable "hypervisor" {
  description = "Hypervisor to use on the virtual host. Either kvm or xen"
  default     = "kvm"
}

variable "image" {
  description = "One of: sles15, sles15sp1, sles15sp2, sles15sp2o, sles15sp3o or opensuse152o"
  type        = string
}

variable "provider_settings" {
  description = "Map of provider-specific settings, see the backend-specific README file"
  default     = {}
}
