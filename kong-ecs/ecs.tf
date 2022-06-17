resource "aws_ecs_cluster" "this" {
  name = "cluster-${local.prefix}"
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = local.prefix
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = local.cpu
  memory                   = local.memory

  task_role_arn = module.iam_assumable_role.iam_role_arn

  container_definitions = jsonencode([
    {
      name   = local.prefix
      image  = local.image
      cpu    = local.cpu
      memory = local.memory
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        },
        {
          containerPort = 8001
          hostPort      = 8001
          protocol      = "tcp"
        },
        {
          containerPort = 8443
          hostPort      = 8443
          protocol      = "tcp"
        },
        {
          containerPort = 8444
          hostPort      = 8444
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "KONG_PROXY_PORT"
          value = local.kong_proxy_port
        },
        {
          name  = "KONG_PROXY_SSL_PORT"
          value = local.kong_proxy_ssl_port
        },
        {
          name  = "KONG_ADMIN_LISTEN"
          value = local.kong_admin_list
        },
        {
          name  = "KONG_PROXY_ACCESS_LOG"
          value = local.kong_access_log
        },
        {
          name  = "KONG_ADMIN_ACCESS_LOG"
          value = local.kong_access_log
        },
        {
          name  = "KONG_PROXY_ERROR_LOG"
          value = local.kong_error_log
        },
        {
          name  = "KONG_ADMIN_ERROR_LOG"
          value = local.kong_error_log
        },
        {
          name  = "KONG_DATABASE"
          value = local.engine
        },
        {
          name  = "KONG_DB_NAME"
          value = local.db_name
        },
        {
          name  = "KONG_DB_USERNAME"
          value = local.db_user
        },
        {
          name  = "KONG_DB_HOST"
          value = aws_db_instance.this.address
        },
        {
          name  = "KONG_DB_PORT"
          value = local.db_port
        }
      ]
      secrets = [
        {
          name      = "KONG_DB_PASSWORD"
          valueFrom = aws_ssm_parameter.kong_db_password.arn
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = local.region
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-stream-prefix = aws_cloudwatch_log_group.this.name
        }
      }
      mountPoints = [{
        sourceVolume  = "efs-root"
        containerPath = local.efs_mount_point
      }]
      essential   = true
      volumesFrom = []
    }
  ])

  volume {
    name = "efs-root"
    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.this.id
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999

      authorization_config {
        access_point_id = aws_efs_access_point.ap.id
        iam             = "ENABLED"
      }
    }
  }

  tags = local.tags
}


resource "aws_ecs_service" "this" {
  name             = local.prefix
  cluster          = "cluster-${terraform.workspace}"
  task_definition  = "${aws_ecs_task_definition.this.family}:${max(aws_ecs_task_definition.this.revision, data.aws_ecs_task_definition.this.revision)}"
  platform_version = "1.4.0"

  desired_count = local.desired_count

  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100
  health_check_grace_period_seconds  = 5

  network_configuration {
    security_groups  = [module.ecs_sg.this_security_group_id]
    subnets          = local.private_subnet_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.this.arn
    container_name   = local.prefix
    container_port   = local.container_port
  }

  capacity_provider_strategy {
    base              = 0
    capacity_provider = "FARGATE"
    weight            = 100
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }
}
