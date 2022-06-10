locals {
  enable_rds = var.enable_aurora ? false : true

  manager_host = var.manager_host == "default" ? join("", aws_lb.internal.*.dns_name) : var.manager_host
  portal_host  = var.portal_host == "default" ? join("", aws_lb.internal.*.dns_name) : var.portal_host

  # VPC Settings
  vpc_name = "api-gateway-test"
  cidr     = "10.171.0.0/16"


  # EC2 Settings 
  ami           = "ami-0783b42a4ca25b7de"
  instance_type = "t2.micro"
  volume_size   = 10
  volume_type   = "gp2"
  key_name      = "kong-test"

  # ASG Settings
  max_size                  = 3
  min_size                  = 1
  desired_capacity          = 2
  health_check_grace_period = 300

  # LB Settings
  enable_external_lb               = true
  health_check_healthy_threshold   = 5
  health_check_interval            = 5
  health_check_timeout             = 3
  health_check_unhealthy_threshold = 2
  enable_deletion_protection       = false
  idle_timeout                     = 60
  ssl_policy                       = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"

  # RDS Settings 
  enable_rds = true

  # Kong Settings
  project     = "kong"
  environment = "test"


  # Tags
  tags = {
    Env            = "test"
    System         = "api-gateway"
    SubSystem      = "kong"
    Documentation  = "CHANGE-ME"
    Tribe          = "platform"
    CreationOrigin = "Terraform"
    Repository     = "CHANGE-ME"
    State          = "adriano-coutinho-bucket/test/kong-terraform-aws/terraform.tfstate"
  }

}
