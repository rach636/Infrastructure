output "vpc_id" {
  value = module.networking.vpc_id
}

output "rds_endpoint" {
  value = module.rds.endpoint
}

output "patient_service_ecr" {
  value = var.patient_service_ecr_url
}

output "appointment_service_ecr" {
  value = var.appointment_service_ecr_url
}

output "patient_portal_ecr" {
  value = var.patient_portal_ecr_url
}

output "shared_alb_dns" {
  value = module.networking.alb_dns_name
}
