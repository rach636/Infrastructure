terraform {
  backend "s3" {
    bucket  = "hospital-management-tfstate"
    key     = "prod/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
