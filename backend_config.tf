terraform {
  backend "s3" {
    bucket         = "terraform-tfstate-293109759455"
    key            = "jobdoneright-jdr-dns"
    region         = "eu-west-1"
    dynamodb_table = "terraform_locks"
  }
}
