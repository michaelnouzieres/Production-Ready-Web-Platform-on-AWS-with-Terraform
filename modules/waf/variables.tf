variable "alb_arn" {
  type = string
}

variable "admin_ip" {
  type = string
}

variable "rate_limit" {
  type = number
  default = 500
}