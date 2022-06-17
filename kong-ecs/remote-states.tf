data "terraform_remote_state" "test_api_gw_lb" {
  backend = "s3"

  config = {
    region         = "us-east-1"
    bucket         = "adriano-coutinho-bucket"
    key            = "test/applications/shared-lb-internal/terraform.tfstate"
    dynamodb_table = "terraform_locks"
    role_arn       = "arn:aws:iam::643318040211:role/brastemp-cross-account-access"
  }

  workspace = terraform.workspace
}
