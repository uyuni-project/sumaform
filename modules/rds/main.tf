module "rds" {
  source = "../backend/db_host"

  base_configuration            = var.base_configuration
  identifier                    = var.identifier
  connect_to_base_network       = true
  connect_to_additional_network = false

  db_username                   = var.db_username
  db_name                       = var.db_name
  db_password                   = var.db_password
  engine                        = var.engine
  engine_version                = var.engine_version
  provider_settings             = var.provider_settings

  publicly_accessible           = var.publicly_accessible
  skip_final_snapshot           = var.skip_final_snapshot
}

output "configuration" {
  value = {
    id              = length(module.rds.configuration["ids"]) > 0 ? module.rds.configuration["ids"][0] : null
    hostname        = length(module.rds.configuration["hostnames"]) > 0 ? module.rds.configuration["hostnames"][0] : null
    ca              = length(module.rds.configuration["ca"]) > 0 ? module.rds.configuration["ca"][0] : null
  }
}
