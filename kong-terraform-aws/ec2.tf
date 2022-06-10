resource "aws_launch_configuration" "kong" {
  name_prefix          = format("%s-%s-", local.project, local.environment)
  image_id             = local.ami[data.aws_region.current.name]
  instance_type        = local.instance_type
  iam_instance_profile = aws_iam_instance_profile.kong.name
  key_name             = local.key_name

  security_groups = [
    data.aws_security_group.default.id,
    aws_security_group.kong.id,
  ]

  associate_public_ip_address = false
  enable_monitoring           = false
  placement_tenancy           = "default"
  user_data                   = data.template_cloudinit_config.cloud-init.rendered

  root_block_device {
    volume_size = local.volume_size
    volume_type = local.volume_type
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "kong" {
  name                = format("%s-%s", local.project, local.environment)
  vpc_zone_identifier = data.aws_subnet_ids.private.ids

  launch_configuration = aws_launch_configuration.kong.name

  desired_capacity          = local.desired_capacity
  force_delete              = false
  health_check_grace_period = local.health_check_grace_period
  health_check_type         = "ELB"
  max_size                  = local.max_size
  min_size                  = local.min_size

  target_group_arns = compact(
    concat(
      aws_lb_target_group.external.*.arn,
      aws_lb_target_group.internal.*.arn,
      aws_lb_target_group.admin.*.arn,
      aws_lb_target_group.manager.*.arn,
      aws_lb_target_group.portal-gui.*.arn,
      aws_lb_target_group.portal.*.arn
    )
  )

  tag {
    key                 = "Name"
    value               = format("%s-%s", local.project, local.environment)
    propagate_at_launch = true
  }
  tag {
    key                 = "Environment"
    value               = local.environment
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = local.tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  depends_on = [
    aws_db_instance.kong,
    aws_rds_cluster.kong
  ]
}
