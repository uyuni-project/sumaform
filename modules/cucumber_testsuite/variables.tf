// base
variable "cc_username" {
  description = "username for the Customer Center"
  type        = string
  default     = null
}

variable "cc_password" {
  description = "password for the Customer Center"
  type        = string
  default     = null
}

variable "use_avahi" {
  description = "use false only if you use bridged networking with static MACs and an external DHCP"
  default     = true
}

variable "avahi_reflector" {
  description = "if using avahi, allow one minion to have a reflector configured"
  default     = false
}

variable "ssh_key_path" {
  description = "path of pub ssh key you want to use to access VMs, see backend_modules/libvirt/README.md"
  default     = "~/.ssh/id_ed25519.pub"
}

variable "domain" {
  description = "domain of all hosts in this testsuite"
  default     = "tf.local"
}

variable "name_prefix" {
  description = "a prefix for all names of objects created by this testsuite to avoid collisions. E.g. moio-"
  default     = ""
}

variable "images" {
  description = "list of images to be uploaded to the libvirt host, leave default for all"
  default     = ["centos7o", "opensuse156o", "opensuse160o", "slemicro55o", "slmicro60o", "slmicro61o", "slmicro62o", "rocky8o", "rocky9o", "sles12sp5o", "sles15sp3o", "sles15sp4o", "sles15sp5o", "sles15sp6o", "sles15sp7o", "ubuntu2204o", "ubuntu2404o", "suma43VM-ign"]
}

variable "main_disk_size" {
  description = "Size of main disk, defined in GiB"
  default     = 200
}

variable "repository_disk_size" {
  description = "Size of an additional disk for /var/spacewalk partition, defined in GiB"
  default     = 0
}

variable "database_disk_size" {
  description = "Size of an additional disk for /var/lib/pgsql partition, defined in GiB"
  default     = 0
}

variable "mirror" {
  description = "hostname of the mirror host or leave the default for no mirror"
  default     = null
}

variable "use_mirror_images" {
  description = "use true download images from a mirror host"
  default     = false
}

variable "use_shared_resources" {
  description = "use true to avoid deploying images, mirrors and other shared infrastructure resources"
  default     = false
}

// cucumber_testsuite
variable "host_settings" {
  description = "Hosts and their specific properties, see README_TESTING.md"
  default = {
    suse-client = {
    }
    suse-minion = {
    }
  }
}

// server
variable "product_version" {
  description = "One of: head, head-staging, uyuni-master, uyuni-main, uyuni-released, uyuni-pr"
  type        = string
  default     = null
}

variable "from_email" {
  description = "email address used as sender for emails"
  default     = null
}

// controller
variable "branch" {
  description = "Leave default for automatic selection or specify an existing branch of spacewalk"
  default     = "default"
}

variable "cc_ptf_username" {
  description = "username of SCC organization having PTFs available"
  type        = string
  default     = null
} 

variable "cc_ptf_password" {
  description = "password of SCC organization having PTFs available"
  type        = string
  default     = null
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
  description = "Git repo clone URL for testsuite code"
  default     = "default"
}

variable "git_profiles_repo" {
  description = "URL of git repository with alternate Docker and Kiwi profiles, see README_TESTING.md"
  default     = "default"
}

variable "no_auth_registry" {
  description = "URI of container registry server, see README_TESTING.md"
  default     = null
}

variable "auth_registry" {
  description = "URI of authenticated registry, see README_TESTING.md"
  default     = null
}

variable "auth_registry_username" {
  description = "username on registry, see README_TESTING.md"
  default     = null
}

variable "auth_registry_password" {
  description = "password on registry, see README_TESTING.md"
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

variable "saltapi_tcpdump" {
  description = "If set to true, all network operations of salt-api on the Server are logged to /tmp/ with tcpdump."
  default     = false
}

// provider
variable "provider_settings" {
  description = "Settings specific to the provider, see README_TESTING.md"
  default     = {}
}

variable "login_timeout" {
  description = "How long the webUI login session cookie is valid"
  default     = null
}

variable "container_server" {
  description = "true to run the server in containers"
  default = false
}

variable "container_proxy" {
  description = "true to run the proxy in containers"
  default = false
}

variable "kubernetes" {
  description = "true to run the server and the proxy on kubernetes"
  default = false
}

variable "use_devel_oci" {
  description = "true to use devel OCIs"
  default = false
}

variable "java_debugging_on_rke2" {
  description = "Enable Java debugging on RKE2"
  default     = false
}

variable "install_mlm_server" {
  description = "true to just install the RKE2 MLM server"
  default = true
}

variable "install_mlm_proxy" {
  description = "true to just install the RKE2 MLM proxy"
  default = true
}

variable "install_traefik" {
  description = "true to install Traefik"
  default = true
}

variable "install_local_path_provisioner" {
  description = "true to install local-path-provisioner when kubernetes_storage_backend is local-path"
  default = true
}

variable "kubernetes_storage_backend" {
  description = "Storage backend for Kubernetes PVCs. Use local-path to let sumaform install Rancher's local-path provisioner. Other values expect a pre-existing StorageClass."
  default     = "local-path"

  validation {
    condition     = contains(["local-path", "external", "nfs", "longhorn", "openebs", "rook-ceph", "cloud"], var.kubernetes_storage_backend)
    error_message = "kubernetes_storage_backend must be one of: local-path, external, nfs, longhorn, openebs, rook-ceph, cloud."
  }
}

variable "kubernetes_storage_class" {
  description = "StorageClass name used by Kubernetes PVCs. Set to null to rely on the cluster default StorageClass."
  default     = "local-path"
}

variable "local_path_provisioner_path" {
  description = "Host path used by Rancher's local-path provisioner for dynamically provisioned volumes."
  default     = "/opt/local-path-provisioner"
}

variable "local_path_provisioner_default_class" {
  description = "true to mark the local-path StorageClass as the cluster default when it is installed."
  default     = true
}

variable "local_path_provisioner_reclaim_policy" {
  description = "Reclaim policy for the local-path StorageClass."
  default     = "Delete"
}

variable "kubernetes_create_static_var_spacewalk_pv" {
  description = "Whether to create the static var-spacewalk PersistentVolume. Leave null to enable it only with the local-path backend."
  default     = null
}

variable "kubernetes_var_spacewalk_host_path" {
  description = "Host path used by the static var-spacewalk PersistentVolume."
  default     = "/var/lib/rancher/rke2/storage/var-spacewalk"
}

variable "beta_enabled" {
  description = "Enable the mechanism to take into account beta channels"
  default     = false
}

variable "web_server_hostname" {
  description = "FQDN of the web server or leave the default for no web server"
  default = null
}
