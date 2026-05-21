#!/usr/bin/env bash
# Quick checks after terraform apply + instance refresh
set -euo pipefail

REGION="${AWS_REGION:-us-east-1}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

cd "$ROOT/terraform"
ALB="$(terraform output -raw alb_dns_name)"
NAT="$(terraform output -raw nat_gateway_public_ip)"
ASG="$(terraform output -raw autoscaling_group_name)"

echo "=== Outputs ==="
echo "ALB:  $ALB"
echo "NAT:  $NAT  (allowlist in MongoDB Atlas)"
echo "ASG:  $ASG"
echo ""

echo "=== Target health ==="
TG_ARN=$(aws elbv2 describe-target-groups --names backend-target-group --region "$REGION" --query 'TargetGroups[0].TargetGroupArn' --output text)
aws elbv2 describe-target-health --target-group-arn "$TG_ARN" --region "$REGION" \
  --query 'TargetHealthDescriptions[*].{Instance:Target.Id,State:TargetHealth.State,Reason:TargetHealth.Reason}' \
  --output table

echo ""
echo "=== ALB /ping ==="
curl -sf -w "\nHTTP %{http_code}\n" "http://${ALB}/ping" || echo "FAILED (502 = no healthy targets; fix Atlas + instance refresh)"

echo ""
echo "=== ECR images ==="
aws ecr describe-images --repository-name assessment-backend --region "$REGION" \
  --query 'imageDetails | length(@)' --output text
