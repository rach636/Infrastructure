terraform {
  backend "s3" {
    bucket         = "scorpiobackendterraform"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
