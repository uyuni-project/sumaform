resource "libvirt_volume" "disk" {
  name  = "${var.volume_name}${var.quantity > 1 ? "-${count.index + 1}" : ""}"
  size  = var.volume_size
  pool  = lookup(var.volume_provider_settings, "pool", "default")
  count = var.quantity
}

output "configuration" {
  value = {
    ids = length(libvirt_volume.disk) > 0 ? libvirt_volume.disk.*.id : []
  }
}
