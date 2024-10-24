resource "aws_db_parameter_group" "postgres_parameter_group" {
  name        = var.rds_parameter_group_name
  family      = var.pg_family
  description = "Custom parameter group for PostgreSQL database"

  parameter {
    name  = "rds.force_ssl"
    value = "0" # Disable SSL
  }

}
