resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/ecs/${local.prefix}"
  retention_in_days = local.log_retention_in_days
  kms_key_id        = aws_kms_key.cmk.arn

  tags = local.tags
}
