
#CPU Utilization Alarm 

resource "aws_cloudwatch_metric_alarm" "asg_cpu_alarm" {
  alarm_name          = "asg-high-cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  actions_enabled = true
  
  # References the SNS topic created above
  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn] 
}

#5xx Errors Alarm

resource "aws_cloudwatch_metric_alarm" "alb_5xx_alarm" {
  alarm_name          = "alb-error-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 100

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  actions_enabled = true
  
  # References the SNS topic created above
  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn] 

  # Recommendation: Don't alert if there is no traffic (prevents false alarms)
  treat_missing_data = "notBreaching" 
}
