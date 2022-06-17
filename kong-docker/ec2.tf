resource "aws_instance" "kong" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = local.instance_type
  key_name                    = local.key_name
  user_data                   = file("cloud-init.cfg")
  subnet_id                   = tolist(data.aws_subnet_ids.private_subnets.ids)[0]
  vpc_security_group_ids      = [aws_security_group.kong.id]
  associate_public_ip_address = false

  tags = merge(local.tags, {
    Name = local.prefix
  })
}
