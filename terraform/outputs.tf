output "alb_dns_name" {
  value = module.compute.alb_dns_name
}

output "ecr_repository_url" {
  value = module.compute.ecr_repository_url
}

output "autoscaling_group_name" {
  value = module.compute.autoscaling_group_name
}

output "redis_endpoint" {
  value = module.storage.redis_endpoint
}

output "cloudfront_distribution_id" {
  value = module.storage.cloudfront_distribution_id
}

output "cloudfront_domain_name" {
  value = module.storage.cloudfront_domain_name
}

output "s3_bucket_name" {
  value = module.storage.s3_bucket_name
}

output "s3_website_url" {
  value = module.storage.s3_website_endpoint
}

output "nat_gateway_public_ip" {
  description = "Add to MongoDB Atlas Network Access allowlist."
  value       = module.networking.nat_gateway_public_ip
}