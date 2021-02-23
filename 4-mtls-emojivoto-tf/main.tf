locals {
  adj = jsondecode(file("./adjectives.json"))
}

module "network" {
  count            = var.deploy_count
  source           = "./modules/network"
  required_subnets = 2
  PlaygroundName   = var.PlaygroundName
}

module "puppet" {
  count              = var.deploy_count
  source             = "./modules/instance"
  PlaygroundName     = "${element(local.adj, count.index)}-panda-${var.PlaygroundName}-puppet"
  security_group_ids = [module.network[count.index].allow_all_security_group_id]
  subnet_id          = module.network[count.index].public_subnets.0
  instance_type      = var.instance_type
  user_data = templatefile(
    "${var.scriptLocation}/puppet_master.sh",
    {
      prefix      = var.PlaygroundName
      type_panda  = "${element(local.adj, count.index)}-panda"
      hostname    = "${var.PlaygroundName}-puppet-${element(local.adj, count.index)}-panda"
      username    = "puppet-user"
      ssh_pass    = "playground"
      region      = var.region
      gitrepo     = "https://github.com/chilcano/mtls-emojivoto-tf.git"
    }
  )
  amiName   = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
  amiOwner  = "099720109477"
}

module "ca" {
  depends_on         = [module.puppet]
  count              = var.deploy_count
  source             = "./modules/instance"
  PlaygroundName     = "${element(local.adj, count.index)}-panda-${var.PlaygroundName}-ca"
  security_group_ids = [module.network[count.index].allow_all_security_group_id]
  subnet_id          = module.network[count.index].public_subnets.0
  instance_type      = var.instance_type
  user_data = templatefile(
    "${var.scriptLocation}/puppet_agent.sh",
    {
      hostname          = "${var.PlaygroundName}-ca-${element(local.adj, count.index)}-panda"
      username          = "ca"
      ssh_pass          = "playground"
      region            = var.region
      gitrepo           = "https://github.com/chilcano/mtls-emojivoto-tf.git"
      puppet_hostname   = "${var.PlaygroundName}-puppet-${element(local.adj, count.index)}-panda"
    }
  )
  amiName   = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
  amiOwner  = "099720109477"
}

module "web" {
  depends_on         = [module.puppet]
  count              = var.deploy_count
  source             = "./modules/instance"
  PlaygroundName     = "${element(local.adj, count.index)}-panda-${var.PlaygroundName}-web"
  security_group_ids = [module.network[count.index].allow_all_security_group_id]
  subnet_id          = module.network[count.index].public_subnets.0
  instance_type      = var.instance_type
  user_data = templatefile(
    "${var.scriptLocation}/puppet_agent.sh",
    {
      hostname          = "${var.PlaygroundName}-web-${element(local.adj, count.index)}-panda"
      username          = "web"
      ssh_pass          = "playground"
      region            = var.region
      gitrepo           = "https://github.com/chilcano/mtls-emojivoto-tf.git"
      puppet_hostname   = "${var.PlaygroundName}-puppet-${element(local.adj, count.index)}-panda"
    }
  )
  amiName   = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
  amiOwner  = "099720109477"
}

module "emoji" {
  depends_on         = [module.puppet]
  count              = var.deploy_count
  source             = "./modules/instance"
  PlaygroundName     = "${element(local.adj, count.index)}-panda-${var.PlaygroundName}-emoji"
  security_group_ids = [module.network[count.index].allow_all_security_group_id]
  subnet_id          = module.network[count.index].public_subnets.0
  instance_type      = var.instance_type
  user_data = templatefile(
    "${var.scriptLocation}/puppet_agent.sh",
    {
      hostname          = "${var.PlaygroundName}-emoji-${element(local.adj, count.index)}-panda"
      username          = "emoji"
      ssh_pass          = "playground"
      region            = var.region
      gitrepo           = "https://github.com/chilcano/mtls-emojivoto-tf.git"
      puppet_hostname   = "${var.PlaygroundName}-puppet-${element(local.adj, count.index)}-panda"
    }
  )
  amiName   = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
  amiOwner  = "099720109477"
}

module "voting" {
  depends_on         = [module.puppet]
  count              = var.deploy_count
  source             = "./modules/instance"
  PlaygroundName     = "${element(local.adj, count.index)}-panda-${var.PlaygroundName}-voting"
  security_group_ids = [module.network[count.index].allow_all_security_group_id]
  subnet_id          = module.network[count.index].public_subnets.0
  instance_type      = var.instance_type
  user_data = templatefile(
    "${var.scriptLocation}/puppet_agent.sh",
    {
      hostname          = "${var.PlaygroundName}-voting-${element(local.adj, count.index)}-panda"
      username          = "voting"
      ssh_pass          = "playground"
      region            = var.region
      gitrepo           = "https://github.com/chilcano/mtls-emojivoto-tf.git"
      puppet_hostname   = "${var.PlaygroundName}-puppet-${element(local.adj, count.index)}-panda"
    }
  )
  amiName   = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
  amiOwner  = "099720109477"
}

module "dns_puppet" {
  depends_on   = [module.puppet]
  count        = var.deploy_count
  source       = "./modules/dns"
  instances    = var.instances
  instance_ips = element(module.puppet.*.public_ips, count.index)
  domain_name  = var.domain_name
  record_name  = "${var.PlaygroundName}-puppet-${element(local.adj, count.index)}-panda"
}

module "dns_ca" {
  count        = var.deploy_count
  source       = "./modules/dns"
  instances    = var.instances
  instance_ips = element(module.ca.*.public_ips, count.index)
  domain_name  = var.domain_name
  record_name  = "${var.PlaygroundName}-ca-${element(local.adj, count.index)}-panda"
}

module "dns_web" {
  count        = var.deploy_count
  source       = "./modules/dns"
  instances    = var.instances
  instance_ips = element(module.web.*.public_ips, count.index)
  domain_name  = var.domain_name
  record_name  = "${var.PlaygroundName}-web-${element(local.adj, count.index)}-panda"
}

module "dns_emoji" {
  count        = var.deploy_count
  source       = "./modules/dns"
  instances    = var.instances
  instance_ips = element(module.emoji.*.public_ips, count.index)
  domain_name  = var.domain_name
  record_name  = "${var.PlaygroundName}-emoji-${element(local.adj, count.index)}-panda"
}

module "dns_voting" {
  count        = var.deploy_count
  source       = "./modules/dns"
  instances    = var.instances
  instance_ips = element(module.voting.*.public_ips, count.index)
  domain_name  = var.domain_name
  record_name  = "${var.PlaygroundName}-voting-${element(local.adj, count.index)}-panda"
}
