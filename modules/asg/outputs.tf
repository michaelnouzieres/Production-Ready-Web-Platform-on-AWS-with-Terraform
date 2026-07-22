output "asg_name" {
  value = aws_autoscaling_group.web_wordpress_asg.name
  description = "Auto Scaling Group Name"
}