# Assessment Operations Runbook

## Terraform apply

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars   # edit with real values
terraform init
terraform apply
```

## GitHub secrets (assessment-application repo)

After apply, set these from Terraform outputs:

| Secret | Command |
|--------|---------|
| `ALB_DNS_NAME` | `terraform output -raw alb_dns_name` |
| `ECR_REPOSITORY` | `terraform output -raw ecr_repository_url` |
| `ASG_NAME` | `terraform output -raw autoscaling_group_name` |
| `S3_BUCKET` | `terraform output -raw s3_bucket_name` |
| `CLOUDFRONT_DISTRIBUTION_ID` | `terraform output -raw cloudfront_distribution_id` |

Use hostname only for `ALB_DNS_NAME` (no `http://`).

## MongoDB Atlas (required)

```bash
terraform output -raw nat_gateway_public_ip
```

Atlas → Network Access → add that IP. Without this, the backend container exits on startup and ALB targets stay unhealthy.

## Instance refresh

```bash
aws autoscaling start-instance-refresh \
  --auto-scaling-group-name "$(terraform output -raw autoscaling_group_name)" \
  --region us-east-1
```

## Verify

```bash
curl "http://$(terraform output -raw alb_dns_name)/health"
```

## Troubleshooting

```bash
sudo cat /var/log/user-data.log
sudo docker ps -a
sudo docker logs backend
curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8080/ping
curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8080/health
```

If logs show `error parsing uri: scheme must be "mongodb"` while `/home/ec2-user/app/.env` looks correct, rebuild and push the backend image after the app config fix (`viper.BindEnv` for `MONGO_URI`, etc.), then run an instance refresh.

SSM is enabled on EC2 (`AmazonSSMManagedInstanceCore`).

## Stuck instance refresh

1. Fix Atlas allowlist.
2. `aws autoscaling cancel-instance-refresh --auto-scaling-group-name <ASG> --region us-east-1`
3. `terraform apply` then start a new refresh.
