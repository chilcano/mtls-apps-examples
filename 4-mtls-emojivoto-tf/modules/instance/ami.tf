data "aws_ami" "amazon-linux-2" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.amiName]
  }

  owners = [var.amiOwner]
}


