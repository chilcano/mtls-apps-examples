output "zone_id" {
  value       = data.aws_route53_zone.playground_hostedzone.name
  description = "The id of the zone the record is in"
}

output "name" {
  description = "name of dns record created"
  value       = aws_route53_record.instances.*.name
}