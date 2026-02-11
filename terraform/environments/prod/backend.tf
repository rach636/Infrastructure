terraform {
  backend "s3" {
    bucket  = "Hospital-Management-TF-STATE"
    key     = "prod/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
