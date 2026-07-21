output "vpc_id" {
  description = "Main VPC ID"
  value = aws_vpc.main.id
}

output "public_subnets_ids" {
  description = "Public subnets IDs"
  value = aws_subnet.public[*].id
  
}

output "private_subnets_ids" {
  description = "Private subnets ID"
  value = aws_subnet.private[*].id
}

output "private_db_subnets_ids" {
  description = "Private DB subnets ID"
  value = aws_subnet.private_db[*].id
}