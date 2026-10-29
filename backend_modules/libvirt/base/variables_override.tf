# Override use_avahi default for libvirt backend
# Avahi/mDNS works well on libvirt and should be enabled by default
# See README_ADVANCED.md for details
#
# Necessary because avahi was globally disabled by default in
# https://github.com/uyuni-project/sumaform/pull/1903

variable "use_avahi" {
  default = true
}
