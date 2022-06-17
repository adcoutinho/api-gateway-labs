data "aws_caller_identity" "current" {}

data "aws_vpc" "vpc" {
  tags = {
    "Name" = "Test"
  }
}

data "aws_subnet_ids" "private_subnets" {
  vpc_id = data.aws_vpc.vpc.id

  filter {
    name   = "tag:Name"
    values = ["Test APP Private *"]
  }
}

data "aws_acm_certificate" "cert" {
  most_recent = true
  domain      = "*.${local.cert_domain}"
}

data "aws_route53_zone" "public" {
  name         = local.domain
  private_zone = false
}
