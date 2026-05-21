# Deployment checklist

Use this after `terraform apply` and on every infra recreate.

## 1. Terraform outputs → GitHub secrets (app repo)

| Secret | Output command |
|--------|----------------|
| `ALB_DNS_NAME` | `terraform -chdir=terraform output -raw alb_dns_name` |
| `ECR_REPOSITORY` | `terraform -chdir=terraform output -raw ecr_repository_url` |
| `ASG_NAME` | `terraform -chdir=terraform output -raw autoscaling_group_name` |

Use the hostname only for `ALB_DNS_NAME` (no `http://`). Values change after destroy/apply.

## 2. MongoDB Atlas (required — #1 cause of unhealthy targets)

EC2 console logs show the **Docker container crash-looping**: the Go API calls `os.Exit(1)` if MongoDB connect/ping fails at startup, so nothing stays up on port **8080** and ALB `/ping` fails.

**You must allowlist the NAT IP before instance refresh can succeed:**


```bash
terraform -chdir=terraform output -raw nat_gateway_public_ip
```

Atlas → **Network Access** → add that IP. Without this, the Go app exits on startup and targets stay **unhealthy** (502).

## 3. Deploy order

1. `terraform apply` (this repo)
2. Backend CI/CD push to ECR + instance refresh (app repo)
3. Frontend CI/CD upload to S3 + CloudFront invalidation (app repo)

## 4. Health checks (aligned)

| Check | Path | Expects |
|-------|------|---------|
| ALB target group | `/ping` | HTTP 200 |
| Docker HEALTHCHECK (image) | `/health` | 200 (needs DB + cache OK) |
| CI smoke test (recommended) | `/ping` or `/health` | see below |

- **`/ping`**: API process is listening.
- **`/health`**: MongoDB (and Redis if `ENABLE_CACHE=true`) must be reachable; returns **503** otherwise.

For CI, either allowlist Atlas and keep `/health`, or use:

```yaml
HEALTH_URL="http://${ALB_HOST}/ping"
```

## 5. After user-data or launch template changes

```bash
aws autoscaling start-instance-refresh \
  --auto-scaling-group-name "$(terraform -chdir=terraform output -raw autoscaling_group_name)" \
  --region us-east-1
```

## 6. Verify

```bash
curl -v "http://$(terraform -chdir=terraform output -raw alb_dns_name)/ping"
curl -v "http://$(terraform -chdir=terraform output -raw alb_dns_name)/health"
```

Target group should show **healthy** before the ALB stops returning 502.

## 7. CloudFront frontend

OAC + bucket policy are in Terraform. You still need:

- Frontend build uploaded to `s3_bucket_name` output (with `index.html` at bucket root)
- `default_root_object` = `index.html` on the distribution

## 8. EC2 env vars (user-data ↔ Go app)

Must match `Server/MuchToDo/internal/config/config.go`:

- `JWT_SECRET_KEY` (not `JWT_SECRET`)
- `REDIS_ADDR=host:6379` (not `REDIS_HOST` / `REDIS_PORT`)
- `DB_NAME` (default `much_todo_db`)
- `MONGO_URI` quoted in `.env` (special characters in Atlas passwords)

## Stuck instance refresh

If refresh shows `100%` but `Waiting for remaining instances to be available`:

1. Fix Atlas allowlist first.
2. Cancel refresh: `aws autoscaling cancel-instance-refresh --auto-scaling-group-name <ASG> --region us-east-1`
3. `terraform apply` then start a new refresh.

## Troubleshooting unhealthy targets

On an instance (SSM — IAM now includes `AmazonSSMManagedInstanceCore`):


```bash
sudo cat /var/log/user-data.log
sudo docker ps -a
sudo docker logs backend
curl -v http://localhost:8080/ping
```
