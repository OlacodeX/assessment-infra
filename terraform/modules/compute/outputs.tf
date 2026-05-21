output "alb_dns_name" {
  value = aws_lb.backend.dns_name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.backend.repository_url
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.backend.name
}