#!/bin/bash
set -euxo pipefail
exec > >(tee /var/log/user-data.log) 2>&1

yum update -y
yum install -y docker

systemctl enable docker
systemctl start docker

mkdir -p /home/ec2-user/app

cat <<EOF > /home/ec2-user/app/.env
PORT=8080
MONGO_URI=${mongodb_uri}
DB_NAME=${db_name}
JWT_SECRET_KEY=${jwt_secret}
ENABLE_CACHE=${enable_cache}
REDIS_ADDR=${redis_endpoint}:${redis_port}
LOG_LEVEL=INFO
LOG_FORMAT=json
ALLOWED_ORIGINS=*
EOF

aws ecr get-login-password --region ${aws_region} \
  | docker login --username AWS --password-stdin ${ecr_repository_url}

for attempt in 1 2 3 4 5; do
  if docker pull ${ecr_repository_url}:latest; then
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
  ${ecr_repository_url}:latest

sleep 15
curl -sf http://localhost:8080/ping

yum install -y amazon-cloudwatch-agent

cat <<EOF > /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/user-data.log",
            "log_group_name": "/assessment/backend",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
EOF

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json \
  -s
