resource "aws_kms_key" "kong" {
  description = format("%s-%s", local.service, local.environment)

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

resource "aws_kms_alias" "kong" {
  name          = format("alias/%s-%s", local.service, local.environment)
  target_key_id = aws_kms_key.kong.key_id
}

resource "aws_ssm_parameter" "ee-bintray-auth" {
  name  = format("/%s/%s/ee/bintray-auth", local.service, local.environment)
  type  = "SecureString"
  value = local.ee_bintray_auth

  key_id = aws_kms_alias.kong.target_key_arn

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "ee-license" {
  name  = format("/%s/%s/ee/license", local.service, local.environment)
  type  = "SecureString"
  value = local.ee_license

  key_id = aws_kms_alias.kong.target_key_arn

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "ee-admin-token" {
  name  = format("/%s/%s/ee/admin/token", local.service, local.environment)
  type  = "SecureString"
  value = random_string.admin_token.result

  key_id = aws_kms_alias.kong.target_key_arn

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "db-host" {
  name = format("/%s/%s/db/host", local.service, local.environment)
  type = "String"
  value = coalesce(
    join("", aws_db_instance.kong.*.address),
    join("", aws_rds_cluster.kong.*.endpoint),
    "none"
  )
}

resource "aws_ssm_parameter" "db-name" {
  name  = format("/%s/%s/db/name", local.service, local.environment)
  type  = "String"
  value = replace(format("%s_%s", local.service, local.environment), "-", "_")
}

resource "aws_ssm_parameter" "db-password" {
  name  = format("/%s/%s/db/password", local.service, local.environment)
  type  = "SecureString"
  value = random_string.db_password.result

  key_id = aws_kms_alias.kong.target_key_arn

  lifecycle {
    ignore_changes = [value]
  }

  overwrite = true
}

resource "aws_ssm_parameter" "db-master-password" {
  name  = format("/%s/%s/db/password/master", local.service, local.environment)
  type  = "SecureString"
  value = random_string.master_password.result

  key_id = aws_kms_alias.kong.target_key_arn

  lifecycle {
    ignore_changes = [value]
  }

  overwrite = true
}
