terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # The registry module uses `moved` blocks, which need 1.1.
  required_version = ">= 1.1"

  cloud {
    organization = "jdr1"

    workspaces {
      name = "jdr-dns"
    }
  }
}
