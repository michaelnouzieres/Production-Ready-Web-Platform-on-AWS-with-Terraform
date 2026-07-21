output "iam_instance_profile_name" {
  description = "The profile for the EC2 instance to connect to SSM"
  value = aws_iam_instance_profile.ec2_ssm_profile.name
}

output "iam_instance_profile_arn" {
  description = "The profile arn for the EC2 instance to connect to SSM"
  value = aws_iam_instance_profile.ec2_ssm_profile.arn
}