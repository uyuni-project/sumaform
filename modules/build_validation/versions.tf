terraform {
  required_version = ">= 1.6.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3"
      configuration_aliases = [
        libvirt.host_old_sle, # For SLES 12
        libvirt.host_new_sle, # For SLES 15/Micro
        libvirt.host_res,     # For Alma/Rocky/CentOS/Oracle
        libvirt.host_debian,  # For Ubuntu/Debian
        libvirt.host_retail,  # For Proxy/BuildHosts/Terminals
        libvirt.host_arm
      ]
    }
    feilong = {
      source  = "bischoff/feilong"
      version = "0.0.9"
    }
  }
}
