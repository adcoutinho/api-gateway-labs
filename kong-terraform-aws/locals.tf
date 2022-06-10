locals {
  enable_rds = var.enable_aurora ? false : true

  manager_host = var.manager_host == "default" ? join("", aws_lb.internal.*.dns_name) : var.manager_host
  portal_host  = var.portal_host == "default" ? join("", aws_lb.internal.*.dns_name) : var.portal_host



  # EC2 Settings 
  ami = "ami-0783b42a4ca25b7de"
  instance_type = "t2.micro"
  volume_size = 10
  volume_type = "gp2"

  # ASG Settings
  max_size = 3
  min_size = 1
  desired_capacity = 2
  health_check_grace_period = 300


}
