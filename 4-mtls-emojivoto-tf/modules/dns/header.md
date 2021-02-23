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
