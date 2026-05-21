variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "assessment"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "mongodb_uri" {
  type      = string
  sensitive = true
}

variable "jwt_secret" {
  type      = string
  sensitive = true
}

variable "redis_port" {
  type    = number
  default = 6379
}