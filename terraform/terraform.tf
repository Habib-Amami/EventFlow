terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.65.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.8.1"
    }
  }

  required_version = "~> 1.16.3"
}
