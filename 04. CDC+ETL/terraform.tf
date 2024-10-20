terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.72.1"
    }
  }
}

provider "aws" {
  profile = "tf-minhojang"
  region = "ap-northeast-2"
}