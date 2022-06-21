resource "aws_instance" "kong" {
  count                       = local.kong_instances
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = local.instance_type
  key_name                    = local.key_name
  user_data                   = file("cloud-init.cfg")
  subnet_id                   = tolist(data.aws_subnet_ids.public_subnets.ids)[count.index]
  vpc_security_group_ids      = [aws_security_group.kong.id]
  associate_public_ip_address = true

  tags = merge(local.tags, {
    Name = "${local.prefix}-${count.index}"
  })
}
