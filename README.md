<<<<<<< HEAD
# Infrastructure
=======
# Hospital Management System - Infrastructure Repository

Complete Infrastructure-as-Code for Docker deployment of Hospital Management System microservices on AWS ECS Fargate with MySQL RDS database.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│              Application Load Balancer                   │
│                   (Public Subnet)                        │
└─────────────────┬───────────────────────────────────────┘
                  │
    ┌─────────────┼─────────────┐
    │             │             │
    ▼             ▼             ▼
┌─────────┐  ┌──────────┐  ┌───────────┐
│Patient  │  │Appt      │  │Frontend   │
│Service  │  │Service   │  │(Nginx)    │
│Fargate  │  │Fargate   │  │Fargate    │
└─────────┘  └──────────┘  └───────────┘
    │             │
    └─────────────┼─────────────┐
                  │             │
                  ▼             ▼
            ┌──────────┐   ┌──────────┐
            │RDS MySQL │   │Secrets   │
            │Database  │   │Manager   │
            └──────────┘   └──────────┘
```

## Directory Structure

```
Infrastructure/
├── terraform/
│   ├── modules/
│   │   ├── ecs/              # ECS Fargate service module
│   │   ├── rds/              # RDS MySQL database module
│   │   ├── ecr/              # ECR container registry module
│   │   ├── networking/       # VPC, subnets, security groups
│   │   └── secrets/          # Secrets Manager for sensitive data
│   ├── environments/
│   │   ├── dev/              # Development environment
│   │   └── prod/             # Production environment
│   └── shared/               # Shared configuration
├── Jenkinsfile               # Jenkins pipeline for infrastructure
└── README.md
```

## Features

✅ **Infrastructure as Code (IaC)** using Terraform
✅ **Multi-Environment Support** (dev, prod)
✅ **ECS Fargate** for serverless containerization
✅ **RDS MySQL** managed database
✅ **Application Load Balancer** for traffic distribution
✅ **Auto Scaling** with capacity providers
✅ **Secrets Management** with AWS Secrets Manager
✅ **CloudWatch** logging and monitoring
✅ **Security** with security groups and IAM roles
✅ **CI/CD Integration** with Jenkins
✅ **State Management** with S3 backend (bucket: scorpiobackendterraform, env-wise)

## Prerequisites

- AWS Account with appropriate permissions
- Terraform >= 1.0
- AWS CLI configured
- GitHub repository with secrets configured

## AWS Secrets Required


Configure the following in Jenkins credentials or environment variables:

```
AWS_ACCOUNT_ID          # Your AWS account ID
AWS_REGION              # AWS region (default: ap-south-1)
SLACK_WEBHOOK           # Optional: For Slack notifications
```

## Terraform Modules

### Networking Module
Creates VPC, subnets, Internet Gateway, security groups for:
- Application Load Balancer
- ECS tasks
- RDS database

### ECR Module
Creates Elastic Container Registry repositories for:
- patient-service
- appointment-service
- frontend

### RDS Module
Creates MySQL 8.0 database instance with:
- Multi-AZ (production)
- Automated backups
- Encrypted storage
- CloudWatch logs

### ECS Module
Creates Fargate services with:
- Task definitions
- Load Balancer integration
- Health checks
- CloudWatch logging
- Auto-scaling

### Secrets Module
Manages sensitive data:
- JWT secrets
- Database credentials
- API keys

## Variables

Key Terraform variables (in `environments/{env}/variables.tf`):

```hcl
aws_region                = "us-east-1"
environment              = "prod"
vpc_cidr                 = "10.0.0.0/16"
ecs_task_cpu             = "256"
ecs_task_memory          = "512"
ecs_service_desired_count = 2
db_instance_class        = "db.t3.small"
db_allocated_storage     = 100
db_backup_retention_period = 30
```

## Deployment

### Initialize Terraform

```bash
cd terraform/environments/prod
terraform init \
  -backend-config="bucket=scorpiobackendterraform" \
  -backend-config="key=prod/terraform.tfstate" \
  -backend-config="region=ap-south-1" \
  -backend-config="dynamodb_table=terraform-locks"
```

### Plan Deployment

```bash
terraform plan -out=tfplan
```

### Apply Configuration

```bash
terraform apply tfplan
```

### Destroy Environment

```bash
terraform destroy
```


## CI/CD Pipeline

The Jenkins pipeline (`Jenkinsfile`) automatically:

1. **Plan** - Validates Terraform and creates execution plan
2. **Apply** - Applies changes to dev or prod environment (manual approval for prod)
3. **Notify** - Sends deployment status notifications (optional)

### Pipeline Triggers

- Automatic on push to `main` branch (if configured in Jenkins)
- Manual approval for production deployments
- Validates all Terraform changes in PRs (if configured)

## Outputs

After deployment, retrieve outputs:

```bash
cd terraform/environments/prod
terraform output -json
```

Key outputs:
- Load Balancer DNS name
- RDS endpoint
- ECR repository URLs
- VPC/Subnet IDs

## Security Best Practices

✅ State file encrypted in S3 with versioning
✅ DynamoDB lock table prevents concurrent modifications
✅ IAM roles follow least-privilege principle
✅ Secrets stored in AWS Secrets Manager
✅ Security groups restrict traffic
✅ RDS encrypted with KMS
✅ VPC with private subnets for services
✅ No hardcoded credentials

## Monitoring

### CloudWatch

- Log groups for each service
- Metrics from ECS Task and RDS
- Custom dashboard (optional)

### Health Checks

- ALB checks services every 30 seconds
- ECS replaces unhealthy tasks
- RDS enhanced monitoring

## Cost Optimization

- Fargate Spot instances for non-critical tasks
- Reserved capacity for baseline
- Auto-scaling based on metrics
- RDS burst capability

## Troubleshooting

### Terraform State Issues
```bash
terraform state list
terraform state show aws_ecs_service.patient_service
```

### View Logs
```bash
aws logs tail /ecs/patient-service --follow
```

### Check ECS Tasks
```bash
aws ecs describe-services --cluster hospital-prod-cluster --services patient-service
```

### Database Connectivity
```bash
aws rds describe-db-instances --query 'DBInstances[0].Endpoint'
```

## Maintenance

### Update Terraform Version
```bash
terraform version
terraform init -upgrade
```

### State Backup
```bash
aws s3 sync s3://Hospital-Management-TF-STATE ./backup/
```

### Modify Infrastructure
1. Update `.tf` files
2. Run `terraform plan`
3. Review changes
4. Run `terraform apply`
5. Verify in AWS Console

## Scaling

To scale services, update in terraform:

```hcl
ecs_service_desired_count = 5  # Increase from 2 to 5

# Or use auto-scaling policies (to be added)
```

## Next Steps

1. Create S3 state bucket
2. Create DynamoDB locks table
3. Configure GitHub secrets
4. Deploy to development environment
5. Validate all services running
6. Deploy to production

---

**Managed with Terraform - Infrastructure as Code**
>>>>>>> 89b65b0 (Initial commit)
