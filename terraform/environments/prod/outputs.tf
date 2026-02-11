output "vpc_id" {
  value = module.networking.vpc_id
}

output "rds_endpoint" {
  value = module.rds.endpoint
}

output "patient_service_ecr" {
  value = module.ecr.patient_service_repository_url
}

output "appointment_service_ecr" {
  value = module.ecr.appointment_service_repository_url
}

output "patient_portal_ecr" {
  value = module.ecr.patient_portal_repository_url
}

output "shared_alb_dns" {
  value = module.networking.alb_dns_name
}
