module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  name = local.vpc_name
  cidr = local.cidr

  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets = [cidrsubnet(local.cidr, 8, 1), cidrsubnet(local.cidr, 8, 1), cidrsubnet(local.cidr, 8, 1)]
  public_subnets  = [cidrsubnet(local.cidr, 8, 10), cidrsubnet(local.cidr, 8, 10), cidrsubnet(local.cidr, 8, 10)]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  private_subnet_tags = local.tags

  public_subnet_tags = local.tags

  tags = local.tags
}
