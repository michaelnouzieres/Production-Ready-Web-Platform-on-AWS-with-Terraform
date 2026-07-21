variable "aws_region" {
  type = string
}

variable "profile" {
  type = string
  default = null
  description = "The local AWS CLI profile to use. Automatically ignored in OIDC environments."
}

variable "availability_zones" {
  type = list(string)
  
}

variable "cidr_block" {
  type = string
  
}

variable "asg_max_size" {
  type = number
  
}

variable "asg_min_size" {
  type = number
}

variable "asg_desired" {
  type = number
}

variable "domain_name" {
  type = string
}

variable "admin_ip" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}