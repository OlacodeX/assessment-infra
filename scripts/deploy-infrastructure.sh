#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/terraform"

if [[ ! -f terraform.tfvars ]]; then
  echo "Create terraform.tfvars from terraform.tfvars.example before deploying."
  exit 1
fi

terraform init
terraform fmt -check -recursive || terraform fmt -recursive
terraform validate

if [[ "${1:-apply}" == "plan" ]]; then
  terraform plan
  exit 0
fi

terraform apply -auto-approve

echo ""
echo "=== Outputs for starttech-application GitHub secrets ==="
echo "ALB_DNS_NAME=$(terraform output -raw alb_dns_name)"
echo "ECR_REPOSITORY=$(terraform output -raw ecr_repository_url)"
echo "ASG_NAME=$(terraform output -raw autoscaling_group_name)"
echo "S3_BUCKET=$(terraform output -raw s3_bucket_name)"
echo "CLOUDFRONT_DISTRIBUTION_ID=$(terraform output -raw cloudfront_distribution_id)"
echo "NAT_IP (Atlas allowlist)=$(terraform output -raw nat_gateway_public_ip)"
