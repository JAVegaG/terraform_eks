terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"

  cloud {
    organization = "aws-applaudo-devops"

    workspaces {
      tags = [
        "aws-workspaces"
      ]
    }

  }

}

provider "aws" {
  region = var.region
}

resource "random_id" "name" {
  byte_length = 4
}
