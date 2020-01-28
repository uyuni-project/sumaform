
resource "null_resource" "disk" {
  triggers = {
    name              = var.volume_name
    size              = var.volume_size
    provider_settings = yamlencode(var.volume_provider_settings)
    count             = var.quantity
  }
}

output "configuration" {
  value = {
    ids = length(null_resource.disk) > 0 ? null_resource.disk.*.id : []
  }
}
