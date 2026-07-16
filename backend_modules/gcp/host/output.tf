output "proxy" {
  value = "${google_compute_instance.suma-proxy-42-instance.name}:${google_compute_instance.suma-proxy-42-instance.network_interface[0].access_config[0].nat_ip}" 
}
output "server" {
  value = "${google_compute_instance.suma-server-42-instance.name}:${google_compute_instance.suma-server-42-instance.network_interface[0].access_config[0].nat_ip}" 
}
