variable "tg_arn" {
  type = string
}

variable "private_subnets_ids" {
  type = list(string)
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

variable "iam_instance_profile_arn" {
  type = string
}

variable "vpc_security_group_ids" {
  type = string
}

variable "db_user" {
  type = string
  
}

variable "db_password" {
  type = string
}

variable "db_endpoint" {
  type = string
}

variable "db_name" {
  type = string
}