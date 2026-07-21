output "webtg-arns" {
  description = "Outputs the value of the ARN for the ASG to link it"
  value = aws_lb_target_group.wordpress-web-tg.arn
}

output "alb_zone_id" {
  value = aws_lb.alb_wordpress.zone_id
}

output "alb_dns_name" {
  value = aws_lb.alb_wordpress.dns_name
}

output "alb_arn" {
  value = aws_lb.alb_wordpress.arn
  
}