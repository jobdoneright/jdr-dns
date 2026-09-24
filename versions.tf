terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # 1.5.7 is the last open-source Terraform release, and the newest the
  # Spacelift stack's Terraform (FOSS) workflow can run. `~> 1.5.0` stops at
  # 1.6 so a newer local Terraform cannot write state the stack cannot read.
  required_version = "~> 1.5.0"
}
