terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.42.0"
    }
  }
  backend "s3" {
    bucket  = "course-project-terrform"
    encrypt = true
    key     = "terraform/eks/terraform.tfstate"
    region  = "us-east-1"
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
  default_tags {
    tags = {
      Owner = "kumaprap"
    }
  }
}
