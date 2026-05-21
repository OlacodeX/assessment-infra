# Assessment Infrastructure and CI/CD Platform

## Project Overview

This repository contains the complete infrastructure and CI/CD implementation for the StartTech full-stack application.

The solution automates infrastructure provisioning, frontend deployment, backend deployment, monitoring, logging, and scaling using AWS cloud services, Terraform, Docker, and GitHub Actions.

---

# Architecture Summary

The platform consists of:

* React frontend hosted on AWS S3
* CloudFront CDN for frontend delivery
* Golang backend running in Docker containers on EC2
* Auto Scaling Group for backend scalability
* Application Load Balancer for traffic routing
* Redis ElastiCache for caching and sessions
* MongoDB Atlas for database persistence
* CloudWatch for centralized monitoring and logging
* GitHub Actions for CI/CD automation

---

# Repository Structure

```text
assessment-infra/
├── .github/
│   └── workflows/
│       └── infrastructure-deploy.yml
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example
│   └── modules/
│       ├── networking/
│       ├── compute/
│       ├── storage/
│       └── monitoring/
├── scripts/
│   └── deploy-infrastructure.sh
├── monitoring/
│   ├── cloudwatch-dashboard.json
│   ├── alarm-definitions.json
│   └── log-insights-queries.txt
├── README.md
├── ARCHITECTURE.md
└── RUNBOOK.md
```

---

# AWS Services Used

| Service                   | Purpose                     |
| ------------------------- | --------------------------- |
| EC2                       | Backend application hosting |
| Auto Scaling Group        | Backend scaling             |
| Application Load Balancer | Traffic distribution        |
| S3                        | Frontend static hosting     |
| CloudFront                | CDN                         |
| ECR                       | Docker image storage        |
| ElastiCache Redis         | Caching                     |
| CloudWatch                | Monitoring and logging      |
| IAM                       | Access control              |
| VPC                       | Networking                  |
| MongoDB Atlas             | Database                    |

---

# Infrastructure Components

## Networking

The infrastructure creates:

* Custom VPC
* Public subnets
* Private subnets
* Internet Gateway
* Security Groups

---

## Frontend Infrastructure

### S3 Bucket

Stores React production build files.

### CloudFront Distribution

Serves frontend globally with CDN acceleration.

---

## Backend Infrastructure

### Application Load Balancer

Routes incoming traffic to backend EC2 instances.

### Launch Template

Defines EC2 instance configuration and startup automation.

### Auto Scaling Group

Maintains healthy backend instances and supports automatic scaling.

### Amazon ECR

Stores backend Docker images pushed from GitHub Actions.

---

## Data Layer

### MongoDB Atlas

Primary persistent database.

### Redis ElastiCache

Handles caching and sessions.

---

# CI/CD Pipelines

GitHub Actions automates deployments for both frontend and backend applications.

---

# Frontend Pipeline

Frontend deployment process:

1. Checkout code
2. Install Node.js dependencies
3. Run npm audit security scan
4. Run frontend tests
5. Build React production bundle
6. Upload build files to S3
7. Invalidate CloudFront cache

Frontend deployment target:

* AWS S3
* AWS CloudFront

---

# Backend Pipeline

Backend deployment process:

1. Checkout code
2. Setup Golang environment
3. Run Go tests
4. Run Golang lint checks
5. Build Docker image
6. Scan image using Trivy
7. Push image to Amazon ECR
8. Trigger Auto Scaling Group instance refresh
9. Run smoke tests against ALB endpoint

Backend deployment target:

* EC2 Auto Scaling Group

---

# Terraform Setup

## Initialize Terraform

```bash
terraform init
```

---

## Validate Terraform

```bash
terraform validate
```

---

## Review Plan

```bash
terraform plan
```

---

## Deploy Infrastructure

```bash
terraform apply
```

---

# Terraform Variables

Create:

```text
terraform.tfvars
```

Example:

```hcl
aws_region  = "us-east-1"

mongodb_uri = "mongodb+srv://USERNAME:PASSWORD@cluster.mongodb.net/assessment"

jwt_secret  = "your_secure_secret"
```

---

# GitHub Secrets

The following GitHub repository secrets are required.

## AWS Credentials

| Secret                | Description    |
| --------------------- | -------------- |
| AWS_ACCESS_KEY_ID     | IAM access key |
| AWS_SECRET_ACCESS_KEY | IAM secret key |

---

## Frontend Secrets

| Secret                     | Description                |
| -------------------------- | -------------------------- |
| S3_BUCKET                  | S3 bucket name             |
| CLOUDFRONT_DISTRIBUTION_ID | CloudFront distribution ID |

---

## Backend Secrets

| Secret         | Description             |
| -------------- | ----------------------- |
| ECR_REPOSITORY | ECR repository URL      |
| ASG_NAME       | Auto Scaling Group name |
| ALB_DNS_NAME   | ALB DNS endpoint        |

---

# Monitoring

Monitoring is implemented using AWS CloudWatch.

Monitoring includes:

* CloudWatch Logs
* CloudWatch Metrics
* CloudWatch Dashboards
* CloudWatch Alarms
* CloudWatch Log Insights queries

Monitoring files are located in:

```text
monitoring/
```

---

# Verification Checklist

## Frontend Verification

* CloudFront URL loads React application
* S3 bucket contains build files
* GitHub Actions frontend pipeline passes

---

## Backend Verification

* ALB health endpoint accessible
* EC2 instances healthy
* Docker container running successfully
* GitHub Actions backend pipeline passes

---

## Monitoring Verification

* CloudWatch log groups receiving logs
* Dashboard metrics visible
* Alarm definitions available

---

# Security Implementation

Security best practices implemented:

* IAM least privilege access
* GitHub Secrets management
* Docker vulnerability scanning
* npm dependency security scanning
* Security Groups for network isolation
* Centralized logging using CloudWatch

---

# Deployment URLs

## Frontend

CloudFront URL:

```text
https://YOUR_CLOUDFRONT_DOMAIN
```

---

## Backend

ALB URL:

```text
http://YOUR_ALB_DNS_NAME/health
```

---

# Cleanup

Destroy infrastructure:

```bash
terraform destroy
```
