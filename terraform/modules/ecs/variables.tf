variable "environment" {
  type = string
}

variable "app_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "container_port" {
  type = number
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "alb_security_group_id" {
  type = string
}

variable "ecs_security_group_id" {
  type = string
}

variable "ecr_repository_url" {
  type = string
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "task_cpu" {
  type = string
}

variable "task_memory" {
  type = string
}

variable "desired_count" {
  type = number
}

variable "execution_role_arn" {
  type    = string
  default = null
}

variable "task_role_arn" {
  type    = string
  default = null
}

variable "container_environment" {
  type    = map(string)
  default = {}
}

variable "container_secrets" {
  type    = map(string)
  default = {}
}

variable "health_check_path" {
  type    = string
  default = "/api/v1/health"
}

variable "health_check_matcher" {
  type    = string
  default = "200-399"
}

variable "alb_listener_arn" {
  type    = string
  default = null
}

variable "listener_rule_priority" {
  type    = number
  default = null
}

variable "listener_rule_path_patterns" {
  type    = list(string)
  default = []
}

output "target_group_arn" {
  value = aws_lb_target_group.service.arn
}
