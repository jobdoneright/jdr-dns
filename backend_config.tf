terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.0"
    }
  }

  cloud {
    organization = "jdr1"

    workspaces {
      name = "jdr-dns"
    }
  }
}
