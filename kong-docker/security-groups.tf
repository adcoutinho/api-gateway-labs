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

resource "aws_security_group" "rds" {

  name        = "${local.prefix}-rds-sg"
  description = "Allow ${local.project} RDS Access"
  vpc_id      = local.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow esgress to any ip"
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = local.tags

}

resource "aws_security_group_rule" "rds_allow" {
  security_group_id        = aws_security_group.kong.id
  description              = "Permite acesso ao banco"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.this.id
}
