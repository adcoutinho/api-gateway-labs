resource "aws_ssm_parameter" "kong_db_password" {
  name  = "/kong/${terraform.workspace}/kong_db_password"
  value = random_password.kong-db-password.result
  type  = "SecureString"

  tags = local.tags

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}
