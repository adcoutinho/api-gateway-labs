locals {
  vpc_id          = data.aws_vpc.vpc.id
  region          = "us-east-1"
  certificate_arn = data.aws_acm_certificate.cert.arn
  env             = terraform.workspace
  team            = "infra-aws"
  tribe           = "Platform"
  project         = "kong-docker"
  name            = lower(local.project)
  prefix          = "${local.name}-${terraform.workspace}"
  domain          = "testes.pagarme.net"
  subnets         = data.aws_subnet_ids.private_subnets.ids
  r53_zone_id     = data.aws_route53_zone.public.zone_id
  instance_type   = "t2.medium"
  key_name        = "adcoutinho-tests"

  service_ports = {
    "22"   = ["10.0.0.0/8", "192.18.0.0/16", "186.194.105.13/32"]
    "8000" = ["10.0.0.0/8", "192.18.0.0/16", "186.194.105.13/32"]
    "8001" = ["10.0.0.0/8", "192.18.0.0/16", "186.194.105.13/32"]
    "8443" = ["10.0.0.0/8", "192.18.0.0/16", "186.194.105.13/32"]
    "8444" = ["10.0.0.0/8", "192.18.0.0/16", "186.194.105.13/32"]
  }


  tags = {
    Env            = local.env
    Team           = local.team
    System         = local.project
    SubSystem      = local.project
    Tribe          = local.tribe
    CreationOrigin = "terraform"
    Repository     = ""
    State          = "adriano-coutinho-bucket/test/applications/api-gw-internal-lb/terraform.tfstate"
    Documentation  = "https://mundipagg.atlassian.net/wiki/home"
  }
}