resource "aws_security_group" "kong" {
  name        = "${local.prefix}-sg"
  description = "Allow ${local.project} Access"
  vpc_id      = local.vpc_id

  dynamic "ingress" {
    for_each = local.service_ports
    content {
      from_port   = ingress.key
      to_port     = ingress.key
      protocol    = "tcp"
      cidr_blocks = ingress.value
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags

}