# FinFlow — AWS Infrastructure

> AWS infrastructure for FinFlow — a PCI-DSS compliant financial dashboard platform built with Terraform. Designed to scale from 500 to 5,000 business customers using EC2 Auto Scaling, RDS Multi-AZ, ElastiCache Redis, Lambda, and EventBridge.

---

## Overview

FinFlow aggregates financial data from multiple sources — Plaid, QuickBooks, Xero, and Stripe — into a single dashboard for finance managers and business owners. This repository contains the complete AWS infrastructure built with Terraform across 10 modules, supporting separate staging and production environments via tfvars-based configuration.

The architecture was designed to solve four real business problems:

- **Two outages this month** — eliminated via Multi-AZ compute and database with automatic failover
- **8–10 second dashboard load times** — addressed via ElastiCache Redis caching layer and read replica offloading
- **Two months of reports lost to disk failure** — solved by replacing EC2 local disk with S3 (11 nines durability)
- **Zero monitoring** — replaced with CloudWatch alarms, SNS alerting, and CloudTrail audit logging

---

## Architecture
Internet

↓

WAF (blocks threats, SQL injection, IP reputation)

↓

ALB (distributes traffic, terminates SSL, redirects HTTP → HTTPS)

↓

EC2 Auto Scaling Group (application layer, private subnets)

↓              ↓               ↓

Redis           RDS            S3

(Cache)       (Database)      (Reports)
Cognito — handles user authentication

EventBridge — triggers Lambda on schedule

SQS — buffers background jobs

CloudTrail + CloudWatch — observability and audit

---

## Modules

| Module | Resources | Purpose |
|---|---|---|
| vpc | VPC, subnets, IGW, NAT Gateway, route tables, NACLs | Network foundation |
| security | Security groups, NACLs, WAFv2 | Traffic controls |
| iam | IAM role, policies, instance profile | Least privilege EC2 identity |
| compute | ALB, target group, launch template, Auto Scaling | Application layer |
| database | RDS PostgreSQL Multi-AZ, read replica, subnet group | Persistent storage |
| cache | ElastiCache Redis replication group | In-memory caching |
| auth | Cognito user pool, app client | User authentication |
| storage | S3 bucket, versioning, encryption, lifecycle | Report storage |
| serverless | Lambda x3, SQS x2, EventBridge x2, IAM role | Background processing |
| monitoring | CloudWatch alarms, SNS, CloudTrail, log groups | Observability and audit |

---

## Three Lambda Flows

**Flow 1 — Dashboard Load**
SQS → Dashboard Lambda → Redis
Pre-fetches financial data on user login so dashboard loads from cache in under 1ms.

**Flow 2 — Hourly Sync**
EventBridge (rate 1 hour) → Hourly Sync Lambda → RDS
Pulls fresh data from Plaid, QuickBooks, Xero, and Stripe every hour.

**Flow 3 — End of Month Reporting**
EventBridge (cron 1st of month) → Reporting Lambda → S3
Generates PDF financial reports and stores them permanently in S3.

---

## Environment Configuration

| Variable | Staging | Production |
|---|---|---|
| `instance_type` | t3.small | t3.medium |
| `min_size` | 1 | 2 |
| `max_size` | 2 | 6 |
| `db_instance_class` | db.t3.micro | db.t3.medium |
| `node_type` | cache.t3.micro | cache.t3.medium |

Sensitive values (`db_username`, `db_password`, `aws_account_id`) are passed via GitHub Secrets using the `TF_VAR_` prefix and never appear in committed files.

---

## Prerequisites

- Terraform >= 1.7.5
- AWS CLI configured with appropriate credentials
- ACM certificate provisioned in us-east-1 for HTTPS listener
- GitHub Secrets configured: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_ACCOUNT_ID`, `ALERT_EMAIL`, `DB_USERNAME`, `DB_PASSWORD`

---

## Deployment

**Staging plan:**
```bash
terraform init
terraform plan -var-file="staging.tfvars"
```

**Production deploy:**
```bash
terraform init
terraform apply -var-file="production.tfvars"
```

**Destroy:**
```bash
terraform destroy -var-file="staging.tfvars"
```

---

## Security

- All data encrypted at rest and in transit
- EC2 accessed via SSM Session Manager — no bastion host, no open SSH
- WAF rate limiting at 500 requests per IP per 5 minutes
- CloudTrail log file validation detects tampering
- IAM roles follow least privilege throughout

---

## Portfolio Context

| Project | Architecture | Compliance |
|---|---|---|
| MedBridge | VPC, EC2, RDS, Cognito, CloudTrail | HIPAA |
| BetPulse | ECS Fargate, Aurora, ElastiCache, Kinesis | PCI-DSS |
| AgentFlow | Serverless, Lambda, DynamoDB, EventBridge | — |
| FinFlow | Multi-tier, Auto Scaling, Redis, Lambda, CI/CD | PCI-DSS |

---

*Built by Montana Williams — AWS Solutions Architect Associate | Active U.S. Security Clearance*