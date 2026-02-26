# Networking Module
module "networking" {
  source = "../../modules/networking"

  environment          = var.environment
  app_name             = var.app_name
  vpc_cidr             = var.vpc_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  existing_vpc_id      = var.existing_vpc_id
  public_subnet_ids    = var.public_subnet_ids
  private_subnet_ids   = var.private_subnet_ids
}
/*
# ECR Repositories
module "ecr" {
  source = "../../modules/ecr"

  repository_names = [
    "patientservice",
    "appointmentservice",
    "patientportal",
    "snapshot/patientservice",
    "snapshot/appointmentservice",
    "snapshot/patientportal"
  ]
}
*/
# Secrets Manager
module "secrets" {
  source = "../../modules/secrets"

  environment = var.environment
  app_name    = var.app_name
}

# RDS MySQL Database
module "rds" {
  source = "../../modules/rds"

  environment            = var.environment
  app_name               = var.app_name
  db_subnet_group_name   = module.networking.db_subnet_group_name
  vpc_security_group_ids = [module.networking.rds_security_group_id]

  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  backup_retention_period = var.db_backup_retention_period

  depends_on = [module.secrets]
}

# ECS Cluster & Services
module "ecs_patient_service" {
  source = "../../modules/ecs"

  app_name       = var.app_name
  environment    = var.environment
  service_name   = "patient-service"
  container_port = 3001

  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  private_subnet_ids    = module.networking.private_subnet_ids
  alb_security_group_id = module.networking.alb_security_group_id
  ecs_security_group_id = module.networking.ecs_security_group_id

  ecr_repository_url = var.patient_service_ecr_url
  image_tag          = var.patient_service_image_tag
  task_cpu           = var.ecs_task_cpu
  task_memory        = var.ecs_task_memory
  desired_count      = var.ecs_service_desired_count
  execution_role_arn = var.shared_execution_role_arn
  task_role_arn      = var.shared_execution_role_arn
  container_environment = {
    NODE_ENV         = "production"
    PORT             = "3001"
    SERVICE_NAME     = "patient-service"
    AUTO_SYNC_SCHEMA = "true"
    DB_DIALECT       = "mysql"
    DB_HOST          = split(":", module.rds.endpoint)[0]
    DB_PORT          = "3306"
    DB_NAME          = module.rds.database_name
    DB_USER          = "admin"
    API_PREFIX       = "/api/v1"
  }
  container_secrets = {
    DB_PASSWORD = module.rds.db_password_secret_arn
    JWT_SECRET  = module.secrets.jwt_secret_arn
  }
  health_check_path           = "/api/v1/health"
  alb_listener_arn            = module.networking.alb_listener_arn
  listener_rule_priority      = 20
  listener_rule_path_patterns = ["/api/v1/patients*", "/api/v1/doctors*", "/api/v1/health*"]

  depends_on = [aws_ecs_cluster.main, module.rds]
}

module "ecs_appointment_service" {
  source = "../../modules/ecs"

  app_name       = var.app_name
  environment    = var.environment
  service_name   = "appointment-service"
  container_port = 3002

  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  private_subnet_ids    = module.networking.private_subnet_ids
  alb_security_group_id = module.networking.alb_security_group_id
  ecs_security_group_id = module.networking.ecs_security_group_id

  ecr_repository_url = var.appointment_service_ecr_url
  image_tag          = var.appointment_service_image_tag
  task_cpu           = var.ecs_task_cpu
  task_memory        = var.ecs_task_memory
  desired_count      = var.ecs_service_desired_count
  execution_role_arn = var.shared_execution_role_arn
  task_role_arn      = var.shared_execution_role_arn
  container_environment = {
    NODE_ENV         = "production"
    PORT             = "3002"
    SERVICE_NAME     = "appointment-service"
    AUTO_SYNC_SCHEMA = "true"
    DB_DIALECT       = "mysql"
    DB_HOST          = split(":", module.rds.endpoint)[0]
    DB_PORT          = "3306"
    DB_NAME          = module.rds.database_name
    DB_USER          = "admin"
    API_PREFIX       = "/api/v1"
  }
  container_secrets = {
    DB_PASSWORD = module.rds.db_password_secret_arn
    JWT_SECRET  = module.secrets.jwt_secret_arn
  }
  health_check_path           = "/api/v1/health"
  alb_listener_arn            = module.networking.alb_listener_arn
  listener_rule_priority      = 10
  listener_rule_path_patterns = ["/api/v1/appointments*", "/api/v1/slots*"]

  depends_on = [aws_ecs_cluster.main, module.rds]
}

module "ecs_patient_portal" {
  source = "../../modules/ecs"

  app_name       = var.app_name
  environment    = var.environment
  service_name   = "patient-portal"
  container_port = 80

  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  private_subnet_ids    = module.networking.private_subnet_ids
  alb_security_group_id = module.networking.alb_security_group_id
  ecs_security_group_id = module.networking.ecs_security_group_id

  ecr_repository_url = var.patient_portal_ecr_url
  image_tag          = var.patient_portal_image_tag
  task_cpu           = var.ecs_task_cpu
  task_memory        = var.ecs_task_memory
  desired_count      = var.ecs_service_desired_count
  execution_role_arn = var.shared_execution_role_arn
  task_role_arn      = var.shared_execution_role_arn
  container_environment = {
    NODE_ENV = "production"
  }
  health_check_path           = "/"
  alb_listener_arn            = module.networking.alb_listener_arn
  listener_rule_priority      = 100
  listener_rule_path_patterns = ["/*"]

  depends_on = [aws_ecs_cluster.main]
}

data "aws_iam_role" "shared_execution_role" {
  name = element(reverse(split("/", var.shared_execution_role_arn)), 0)
}

resource "aws_iam_role_policy" "shared_execution_role_secrets_access" {
  name = "${var.app_name}-${var.environment}-ecs-exec-secrets-access"
  role = data.aws_iam_role.shared_execution_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          module.rds.db_password_secret_arn,
          module.secrets.jwt_secret_arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = "*"
      }
    ]
  })
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = var.enable_monitoring ? "enabled" : "disabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name       = aws_ecs_cluster.main.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.app_name}"
  retention_in_days = 30
}
