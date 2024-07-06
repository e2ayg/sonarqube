variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "region" {
  type    = string
  default = "us-west-2"
}

variable "allowed_ip" {
  description = "IP addresses allowed to access the ALB"
  type        = string
}

variable "common_tags" {
  type = map(string)
  default = {
    "managed_by"  = "Terraform"
    "environment" = "dev"
    "team"        = "goonies"
    "cost_code"   = "42"
  }
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate"
  type        = string
}

variable "route53_zone_id" {
  type        = string
  description = "Route53 Zone ID"
}

variable "domain_name" {
  type        = string
  description = "Domain name"
}

variable "email" {
  type        = string
  description = "Email address to use for alerts"
}