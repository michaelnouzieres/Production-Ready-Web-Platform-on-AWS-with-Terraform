resource "aws_db_subnet_group" "wp_db_subnet_group" {
  name       = "wordpress-db-subnet-group"
  subnet_ids = var.private_subnet_ids # Replace with your custom VPC's subnet IDs list
  
  tags = {
    Name = "WordPress DB Subnet Group"
  }
}


resource "aws_db_instance" "wp_db" {
  allocated_storage    = 10
  db_name              = "mywpdb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"
  multi_az = true
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.wp_db_subnet_group.name
  vpc_security_group_ids = [var.vpc_sg_db]
}