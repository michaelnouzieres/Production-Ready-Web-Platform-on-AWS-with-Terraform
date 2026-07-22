#1 Create SNS topic

resource "aws_sns_topic" "cloudwatch_alarms" {
  name = "cloudwatch-alarms-topic"
}


#2 Create email susbcription to the target
resource "aws_sns_topic_subscription" "cloudwatch_alarms_email_target" {
  topic_arn = aws_sns_topic.cloudwatch_alarms.arn
  protocol  = "email"
  endpoint  = var.email
}