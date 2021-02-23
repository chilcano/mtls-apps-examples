output "puppet_ip" {
  value       = module.puppet.*.public_ips
  description = "The IP's of child node instances"
}

output "ca_ip" {
  value = module.ca.*.public_ips
}

output "web_ip" {
  value = module.web.*.public_ips
}

output "emoji_ip" {
  value = module.emoji.*.public_ips
}

output "voting_ip" {
  value = module.voting.*.public_ips
}