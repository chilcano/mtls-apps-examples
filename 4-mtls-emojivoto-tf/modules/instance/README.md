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

#### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| PlaygroundName | The name of the playground for tagging | `string` | n/a | yes |
| security_group_ids | An array of security groups for the instance | `list(string)` | n/a | yes |
| subnet_id | The id of the subnet | `string` | n/a | yes |
| amiName | The name of the ami to run on the instance | `string` | `"amzn2-ami-hvm*"` | no |
| amiOwner | The Owner of the ami to run on the instance | `string` | `"amazon"` | no |
| associate_public_ip_address | Should aws give the instance a public ip | `bool` | `true` | no |
| instance_count | The amount of instances to create | `number` | `1` | no |
| instance_type | The type of instance | `string` | `"t2.micro"` | no |
| profile | The Role of the instance to take | `string` | `null` | no |
| purpose | A tag to give each resource | `string` | `"Playground"` | no |
| user_data | Custom user data to run on first start | `string` | `""` | no |

#### Outputs

| Name | Description |
|------|-------------|
| public_ips | The public ips of the workstation |

