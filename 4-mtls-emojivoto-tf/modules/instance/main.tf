resource "aws_instance" "main" {
  count                       = var.instance_count
  ami                         = data.aws_ami.amazon-linux-2.id
  iam_instance_profile        = var.profile
  associate_public_ip_address = var.associate_public_ip_address
  instance_type               = var.instance_type
  vpc_security_group_ids      = var.security_group_ids
  subnet_id                   = var.subnet_id
  user_data                   = var.user_data

  tags = {
    Name    = "${var.PlaygroundName}-${count.index + 1}"
    Purpose = var.purpose
  }
}
