# Assessment System Architecture

# Overview

This document explains the architecture of the StartTech full-stack platform and the DevOps implementation used for deployment, scalability, monitoring, and automation.

The platform uses AWS cloud infrastructure provisioned with Terraform and deployed through GitHub Actions CI/CD pipelines.

---

# High-Level Architecture

```text
Users
   │
   ▼
CloudFront CDN
   │
   ▼
S3 Static Website Hosting
   │
   ▼
Frontend React Application
   │
   ▼
Application Load Balancer
   │
   ▼
EC2 Auto Scaling Group
   │
   ▼
Dockerized Golang Backend
   │
   ├──────────► Redis ElastiCache
   │
   └──────────► MongoDB Atlas
```

---

# Frontend Architecture

## React Application

The frontend is built using React.

The React application is compiled into static production files during the CI/CD process.

---

## S3 Static Hosting

The React build output is uploaded to AWS S3.

S3 stores:

* HTML
* CSS
* JavaScript
* Static assets

---

## CloudFront CDN

CloudFront provides:

* Global CDN delivery
* Lower latency
* HTTPS support
* Content caching

Users access the frontend through CloudFront.

---

# Backend Architecture

## Golang API

The backend API is written in Go (Golang).

The backend provides:

* REST API endpoints
* Authentication
* Database access
* Redis caching
* Health endpoints

---

## Docker Containerization

The backend application is packaged as a Docker image.

The image is:

1. Built in GitHub Actions
2. Pushed to Amazon ECR
3. Pulled automatically by EC2 instances

---

## EC2 Auto Scaling Group

Backend EC2 instances are managed by an Auto Scaling Group.

Responsibilities:

* Automatic scaling
* High availability
* Self-healing instances
* Rolling deployments

---

## Launch Template

The launch template defines:

* AMI
* EC2 instance type
* IAM instance profile
* Security groups
* User-data startup scripts

User-data automatically:

* Installs Docker
* Authenticates with ECR
* Pulls backend image
* Starts Docker container

---

# Load Balancing

## Application Load Balancer

The ALB distributes incoming traffic across backend EC2 instances.

Features:

* Health checks
* Traffic balancing
* Fault tolerance
* High availability

Health endpoint:

```text
/health
```

---

# Database Layer

## MongoDB Atlas

MongoDB Atlas serves as the primary persistent database.

Stores:

* Users
* Todos
* Sessions
* Application data

MongoDB Atlas was selected because:

* Managed service
* Automatic backups
* Scalability
* High availability

---

## Redis ElastiCache

Redis is used for:

* Caching
* Session storage
* Performance optimization

---

# Infrastructure as Code

## Terraform

Terraform provisions all AWS infrastructure.

Terraform modules used:

| Module     | Purpose               |
| ---------- | --------------------- |
| networking | VPC and subnets       |
| compute    | EC2, ALB, ASG         |
| storage    | S3, CloudFront, Redis |
| monitoring | CloudWatch            |

---

# CI/CD Architecture

## GitHub Actions

GitHub Actions automates deployments.

---

# Frontend Pipeline

Triggered on push to main branch.

Pipeline stages:

1. Install dependencies
2. Run npm audit
3. Run tests
4. Build React application
5. Deploy build files to S3
6. Invalidate CloudFront cache

---

# Backend Pipeline

Triggered on push to main branch.

Pipeline stages:

1. Run Go tests
2. Run lint checks
3. Build Docker image
4. Run Trivy vulnerability scan
5. Push image to ECR
6. Trigger ASG instance refresh
7. Run smoke tests

---

# Monitoring Architecture

## CloudWatch Logs

Centralized logs collected from:

* Backend application
* Docker containers
* EC2 instances

---

## CloudWatch Metrics

Metrics collected:

* CPU utilization
* ALB request count
* HTTP 5XX errors
* Redis performance

---

## CloudWatch Dashboard

Dashboard visualizes:

* EC2 health
* ALB traffic
* Redis metrics
* Error rates

---

# Security Architecture

## IAM Security

Least-privilege IAM roles are used.

---

## Secrets Management

Sensitive values stored in GitHub Secrets:

* AWS credentials
* JWT secrets
* ECR repository URLs

---

## Network Security

Security groups restrict:

* Backend traffic
* ALB access
* Redis access

---

# Deployment Flow

## Frontend Deployment Flow

```text
Developer Push
   │
   ▼
GitHub Actions
   │
   ▼
React Build
   │
   ▼
S3 Upload
   │
   ▼
CloudFront Cache Invalidation
```

---

## Backend Deployment Flow

```text
Developer Push
   │
   ▼
GitHub Actions
   │
   ▼
Go Tests + Lint
   │
   ▼
Docker Build
   │
   ▼
Push to ECR
   │
   ▼
ASG Instance Refresh
   │
   ▼
EC2 Pulls Latest Image
```
