variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "instance_type" {
  type = string
}

variable "mongodb_uri" {
  type = string
}

variable "jwt_secret" {
  type = string
}

variable "redis_port" {
  type = number
}

variable "redis_endpoint" {
  type = string
}

variable "aws_region" {
  type = string
}