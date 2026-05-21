# Assessment Operations Runbook

## Terraform apply

```bash
cd terraform
terraform init
terraform apply
```

## GitHub secrets (app repo)

See [DEPLOYMENT.md](./DEPLOYMENT.md) for `ALB_DNS_NAME`, `ECR_REPOSITORY`, `ASG_NAME`, and Atlas NAT IP.

## After backend CI/CD pushes an image

```bash
aws autoscaling start-instance-refresh \
  --auto-scaling-group-name "$(terraform -chdir=terraform output -raw autoscaling_group_name)" \
  --region us-east-1
```

Verify:

```bash
curl "http://$(terraform -chdir=terraform output -raw alb_dns_name)/ping"
curl "http://$(terraform -chdir=terraform output -raw alb_dns_name)/health"
```
