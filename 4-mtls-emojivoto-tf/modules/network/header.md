# DPG - VPC module

This module creates a separate VPC to be used by the instances related to the DevOps Playground.
The goal is to give some more isolation.

You only need to provide the base CIDR block for the VPC, and the subnet CIDRs will be calculated for you.

For example:

```bash
vpc_cidr_block = 10.0.0.0/16
public_subnets = 2
private_subnets = 3
```

This will create 2 public subnets:

- 10.0.11.0/24
- 10.0.12.0/24

and 3 private subnets:

- 10.0.101.0/24
- 10.0.102.0/24
- 10.0.103.0/24
