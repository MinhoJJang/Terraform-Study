# Step-by-Step Guide: Managing EC2 Instances Using Variables and Output Values


이번 주차 스터디에서는 Terraform의 핵심 개념인 변수와 출력값에 대해 알아보고, 실제 EC2 인스턴스 생성 및 관리에 적용하는 실습을 진행합니다. 변수와 출력값을 활용하면 코드 재사용성을 높이고, 유연하고 관리하기 쉬운 인프라를 구축할 수 있습니다.

## 1. 변수 (Variables)

### 1.1 개념 및 필요성

변수는 코드 내에서 재사용 가능한 값을 저장하는 공간입니다.  인프라 구성 시 IP 주소, 인스턴스 유형, 리전 등 다양한 값을 하드코딩하는 대신 변수로 정의하면 코드의 가독성과 유지보수성을 높일 수 있습니다. 변수가 없다면 동일한 값을 여러 번 반복해서 작성해야 하고, 값을 변경할 때마다 모든 곳을 수정해야 하는 번거로움이 발생합니다. 변수를 사용하면 값을 한 곳에서 관리하고, 필요에 따라 값을 쉽게 변경할 수 있습니다.

### 1.2 변수 유형 및 선언

Terraform은 다양한 데이터 유형의 변수를 지원합니다 (string, number, bool, list, map 등). 변수는 `variable` 블록을 사용하여 선언하고, `type`과 `default` 키워드를 사용하여 유형과 기본값을 지정할 수 있습니다. `description` 키워드를 사용하여 변수에 대한 설명을 추가할 수도 있습니다.

```
variable "instance_type" {
  type = string
  description = "EC2 인스턴스 유형"
  default = "t2.micro"
}

variable "tags" {
  type = map(string)
  description = "EC2 태그"
  default = {
    Name = "My EC2 Instance"
  }
}
```

### 1.3 변수 입력 및 우선순위

변수 값은 다음과 같은 방법으로 입력할 수 있으며, 우선순위가 높은 값이 적용됩니다.

1. CLI 입력: `terraform plan -var="instance_type=t3.micro"`
2. 환경 변수: `TF_VAR_instance_type=t3.micro terraform plan`
3. 변수 파일: `terraform.tfvars`, `.auto.tfvars`
4. 기본값: `variable` 블록에 지정된 `default` 값

`terraform.tfvars` 파일은 프로젝트의 기본 변수 값을 저장하는 데 사용하고, `*.auto.tfvars` 파일은 환경별 변수 값을 저장하는 데 사용할 수 있습니다 (예: `dev.auto.tfvars`, `prod.auto.tfvars`).

### 1.4 Local Values

`locals` 블록은 모듈 내에서만 사용 가능한 지역 변수를 정의하는 데 사용됩니다. `locals` 블록에 정의된 변수는 외부에서 접근할 수 없으므로, 모듈 내부의 로직을 단순화하고 변수 이름 충돌을 방지하는 데 유용합니다.

```
locals {
  instance_name = "my-ec2-${var.environment}"
}
```

## 2. 출력값 (Output Values)

### 2.1 개념 및 필요성

출력값은 Terraform이 인프라를 생성하거나 변경한 후에 사용자에게 중요한 정보를 제공하는 데 사용됩니다. 예를 들어, EC2 인스턴스의 퍼블릭 IP 주소, 데이터베이스의 연결 문자열 등을 출력값으로 정의할 수 있습니다. 출력값이 없다면 AWS 콘솔이나 CLI를 통해 직접 정보를 확인해야 하는 번거로움이 있습니다.  출력값을 사용하면 필요한 정보를 쉽게 확인하고, 다른 스크립트나 도구에서 활용할 수 있습니다.

### 2.2 출력값 선언 및 사용

출력값은 `output` 블록을 사용하여 선언하고, `value` 키워드를 사용하여 값을 지정합니다. `description` 키워드를 사용하여 출력값에 대한 설명을 추가할 수도 있습니다.  `sensitive = true` 를 설정하면 출력값이 터미널에 표시되지 않도록 할 수 있습니다. 이는 비밀번호나 API 키와 같은 민감한 정보를 출력할 때 유용합니다.  하지만 state 파일에 저장되므로 주의해야합니다.

