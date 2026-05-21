#!/bin/bash
set -uxo pipefail
exec > >(tee /var/log/user-data.log) 2>&1

yum update -y
yum install -y docker

systemctl enable docker
systemctl start docker

mkdir -p /home/ec2-user/app
echo '${backend_env_b64}' | base64 -d > /home/ec2-user/app/.env
chmod 600 /home/ec2-user/app/.env

aws ecr get-login-password --region ${aws_region} \
  | docker login --username AWS --password-stdin ${ecr_repository_url}

IMAGE="${ecr_repository_url}:latest"
for attempt in 1 2 3 4 5; do
  if docker pull "$IMAGE"; then
    break
  fi
  echo "docker pull failed (attempt $attempt); retrying in 60s..."
  sleep 60
done

docker stop backend 2>/dev/null || true
docker rm backend 2>/dev/null || true

docker run -d \
  --name backend \
  -p 8080:8080 \
  --restart unless-stopped \
  --env-file /home/ec2-user/app/.env \
  "$IMAGE"

for i in $(seq 1 36); do
  if curl -sf http://127.0.0.1:8080/ping >/dev/null; then
    echo "API ready after $${i} attempt(s)"
    docker logs backend 2>&1 | tail -20
    exit 0
  fi
  echo "Waiting for API (attempt $${i}/36)..."
  docker ps -a || true
  docker logs backend 2>&1 | tail -15 || true
  sleep 10
done

echo "ERROR: API did not respond on /ping — check MongoDB Atlas allowlist for NAT IP and docker logs"
docker logs backend 2>&1 | tail -50 || true
exit 1
