resource "aws_lb" "kong" {
  name               = local.prefix
  internal           = true
  load_balancer_type = "network"
  subnets            = [aws_security_group.sg_kong_api_gw_internal.id]

  enable_deletion_protection = true

  tags = merge(local.tags, { Name = "${local.prefix}" })
}

resource "aws_security_group" "sg_kong_lb_internal" {
  description = "${terraform.workspace} kong api gw internal lb main security group"
  name        = "${terraform.workspace}_sg_kong_lb_internal"
  vpc_id      = local.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    ignore_changes = [
      egress
    ]
  }

  tags = local.tags
}

resource "aws_lb_listener" "kong_443" {
  load_balancer_arn = aws_lb.kong.arn
  port              = "443"
  protocol          = "TLS"
  certificate_arn   = data.aws_acm_certificate.cert.arn
  alpn_policy       = "HTTP2Preferred"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kong.arn
  }
}

resource "aws_lb_target_group" "https" {
  name                 = local.prefix
  port                 = local.container_port
  protocol             = "HTTP"
  vpc_id               = local.vpc_id
  target_type          = "ip"
  deregistration_delay = 5

  health_check {
    interval            = 8
    path                = "/hello"
    timeout             = 5
    unhealthy_threshold = 3
  }

  tags = local.tags
}
