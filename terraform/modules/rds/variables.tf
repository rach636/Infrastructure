variable "environment" {
  type = string
}

variable "app_name" {
  type = string
}

variable "db_subnet_group_name" {
  type = string
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "engine_version" {
  type = string
}

variable "instance_class" {
  type = string
}

variable "allocated_storage" {
  type = number
}

variable "backup_retention_period" {
  type = number
}

output "endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "database_name" {
  value = aws_db_instance.mysql.db_name
}

output "db_password_secret_arn" {
  value = aws_secretsmanager_secret.db_password.arn
}
