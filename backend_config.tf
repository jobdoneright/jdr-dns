# The bucket and lock table this repo used before the 2023 move to Terraform
# Cloud. State moved back here when execution moved to Spacelift.
terraform {
  backend "s3" {
    bucket         = "terraform-tfstate-293109759455"
    key            = "jobdoneright-jdr-dns"
    region         = "eu-west-1"
    dynamodb_table = "terraform_locks"
  }
}
