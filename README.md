# Terraform module for CloudSQL

This module is mostly based off the [Google SQL DB Postgres module](https://github.com/terraform-google-modules/terraform-google-sql-db) version 4.

Additional features:
- Support private instances (via VPC peering) by default
- Improved read replicas configuration


# Usage

The variables are the same as the ones in the aforementioned module.

By default it creates a private db instance and therefore the `private_network` variable must be set. If you don't want the cluster to be private, just pass `private_network = null`. It will automatically set the `public_ip` to `true`.

```
module "postgresql-db" {
  source  = "github.com/davinerd/tf_cloudsql"

  database_version = "POSTGRES_12"

  name = "cloudsql-testing"

  project_id = "myCoolProject"

  zone = local.db_zone

  machine_type = "db-custom-2-8096"

  # default is ZONAL
  availability_type = "REGIONAL"

  region = "europe-west4"

  backup_configuration = {
    "enabled" : true,
    "location" : "EU",
    "point_in_time_recovery_enabled" : false,
    "retained_backups" : 7,
    "retention_unit" : null,
    "start_time" : null,
    "transaction_log_retention_days" : null
  }

  # If you don't want the cluster to be private, just pass 'null' here
  private_network = google_compute_network.custom_network.self_link

  read_replicas = 1
}
```