# External - HTTPS only
resource "aws_lb_target_group" "external" {
  count = local.enable_external_lb ? 1 : 0

  name     = format("%s-%s-external", local.project, local.environment)
  port     = 8000
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.vpc.id

  health_check {
    healthy_threshold   = local.health_check_healthy_threshold
    interval            = local.health_check_interval
    path                = "/status"
    port                = 8000
    timeout             = local.health_check_timeout
    unhealthy_threshold = local.health_check_unhealthy_threshold
  }

  tags = merge(
    {
      "Name"        = format("%s-%s-external", local.project, local.environment),
      "Environment" = local.environment
    },
    local.tags
  )
}

resource "aws_lb" "external" {
  count = local.enable_external_lb ? 1 : 0

  name     = format("%s-%s-external", local.project, local.environment)
  internal = false
  subnets  = data.aws_subnet_ids.public.ids

  security_groups = [aws_security_group.external-lb.id]

  enable_deletion_protection = local.enable_deletion_protection
  idle_timeout               = local.idle_timeout

  tags = merge(
    {
      "Name"        = format("%s-%s-external", local.project, local.environment),
      "Environment" = local.environment
    },
    local.tags
  )
}

resource "aws_lb_listener" "external-https" {
  count = local.enable_external_lb ? 1 : 0

  load_balancer_arn = aws_lb.external[0].arn
  port              = "443"
  protocol          = "HTTPS"

  ssl_policy      = local.ssl_policy
  certificate_arn = data.aws_acm_certificate.external-cert.arn

  default_action {
    target_group_arn = aws_lb_target_group.external[0].arn
    type             = "forward"
  }
}
