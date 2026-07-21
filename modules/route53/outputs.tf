output "zone_id" {
  description = "Hosted Zone ID"
  value = aws_route53_zone.primary.id
}

output "name_servers" {
  description = "Name Servers"
  value = aws_route53_zone.primary.name_servers
}