output "alb_sg_id" {
  description = "ID du Security Group Load Balancer (ALB)"
  value       = aws_security_group.alb_sg.id
}

output "web_sg_id" {
  description = "ID du Security Group Web WordPress"
  value       = aws_security_group.web_sg.id
}

output "db_sg_id" {
  description = "ID Security Group RDS"
  value       = aws_security_group.db_sg.id
}