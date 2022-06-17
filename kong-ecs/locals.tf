locals {
  env                   = terraform.workspace
  account_id            = data.aws_caller_identity.current.id
  region                = "us-east-1"
  project               = "kong-api-gw"
  name                  = lower(local.project)
  prefix                = "${local.name}-${terraform.workspace}"
  vpc_id                = data.aws_vpc.vpc.id
  domain                = "testes.pagarme.net"
  subnets               = data.aws_subnet_ids.private_subnets.ids
  r53_zone_id           = data.aws_route53_zone.public.zone_id
  team                  = "infra-aws"
  tribe                 = "Platform"
  cpu                   = 512
  memory                = 1024
  image                 = "kong:2.8.1-ubuntu"
  log_retention_in_days = 7

  # RDS Settings
  allocated_storage = 5
  engine            = "postgres"
  engine_version    = "12.1"
  instance_class    = "db.t3.micro"
  db_name           = "kong"
  db_user           = "konguser"
  db_port           = 5432

  # Kong Settings
  kong_proxy_port     = 8000
  kong_proxy_ssl_port = 8443
  kong_admin_list     = "0.0.0.0:8001, 0.0.0.0:8444 ssl"
  kong_access_log     = "/dev/stdout"
  kong_error_log      = "/dev/stderr"



  tags = {
    Env            = local.env
    Team           = local.team
    System         = local.project
    SubSystem      = local.project
    Tribe          = local.tribe
    CreationOrigin = "terraform"
    Repository     = "pagarme/platform-infrastructure"
    State          = "platform-infrastructure/applications/shared-internal-lb/terraform.tfstate"
    Documentation  = "https://mundipagg.atlassian.net/wiki/home"
  }
}