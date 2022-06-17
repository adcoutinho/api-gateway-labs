resource "aws_db_instance" "this" {
  allocated_storage   = local.allocated_storage
  engine              = local.engine
  engine_version      = local.engine_version
  instance_class      = local.instance_class
  name                = local.db_name
  username            = local.db_user
  password            = random_password.kong-db-password.result
  skip_final_snapshot = true
}

resource "random_password" "kong-db-password" {
  length  = 24
  special = false
}
