####### SG for ALB (Public)
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Allow HTTPS/HTTP inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "alb_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.alb_sg.id
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.alb_sg.id
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  cidr_ipv4 = "0.0.0.0/0"
}



resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_out" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # Allows all outbound traffic
}

####### SG for webserver

resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTPS/HTTP inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "web_sg"
  }
}


resource "aws_vpc_security_group_ingress_rule" "allow_http_alb" {
  security_group_id = aws_security_group.web_sg.id
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  referenced_security_group_id = aws_security_group.alb_sg.id
  
}

resource "aws_vpc_security_group_egress_rule" "allow_https_out" {
  security_group_id = aws_security_group.web_sg.id
  
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  cidr_ipv4 = "0.0.0.0/0"
  
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_web" {
  security_group_id = aws_security_group.web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

####### SG for MYSQL DB

resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  description = "Allow db connection"
  vpc_id      = var.vpc_id

  tags = {
    Name = "db_sg"
  }
}


resource "aws_vpc_security_group_ingress_rule" "allow_http_websg" {
  security_group_id = aws_security_group.db_sg.id
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
  referenced_security_group_id = aws_security_group.web_sg.id  
}
