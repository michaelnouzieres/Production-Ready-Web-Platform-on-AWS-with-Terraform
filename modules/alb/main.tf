#### Create Application Load Balancer

resource "aws_lb" "alb_wordpress" {
  name = "wordpress-alb"
  load_balancer_type = "application"
  security_groups = [var.alb_sg_id]
  subnets = var.public_subnets
}

#### Create Target Group

resource "aws_lb_target_group" "wordpress-web-tg" {
  name     = "wordpress-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200,301,302"  # <-- This accepts redirects as healthy
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

#### Create HTTP Listener
resource "aws_lb_listener" "wordpress_http_listener" {
  load_balancer_arn = aws_lb.alb_wordpress.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "wordpress_https_listener" {
  load_balancer_arn = aws_lb.alb_wordpress.arn
  port              = 443
  protocol          = "HTTPS"

  
  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  certificate_arn = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress-web-tg.arn
  }
}