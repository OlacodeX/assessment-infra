output "alb_dns_name" {
  value = aws_lb.backend.dns_name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.backend.repository_url
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.backend.name
}

output "alb_arn_suffix" {
  value = aws_lb.backend.arn_suffix
}

output "scale_out_policy_arn" {
  value = aws_autoscaling_policy.scale_out.arn
}

output "scale_in_policy_arn" {
  value = aws_autoscaling_policy.scale_in.arn
}