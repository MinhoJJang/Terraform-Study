terraform {
  required_version = ">= v1.9.5"

  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0" # 틸드 연산자. 5.0.x 버전이 설치된다.
    }
  }
}