# AWS Data
data "aws_vpc" "vpc" {
  state = "available"

  tags = {
    "Name" = local.vpc_name 
  }
}

data "aws_region" "current" {}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.vpc.id

  filter {
    name   = "tag:${local.subnet_tag}"
    values = [local.public_subnets]
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.vpc.id

  filter {
    name   = "tag:${local.subnet_tag}"
    values = [local.private_subnets]
  }
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.vpc.id

  tags = {
    "Name" = local.default_security_group
  }
}

data "aws_acm_certificate" "external-cert" {
  domain = local.ssl_cert_external
}

data "aws_acm_certificate" "internal-cert" {
  domain = local.ssl_cert_internal
}

data "template_file" "cloud-init" {
  template = file("${path.module}/cloud-init.cfg")
}

data "template_file" "shell-script" {
  template = file("${path.module}/cloud-init.sh")

  locals = {
    DB_USER        = replace(format("%s_%s", local.service, local.environment), "-", "_")
    CE_PKG         = local.ce_pkg
    EE_PKG         = local.ee_pkg
    PARAMETER_PATH = format("/%s/%s", local.service, local.environment)
    REGION         = data.aws_region.current.name
    VPC_CIDR_BLOCK = data.aws_vpc.vpc.cidr_block
    DECK_VERSION   = local.deck_version
    MANAGER_HOST   = local.manager_host
    PORTAL_HOST    = local.portal_host
    SESSION_SECRET = random_string.session_secret.result
  }
}

data "template_cloudinit_config" "cloud-init" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.cloud-init.rendered
  }

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.shell-script.rendered
  }
}
