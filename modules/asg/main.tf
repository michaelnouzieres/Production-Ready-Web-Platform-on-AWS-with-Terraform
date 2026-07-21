
### Defining AMI to use

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["137112412989"] # ID AWS
  filter {
    name   = "name"
    values = ["al2023-*-x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}


### Defining Launch Template

resource "aws_launch_template" "web_wordpress_lt" {
  name_prefix   = "web_wordpress_lt"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 30 # 30 GB prevents disk exhaustion
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # Enforces IMDSv2
    http_put_response_hop_limit = 2          # <-- MUST BE 2 for SSM to retrieve credentials
  }
  iam_instance_profile {
    arn = var.iam_instance_profile_arn
  }

  user_data = base64encode(templatefile("${path.root}/wordpress.sh.tpl", {
    db_name     = var.db_name
    db_user     = var.db_user
    db_password = var.db_password
    db_endpoint = var.db_endpoint
  }))

  vpc_security_group_ids = [var.vpc_security_group_ids]
}

### Defining auto scaling group

resource "aws_autoscaling_group" "web_wordpress_asg" {
 vpc_zone_identifier = var.private_subnets_ids
  desired_capacity   = var.asg_desired
  max_size           = var.asg_max_size
  min_size           = var.asg_min_size

  target_group_arns = [var.tg_arn]
  health_check_type = "ELB"
  health_check_grace_period = 600



  launch_template {
    id      = aws_launch_template.web_wordpress_lt.id
    version = "$Latest"
  }
}