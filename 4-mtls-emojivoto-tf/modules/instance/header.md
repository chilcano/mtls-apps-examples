# DPG - Instances module

This module creates the ec2 instances used by the playgrounds

``` HCL
  depends_on         = [module.network]
  profile            = aws_iam_instance_profile.jenkins_profile.name
  PlaygroundName     = "${var.PlaygroundName}Jenkins"
  instance_type      = "t2.medium"
  security_group_ids = [module.network.allow_all_security_group_id]
  subnet_id          = module.network.public_subnets.0
  user_data          = file("install-jenkins.sh")


```

This will create a instance and run the "install-jenkins.sh" file on the instance
