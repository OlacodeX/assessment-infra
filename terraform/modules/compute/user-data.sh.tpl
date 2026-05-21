#!/bin/bash

yum update -y

yum install docker -y

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

mkdir -p /home/ec2-user/app

cat <<EOF > /home/ec2-user/app/.env
PORT=8080
MONGO_URI=${mongodb_uri}
REDIS_HOST=${redis_endpoint}
REDIS_PORT=${redis_port}
JWT_SECRET=${jwt_secret}
EOF

aws ecr get-login-password --region ${aws_region} \
| docker login \
--username AWS \
--password-stdin ${ecr_repository_url}

docker pull ${ecr_repository_url}:latest

docker stop backend || true
docker rm backend || true

docker run -d \
--name backend \
-p 8080:8080 \
--restart unless-stopped \
--env-file /home/ec2-user/app/.env \
${ecr_repository_url}:latest

yum install amazon-cloudwatch-agent -y

cat <<EOF > /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/home/ec2-user/logs/app.log",
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