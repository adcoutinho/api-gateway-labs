terraform {
  backend "s3" {
    bucket = "adriano-coutinho-bucket"
    key    = "test/applications/kong-ecs/terraform.tfstate"
    region = "us-east-1"
  }
}