```
output "public_ip" {
  value = aws_instance.example.public_ip
  description = "EC2 인스턴스의 퍼블릭 IP 주소"
}

output "private_key" {
  value = tls_private_key.example.private_key_pem
  sensitive = true
  description = "EC2 인스턴스의 프라이빗 키"
}

```

출력값은 `terraform output` 명령어를 사용하여 확인할 수 있습니다.

## 3. EC2 인스턴스 생성 및 관리

variable 학습에 초점을 맞추기 위해, 이번 실습에서는 기본 vpc, subnet을 사용하고 data, output, locals, variable.tf, .tfvars 에 집중해서 구성해보았다.

### 3.1 main.tf

```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# 기본 VPC 가져오기
data "aws_vpc" "default" {
  default = true
}

# 기본 서브넷 가져오기
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# EC2 인스턴스 생성
resource "aws_instance" "ec2" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id     = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.mhj-sg-group.id]
  user_data              = file("user_data.sh")

  tags = merge(var.tags, { Name = local.instance_name })

  count = var.instance_count
}

resource "aws_security_group" "mhj-sg-group" {
  vpc_id = data.aws_vpc.default.id
  name = local.sg_name
  description = "EC2 Security Group - mhj"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] 
  security_group_id = aws_security_group.mhj-sg-group.id
}

resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] 
  security_group_id = aws_security_group.mhj-sg-group.id
}

# 출력값 정의
output "public_ips" {
  value       = tolist([for instance in aws_instance.ec2 : instance.public_ip])
  description = "EC2 인스턴스의 퍼블릭 IP 주소 목록"
}

output "private_ips" {
  value       = tolist([for instance in aws_instance.ec2 : instance.private_ip])
  description = "EC2 인스턴스의 프라이빗 IP 주소 목록"
}

locals {
  instance_name = "mhj-ec2-${var.environment}"
  sg_name       = "mhj-sg-${var.environment}"
}

```

### 3.2 variables.tf

```
variable "region" {
  type        = string
  description = "AWS 리전"
  default     = "ap-northeast-2"
}

variable "ami" {
  type        = string
  description = "EC2 AMI ID"
}

variable "instance_type" {
  type        = string
  description = "EC2 인스턴스 유형"
  default = "t2.micro"
}

variable "tags" {
  type = map(string)
  description = "EC2 태그"
  default = {
    Environment = "dev"
  }
}

variable "instance_count" {
  type = number
  default = 1 # default 1로 설정
}

variable "environment" {
  type = string
  default = "dev"
}
```

### 3.3 user_data.sh

```bash
#!/bin/bash
sudo apt update -y
sudo apt install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2

echo "<h1>Hello from $(hostname -f)</h1>" | sudo tee /var/www/html/index.html # public ip로 접속하면, 자신 인스턴스의 private ip 주소가 화면에 뜨도록 구성했다.
```

### 3.4 terraform.tfvars 

```
ami = "ami-05d2438ca66594916" 

instance_count = 2 # 인스턴스 2개 생성, variables.tf 에는 default 1로 설정. 어떤 변수가 우선일까?
```

### 3.5 실행

1. `terraform init`
2. `terraform plan`
3. `terraform apply`
4. `terraform output`
	![](https://velog.velcdn.com/images/minhojjang/post/35fabbb3-3963-4904-aae4-bc581e5e0210/image.png)


### 3.6 결과 확인

#### 3.6.1 변수 우선순위는?

terraform.tfvars에 정의한 인스턴스 개수 2개가 실제로 변수값에 들어간 것을 볼 수 있다. (variables.tf 에는 default 1로 설정됨)


![](https://velog.velcdn.com/images/minhojjang/post/9905afa2-d231-4eb1-b115-b05fbde444d1/image.png)

![](https://velog.velcdn.com/images/minhojjang/post/c614a894-f836-4359-a588-4a35a30490ff/image.png)

#### 3.6.2 로컬 변수는 어떻게 됐을까?

로컬로 선언한 이름이 잘 들어가있는 모습을 확인할 수 있다.
`locals {
  instance_name = "mhj-ec2-${var.environment}" }`

![](https://velog.velcdn.com/images/minhojjang/post/12629639-1dac-4712-a0b6-7559aec2302b/image.png)
