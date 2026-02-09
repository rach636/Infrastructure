terraform {
  backend "s3" {
    bucket         = "scorpiobackendterraform"
    key            = "stage/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
