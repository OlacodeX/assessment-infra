variable "project_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "asg_name" {
  type = string
}

variable "alb_arn_suffix" {
  type = string
}

variable "redis_cluster_id" {
  type = string
}

variable "scale_out_policy_arn" {
  type = string
}

variable "scale_in_policy_arn" {
  type = string
}
