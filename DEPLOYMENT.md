# Deployment secrets and troubleshooting

After `terraform apply`, sync these values into the **application repo** GitHub Actions secrets:

| Secret | Terraform output | Example format |
|--------|------------------|----------------|
| `ALB_DNS_NAME` | `alb_dns_name` | `backend-alb-2015891018.us-east-1.elb.amazonaws.com` (hostname only, no `http://`) |
| `ECR_REPOSITORY` | `ecr_repository_url` | `444166849648.dkr.ecr.us-east-1.amazonaws.com/assessment-backend` |
| `ASG_NAME` | `autoscaling_group_name` | `terraform-20260521145317886600000009` |

**Important:** After every `terraform destroy` + `apply`, the ALB DNS name changes. Update `ALB_DNS_NAME` or smoke tests will hit a dead hostname.

## MongoDB Atlas

EC2 instances reach the internet via the NAT gateway. Allow that IP in Atlas:

```bash
terraform -chdir=terraform output -raw nat_gateway_public_ip
```

Atlas → Network Access → Add IP Address → paste the NAT public IP (or `0.0.0.0/0` for dev only).

## 502 Bad Gateway

The ALB returns 502 when **no healthy targets** are registered. Common causes:

1. Wrong env vars in EC2 user-data (must match Go `config.go`: `JWT_SECRET_KEY`, `REDIS_ADDR`, `DB_NAME`, not `JWT_SECRET` / `REDIS_HOST`).
2. App exits on startup if MongoDB is unreachable (Atlas IP not allowlisted).
3. ECR image missing or instance refresh not run after push.

## Backend CI/CD smoke test

The workflow curls `/health`, which returns **503** if MongoDB or Redis checks fail, even when the server is up.

Either:

- Allowlist the NAT IP in Atlas (recommended), or
- Change the smoke test URL to `/ping` (always 200 when the API process is listening):

```yaml
HEALTH_URL="http://${ALB_HOST}/ping"
```

ALB target health checks use `/ping` in Terraform.

## CloudFront AccessDenied

Fixed by Origin Access Control (OAC) + S3 bucket policy in `terraform/modules/storage/cloudfront.tf`. Run `terraform apply`, then upload the frontend build to the S3 bucket from your frontend pipeline.
