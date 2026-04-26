terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.42.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }
  }
  backend "s3" {
    bucket  = "course-project-terrform"
    encrypt = true
    key     = "terraform/monitoring/terraform.tfstate"
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

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks_cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks_cluster.token
  }
}

variable "region" {
    description = "AWS region to deploy resources"
    default     = "us-east-1"
}

data "aws_eks_cluster" "eks_cluster" {
  name = local.cluster_name
}   

data "aws_eks_cluster_auth" "eks_cluster" {
  name = local.cluster_name
}