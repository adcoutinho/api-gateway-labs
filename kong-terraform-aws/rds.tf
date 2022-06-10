resource "aws_db_instance" "kong" {
  count      = local.enable_rds ? 1 : 0
  identifier = format("%s-%s", local.service, local.environment)


  engine            = "postgres"
  engine_version    = local.db_engine_version
  instance_class    = local.db_instance_class
  allocated_storage = local.db_storage_size
  storage_type      = "gp2"

  backup_retention_period = local.db_backup_retention_period
  db_subnet_group_name    = local.db_subnets
  multi_az                = local.db_multi_az
  parameter_group_name    = format("%s-%s", local.service, local.environment)


  username = "root"
  password = random_string.master_password.result

  vpc_security_group_ids = [aws_security_group.postgresql.id]

  skip_final_snapshot       = local.db_final_snapshot_identifier == "" ? true : false
  final_snapshot_identifier = local.db_final_snapshot_identifier == "" ? null : local.db_final_snapshot_identifier

  tags = merge(
    {
      "Name"        = format("%s-%s", local.service, local.environment),
      "Environment" = local.environment,
      "Description" = local.description,
      "Service"     = local.service,
    },
    local.tags
  )
  depends_on = [aws_db_parameter_group.kong]
}

resource "aws_db_parameter_group" "kong" {
  count = local.db_instance_count > 0 ? 1 : 0

  name        = format("%s-%s", local.service, local.environment)
  family      = local.db_family
  description = local.description

  tags = merge(
    {
      "Name"        = format("%s-%s", local.service, local.environment),
      "Environment" = local.environment,
      "Description" = local.description,
      "Service"     = local.service,
    },
    local.tags
  )
}
