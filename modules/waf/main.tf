##############################################
# IPsets
##############################################

resource "aws_wafv2_ip_set" "admin_ip" {

  name               = "wordpress-admin-ip"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"

  addresses = [
    var.admin_ip
  ]
}

##############################################
# WEB ACL Rules
##############################################


resource "aws_wafv2_web_acl" "wordpress_acl" {

  name  = "wordpress-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "wordpress-waf"
    sampled_requests_enabled   = true
  }

  
  ############## Allow my IP to wp-admin
  

  rule {

    name     = "AllowMyIPToAdmin"
    priority = 1

    action {
      allow {}
    }

    statement {

      and_statement {

        statement {

          byte_match_statement {

            field_to_match {
              uri_path {}
            }

            positional_constraint = "STARTS_WITH"
            search_string         = "/wp-admin"

            text_transformation {
              priority = 0
              type     = "NONE"
            }

          }

        }

        statement {

          ip_set_reference_statement {
            arn = aws_wafv2_ip_set.admin_ip.arn
          }

        }

      }

    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AllowAdmin"
      sampled_requests_enabled   = true
    }

  }

  ############## Block all the others

  rule {

    name     = "BlockOtherIPsToAdmin"
    priority = 2

    action {
      block {}
    }

    statement {

      and_statement {

        statement {

          byte_match_statement {

            field_to_match {
              uri_path {}
            }

            positional_constraint = "STARTS_WITH"
            search_string         = "/wp-admin"

            text_transformation {
              priority = 0
              type     = "NONE"
            }

          }

        }

        statement {

          not_statement {

            statement {

              ip_set_reference_statement {
                arn = aws_wafv2_ip_set.admin_ip.arn
              }

            }

          }

        }

      }

    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BlockAdmin"
      sampled_requests_enabled   = true
    }

  }

  ############## AWS Common Rules including XSS

  rule {

    name     = "AWSManagedCommonRules"
    priority = 10

    override_action {
      none {}
    }

    statement {

      managed_rule_group_statement {

        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"

      }

    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRules"
      sampled_requests_enabled   = true
    }

  }

  ############## Bock SQL Injections

  rule {

    name     = "AWSManagedSQLi"
    priority = 20

    override_action {
      none {}
    }

    statement {

      managed_rule_group_statement {

        vendor_name = "AWS"
        name        = "AWSManagedRulesSQLiRuleSet"

      }

    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLi"
      sampled_requests_enabled   = true
    }

  }

  ############## Rate limiting /IP

  rule {

    name     = "RateLimit"
    priority = 30

    action {
      block {}
    }

    statement {

      rate_based_statement {

        aggregate_key_type = "IP"

        limit = var.rate_limit

      }

    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimit"
      sampled_requests_enabled   = true
    }

  }

}

##############################################
# ALB Association
##############################################

resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.wordpress_acl.arn
}