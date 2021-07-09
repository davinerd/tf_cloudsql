locals {
  master_instance_name = var.random_instance_name ? "${var.name}-${random_id.suffix[0].hex}" : var.name

  databases = { for db in var.additional_databases : db.name => db }
  users     = { for u in var.additional_users : u.name => u }
  iam_users = [for iu in var.iam_user_emails : {
    email         = iu,
    is_account_sa = trimsuffix(iu, "gserviceaccount.com") == iu ? false : true
  }]

  replicas = {
    for x in var.read_replicas : "${var.name}-replica${var.read_replica_name_suffix}${x.name}" => x
  }

  retained_backups = lookup(var.backup_configuration, "retained_backups", null)
  retention_unit   = lookup(var.backup_configuration, "retention_unit", null)

  is_private = var.private_network != null ? true : false

  private_ip_name = "private-ip-${random_id.network_name.hex}"

  #is_public = (!local.is_private && !var.public_ip) || (!local.is_private && var.public_ip) || var.public_ip ? true : false

  is_public = local.is_private && !var.public_ip ? false : true

  ip_configuration = {
    "authorized_networks" : var.authorized_networks
    "ipv4_enabled" : local.is_public,
    "private_network" : var.private_network,
    "require_ssl" : var.require_ssl
  }

  ip_configuration_enabled = length(keys(local.ip_configuration)) > 0 ? true : false

  ip_configurations = {
    enabled  = local.ip_configuration
    disabled = {}
  }
}
