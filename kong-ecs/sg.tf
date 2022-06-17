resource "aws_security_group" "this" {

  name        = "${local.prefix}-sg"
  description = "Allow access to RDS instances"

  vpc_id = local.vpc_id

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
  security_group_id        = data.terraform_remote_state.forrestgump.outputs.db_security_group_id
  description              = "Permite acesso ao banco via ecs cluster"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.this.id
}
