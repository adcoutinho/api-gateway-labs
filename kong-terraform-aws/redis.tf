resource "aws_elasticache_replication_group" "kong" {
  count = local.enable_redis ? 1 : 0

  replication_group_id          = format("%s-%s", local.service, local.environment)
  replication_group_description = local.description

  engine                = "redis"
  engine_version        = local.redis_engine_version
  node_type             = local.redis_instance_type
  number_cache_clusters = local.redis_instance_count
  parameter_group_name  = format("%s-%s", local.service, local.environment)
  port                  = 6379

  subnet_group_name  = local.redis_subnets
  security_group_ids = [aws_security_group.redis.id]

  tags = merge(
    {
      "Name"        = format("%s-%s", local.service, local.environment),
      "Environment" = local.environment,
      "Description" = local.description,
      "Service"     = local.service,
    },
    local.tags
  )
  depends_on = [aws_elasticache_parameter_group.kong]
}

resource "aws_elasticache_parameter_group" "kong" {
  name   = format("%s-%s", local.service, local.environment)
  family = local.redis_family

  description = local.description
}
