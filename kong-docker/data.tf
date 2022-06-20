data "aws_caller_identity" "current" {}

data "aws_vpc" "vpc" {
  tags = {
    "Name" = "Test"
  }
}

data "aws_subnet_ids" "public_subnets" {
  vpc_id = data.aws_vpc.vpc.id

  filter {
    name   = "tag:Name"
    values = ["Test Public *"]
  }
}

data "aws_acm_certificate" "cert" {
  most_recent = true
  domain      = "*.${local.domain}"
}

data "aws_route53_zone" "public" {
  name         = local.domain
  private_zone = false
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
