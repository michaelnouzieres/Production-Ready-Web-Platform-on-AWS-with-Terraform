resource "aws_ec2_serial_console_access" "this" {

enabled = true

}

module "networking" {
  source = "./modules/networking"
  availability_zones = var.availability_zones
  cidr_block = var.cidr_block
}

module "sg" {
  source = "./modules/sg"
  vpc_id = module.networking.vpc_id
  
}

module "db" {
  source = "./modules/db"
  vpc_sg_db = module.sg.db_sg_id
  private_subnet_ids = module.networking.private_db_subnets_ids
  db_password = var.db_password
  db_username = var.db_username
  
}

module "iam" {
  source = "./modules/iam"
}

module "compute" {
 source = "./modules/compute"
}

module "alb" {
  source = "./modules/alb"
  alb_sg_id = module.sg.alb_sg_id
  public_subnets = module.networking.public_subnets_ids
  vpc_id = module.networking.vpc_id
  certificate_arn = module.acm.certificate_arn
}

module "asg" {
  source = "./modules/asg"
  asg_desired = var.asg_desired
  asg_max_size = var.asg_max_size
  asg_min_size = var.asg_min_size
  tg_arn = module.alb.webtg-arns
  private_subnets_ids = module.networking.private_subnets_ids
  iam_instance_profile_arn = module.iam.iam_instance_profile_arn
  vpc_security_group_ids = module.sg.web_sg_id
  db_endpoint = module.db.db_endpoint
  db_name = module.db.db_name
  db_password = module.db.db_password
  db_user = module.db.db_user
}

module "route53" {
  source = "./modules/route53"
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id = module.alb.alb_zone_id
  domain_name = var.domain_name
}

module "acm" {
  source = "./modules/acm"
  zone_id = module.route53.zone_id
  domain_name = var.domain_name
}

module "waf" {
  source = "./modules/waf"
  alb_arn = module.alb.alb_arn
  admin_ip = var.admin_ip
}