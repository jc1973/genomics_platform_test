#--------------------------------------------------------------
# Provider
#--------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

#--------------------------------------------------------------
# Pin terraform version
#--------------------------------------------------------------

terraform {
  required_version = "= 1.2.9"
}

