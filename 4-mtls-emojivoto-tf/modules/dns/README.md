<<<<<<< HEAD
# DPG - VPC module
## Requirements

To have the DNS module work you need the following:

- A route 53 hosted zone created within an AWS account

To use your own hosted zone edit the data.tf file under this module
and add the name of your route 53 hosted zone.

**Example:**

```bash
data "aws_route53_zone"  "playground_hostedzone" {
name = "YOUR_HOSTED_ZONE_NAME" 
private_zone = false
}
```
For more information on the creation of a hosted zone:
 - https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingHostedZone.html
##

This module creates a separate DNS record for each user of the playground. 
This is used to have a more memorable name so that user don't need to remember IP addresses. 

DNS records are automatically made when applied and will give a random adjective.
This will end with the prefix of -panda as shown below.
- To make the name more memorable. 

**Example**

```bash
    workstation-alive-panda.devopsplayground.org
    workstation-advanced-panda.devopsplayground.org
```
=======
# DPG - dns module

This requires a hosted zone so for the average use will not be used.

example jenkins DNS module

``` HCL
  depends_on   = [module.jenkins]
  instances    = 1
  instance_ips = module.jenkins.public_ip
  record_name  = "happy-panda"
```

This will create a DNS record for an instances ip with the prefix of happy-panda

i.e happy-panda.devopsplayground.org

>>>>>>> 62bf15d2796292b4b96cc90fb812d7ba12c9dfcb
#### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| instance_ips | List of IP's of the instances being used  the DNS hosted zone | `list(string)` | n/a | yes |
| instances | number of instances to create records for | `number` | n/a | yes |
| record_name | the name of the dns record to create | `string` | n/a | yes |
| record_ttl | default time to live for domain records | `number` | `300` | no |
| record_type | The dns record type to be used | `string` | `"A"` | no |

#### Outputs

| Name | Description |
|------|-------------|
| name | name of dns record created |
| zone_id | The id of the zone the record is in |

