# Step-by-Step Guide: EC2 Instance Deployment with Terraform

## Step 0. 초기 세팅

### 1. Terraform 설치

https://developer.hashicorp.com/terraform/downloads

설치 후, 터미널에서 `terraform -v` 명령어를 통해 Terraform이 정상적으로 설치되었는지 확인합니다.

![](https://velog.velcdn.com/images/minhojjang/post/2de170cb-3796-4f23-a664-f7b2a6d0e561/image.png)


### 2. aws cli 설치

https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html 

설치 후, 터미널에서 `aws --version` 명령어를 통해 aws cli가 정상적으로 설치되었는지 확인합니다.

![](https://velog.velcdn.com/images/minhojjang/post/fa84c73f-50cd-4d55-9f35-72739edd95b5/image.png)
## Step 1. IAM User 생성

테라폼에서 AWS에 리소스를 프로비저닝하기 위해서는 **어떤 계정으로 리소스를 생성/변경/삭제할 것인지**를 AWS 측에 알려줘야 합니다. IAM User는 이러한 권한을 관리하는 데 사용됩니다.

**IAM User를 생성하는 이유는 root 계정 정보 유출을 막기 위함입니다.** root 계정은 AWS 계정에 대한 모든 권한을 가지고 있기 때문에, 실수로 삭제하거나 중요 정보가 담긴 리소스를 변경할 위험이 있습니다. 따라서, root 계정 대신 제한된 권한을 가진 IAM User를 생성하여 사용하는 것이 안전합니다.

IAM User 생성 과정은 아래와 같습니다.

1. AWS 콘솔에 접속하여 IAM 서비스 페이지로 이동합니다.
2. 사용자 메뉴에서 "사용자 추가" 버튼을 클릭합니다.
3. 사용자 이름을 입력하고 "프로그래밍 방식 액세스" 옵션을 선택합니다.
4. 다음 페이지에서 "권한 직접 연결"을 선택하고 "AdministratorAccess" 정책을 선택합니다.
5. "태그 추가" 페이지는 건너뛰고 "검토" 페이지에서 사용자 정보를 확인한 후 "사용자 생성" 버튼을 클릭합니다.

![](https://velog.velcdn.com/images/minhojjang/post/ba559942-1708-4843-a621-1c3114082a94/image.png)콘솔 접근은 딱히 필요하지 않아서 체크하지 않았다.![](https://velog.velcdn.com/images/minhojjang/post/54106bfe-4ebc-4649-adef-ca08fa9b5e41/image.png)![](https://velog.velcdn.com/images/minhojjang/post/05d6165c-752e-40af-a9f8-27ddb1da7ff7/image.png)

## Step 2. Access Key 생성

생성한 IAM User에 대한 Access Key를 발급합니다. Access Key는 IAM User가 AWS 리소스에 접근할 때 사용하는 인증 정보입니다.

**Access Key는 한 번만 발급되며, 분실 시 다시 확인할 수 없습니다.** 따라서, Access Key ID와 Secret Access Key를 안전하게 보관해야 합니다.

Access Key 생성 과정은 아래와 같습니다.

1. 생성된 IAM User를 클릭합니다.
2. "보안 자격 증명" 탭에서 "액세스 키" 섹션의 "액세스 키 생성" 버튼을 클릭합니다.
3. 팝업 창에서 "CSV 다운로드" 버튼을 클릭하여 Access Key ID와 Secret Access Key를 로컬 컴퓨터에 저장합니다.

![](https://velog.velcdn.com/images/minhojjang/post/ed02fcbd-46a9-4abe-8d13-700d19f38597/image.png)![](https://velog.velcdn.com/images/minhojjang/post/a4c2a178-824c-4aba-86b5-44b2efca700d/image.png)![](https://velog.velcdn.com/images/minhojjang/post/a8e28e0f-2a38-4da7-8cdb-c687112a850c/image.png)![](https://velog.velcdn.com/images/minhojjang/post/0de80564-f732-49cd-b132-4180d7e2c7ef/image.png)


## Step 3. AWS CLI로 정보 등록

다운로드 받은 Access Key 정보를 AWS CLI에 등록합니다. 이렇게 하면 터미널에서 AWS CLI 명령어를 사용할 때, 해당 IAM User로 인증되어 명령어를 실행할 수 있습니다.

```bash
aws configure --profile tf-minhojang

AWS Access Key ID [None]: AKIAUPMYNEE4RBWMZCSL
AWS Secret Access Key [None]:
Default region name [None]: ap-northeast-2
Default output format [None]: json
```

- `-profile tf-minhojang`: `tf-minhojang` 라는 이름으로 프로파일을 생성합니다. 프로파일을 사용하면 여러 AWS 계정을 사용하거나, 하나의 계정에서 여러 IAM User를 사용할 때 편리합니다.
- `AWS Access Key ID`: Step 2에서 발급받은 Access Key ID를 입력합니다.
- `AWS Secret Access Key`: Step 2에서 발급받은 Secret Access Key를 입력합니다.
- `Default region name`: 기본적으로 사용할 AWS 리전을 입력합니다. 여기서는 `ap-northeast-2` (서울 리전)를 사용합니다.
- `Default output format`: AWS CLI 명령어 실행 결과 출력 형식을 지정합니다. 여기서는 `json` 형식을 사용합니다.

## Step 4. EC2 생성할 때 필요한 리소스는?

EC2 인스턴스를 생성하기 위해서는 다음과 같은 리소스들이 필요합니다. 아래 리소스들을 코드로 정의해보도록 하겠습니다.

- **VPC (Virtual Private Cloud):** AWS 클라우드 내에서 논리적으로 분리된 네트워크 공간입니다. EC2 인스턴스를 생성하려면 VPC 내에 위치해야 합니다.
- **IGW (Internet Gateway):** VPC와 인터넷 간의 통신을 가능하게 하는 게이트웨이입니다. EC2 인스턴스가 인터넷에 접속하려면 IGW가 필요합니다.
- **Subnet (서브넷):** VPC 내에서 IP 주소 범위를 세분화한 것입니다. EC2 인스턴스는 특정 서브넷에 연결됩니다. Public Subnet은 IGW를 통해 인터넷에 연결되며, Private Subnet은 인터넷에 직접 연결되지 않습니다.
- **Routing Tables (라우팅 테이블):** 서브넷에서 트래픽을 라우팅하는 방법을 정의합니다. Public Subnet은 IGW를 통해 인터넷으로 트래픽을 라우팅하고, Private Subnet은 NAT Gateway 또는 VPN을 통해 트래픽을 라우팅할 수 있습니다.
- **Security Group (보안 그룹):** EC2 인스턴스에 대한 방화벽 역할을 합니다. 인바운드 및 아웃바운드 트래픽에 대한 규칙을 정의하여 인스턴스를 보호합니다.
- **AMI (Amazon Machine Image):** EC2 인스턴스를 시작하는 데 사용되는 템플릿입니다. 운영 체제, 애플리케이션 서버, 데이터베이스 등이 포함될 수 있습니다.
- **EBS (Elastic Block Storage):** EC2 인스턴스에 연결되는 영구적인 블록 스토리지입니다. 데이터 저장, 애플리케이션 실행 등에 사용됩니다.
- **Instance Type (인스턴스 유형):** EC2 인스턴스의 CPU, 메모리, 스토리지, 네트워크 용량을 정의합니다. 애플리케이션 요구 사항에 맞는 인스턴스 유형을 선택해야 합니다.
- **Key Pair (키 페어):** EC2 인스턴스에 안전하게 연결하기 위해 사용되는 공개 키와 개인 키 쌍입니다.

## Step 5. terraform.tfvars

`terraform.tfvars` 파일은 Terraform 코드에서 사용할 변수 값을 저장하는 파일입니다. 이 파일을 사용하면 코드를 수정하지 않고도 변수 값을 쉽게 변경할 수 있습니다.

`terraform.tfvars` 파일은 `.gitignore`에 등록하여 Git 저장소에 포함되지 않도록 관리해야 합니다. 이는 민감한 정보(예: Access Key, Secret Key 등)가 포함될 수 있기 때문입니다.

```
region = "ap-northeast-2"
project_name = "terraform_project"
target_label = "dev"

### VPC variables
vpc_cidr = "172.100.0.0/16"
public_cidr = ["172.100.0.0/24"]
azs = ["ap-northeast-2a"]

### EC2 variables
ec2_instance_spec = "t2.micro"
```

- `region`: AWS 리전을 지정합니다.
- `project_name`: 프로젝트 이름을 지정합니다.
- `target_label`: 환경을 구분하기 위한 레이블을 지정합니다. (예: dev, stage, prod)
- `vpc_cidr`: VPC의 CIDR 블록을 지정합니다.
- `public_cidr`: Public Subnet의 CIDR 블록을 지정합니다.
- `azs`: VPC를 생성할 가용 영역 목록을 지정합니다.
- `ec2_instance_spec`: EC2 인스턴스 유형을 지정합니다.

## Step 6. variables.tf

`variables.tf` 파일은 `terraform.tfvars` 파일에서 **사용할** 변수를 정의하는 파일입니다. 변수의 데이터 유형, 기본값, 설명 등을 정의할 수 있습니다.terraform.tfvars 파일에서는 이 변수들에 실제 값을 할당합니다. 만약 variables.tf에서 변수를 정의하지 않았다면, terraform.tfvars에서 정의된 값은 사용되지 않습니다.

따라서, variables.tf 파일에서 변수를 선언하지 않으면, terraform.tfvars에서 정의된 변수 값은 사용되지 않습니다.

```
variable "region" {
  description = "aws region"
  type = string
  default = "ap-northeast-2"
}

variable "project_name" {
  description = "project name"
  type = string
  default = null
}

variable "target_label" {
  description = "dev/stage/prod"
  type = string
  default = null
}

variable "vpc_cidr" {
  description = "VPC CIDR Range"
  type = string
  default = null
}

variable "azs" {
    description = "A list of availability zones names or ids in the region"
    type = list(string)
    default = ["ap-northeast-2a"]
}

variable "public_cidr" {
  description = "Public Subnet CIDR"
  type = list(string)
  default = null
}

variable "ec2_instance_spec" {
  description = "EC2 Spec Information"
  type = string
  default = null
}
```

- `variable`: 변수를 정의합니다.
- `description`: 변수에 대한 설명을 작성합니다.
- `type`: 변수의 데이터 유형을 지정합니다.
- `default`: 변수의 기본값을 지정합니다.

## Step 7. provider.tf

`provider.tf` 파일은 Terraform에서 사용할 클라우드 플랫폼 제공자를 정의하는 파일입니다. 여기서는 AWS를 사용하므로 `aws` provider를 정의합니다.

```bash
provider "aws" {
  profile = "tf-minhojang"
  region = "ap-northeast-2"
}
```

- `provider`: 제공자를 정의합니다.
- `profile`: Step 3에서 생성한 AWS CLI 프로파일 이름을 지정합니다.
- `region`: 사용할 AWS 리전을 지정합니다.

## Step 8. main.tf

`main.tf` 파일은 Terraform 코드의 진입점입니다. 이 파일에서 Terraform 버전, 제공자, 모듈 등을 정의합니다.

```bash
terraform {
  required_version = ">= v1.9.5"

  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0" # 틸드 연산자. 5.0.x 버전이 설치된다.
    }
  }
}
```

- `terraform`: Terraform 설정 블록입니다.
- `required_version`: Terraform 버전을 명시합니다. `>= v1.9.5`는 1.9.5 버전 이상을 사용하도록 지정합니다.
- `required_providers`: Terraform 코드에서 사용할 provider를 명시합니다. `hashicorp/aws`는 HashiCorp에서 제공하는 공식 AWS provider이며, `~> 5.0`은 5.0.x 버전을 사용하도록 지정합니다.

## Step 9. vpc.tf

`vpc.tf` 파일은 VPC, Subnet, Internet Gateway 등 네트워크 리소스를 생성하는 코드를 작성하는 파일입니다.

```bash
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "${var.project_name}-${var.target_label}-vpc"

  # vpc cidr 설정
  cidr = var.vpc_cidr

  # VPC 가용영역 설정
  azs = var.azs

  # subnet cidr 설정
  public_subnets = var.public_cidr

  # public ip를 매핑할 것인지 여부
  map_public_ip_on_launch = true

  # 자동으로 인터넷 게이트웨이를 생성하도록 설정
  create_igw = true
}
```

- `module`: Terraform 모듈을 사용합니다. Terraform 모듈은 재사용 가능한 코드 블록입니다. 여기서는 `terraform-aws-modules/vpc/aws` 모듈을 사용하여 VPC를 생성합니다.
- `source`: 모듈의 소스를 지정합니다.
- `version`: 모듈의 버전을 지정합니다.
- `name`: VPC 이름을 지정합니다.
- `cidr`: VPC의 CIDR 블록을 지정합니다.
- `azs`: VPC를 생성할 가용 영역 목록을 지정합니다.
- `public_subnets`: Public Subnet의 CIDR 블록을 지정합니다.
- `map_public_ip_on_launch`: Public Subnet에 생성된 EC2 인스턴스에 Public IP를 할당할지 여부를 지정합니다.
- `create_igw`: Internet Gateway를 생성할지 여부를 지정합니다.

## Step 10. security_group.tf

`security_group.tf` 파일은 EC2 인스턴스에 대한 방화벽 역할을 하는 Security Group을 생성하는 코드를 작성하는 파일입니다.

```bash
resource "aws_security_group" "terraform-ec2-sg" {
  vpc_id = module.vpc.vpc_id
  name = "${var.project_name}-${var.target_label}-sg"
  description = "EC2 Security Group"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group_rule" "terraform-ec2-sg-i" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.terraform-ec2-sg.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "terraform-ec2-ssh-i" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.terraform-ec2-sg.id

  lifecycle {
    create_before_destroy = true
  }
}
```

- `resource`: 리소스를 생성합니다.
    - `aws_security_group`: Security Group을 생성합니다.
        - `vpc_id`: Security Group을 연결할 VPC ID를 지정합니다.
        - `name`: Security Group 이름을 지정합니다.
        - `description`: Security Group에 대한 설명을 작성합니다.
        - `egress`: 아웃바운드 트래픽에 대한 규칙을 정의합니다.
            - `from_port`: 시작 포트 번호를 지정합니다.
            - `to_port`: 종료 포트 번호를 지정합니다.
            - `protocol`: 프로토콜을 지정합니다.
            - `cidr_blocks`: 허용할 IP 주소 범위를 CIDR 표기법으로 지정합니다.
            - `ipv6_cidr_blocks`: IPv6 주소 범위를 CIDR 표기법으로 지정합니다.
    - `aws_security_group_rule`: Security Group 규칙을 생성합니다.
        - `type`: 규칙 유형을 지정합니다. `ingress`는 인바운드 트래픽, `egress`는 아웃바운드 트래픽에 대한 규칙입니다.
        - `from_port`: 시작 포트 번호를 지정합니다.
        - `to_port`: 종료 포트 번호를 지정합니다.
        - `protocol`: 프로토콜을 지정합니다.
        - `cidr_blocks`: 허용할 IP 주소 범위를 CIDR 표기법으로 지정합니다.
        - `security_group_id`: 규칙을 적용할 Security Group ID를 지정합니다.
        - `lifecycle`: 리소스의 라이프사이클을 관리합니다.
            - `create_before_destroy`: 리소스를 삭제하기 전에 새 리소스를 생성합니다. 이 옵션은 Security Group 규칙을 업데이트할 때 유용합니다.

## Step 11. ec2.tf

`ec2.tf` 파일은 EC2 인스턴스를 생성하는 코드를 작성하는 파일입니다.

```bash
resource "aws_instance" "ec2_instance" {
  ami = "ami-05d2438ca66594916"
  instance_type = "${var.ec2_instance_spec}"

  subnet_id = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.terraform-ec2-sg.id]

  associate_public_ip_address = true

  # 키 페어는 사용하지 않으므로, 설정 안함
  # key_name = aws_key_pair.example_key_pair.key_name

  # 인스턴스가 시작될 때 실행할 사용자 데이터
  # 인스턴스가 시작될 때 실행되는 스크립트 코드
  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt install nginx -y // nginx 설치
  EOF

  tags = {
    Name = "${var.project_name}-${var.target_label}-ec2"
  }
}

# resource "aws_key_pair" "example_key_pair" {
#   key_name = "example_key"
#   public_key = file("key-path/rsa.pub")
# }
```

- `resource`: 리소스를 생성합니다.
    - `aws_instance`: EC2 인스턴스를 생성합니다.
        - `ami`: 인스턴스를 생성할 때 사용할 AMI ID를 지정합니다.
        - `instance_type`: 인스턴스 유형을 지정합니다.
        - `subnet_id`: 인스턴스를 생성할 Subnet ID를 지정합니다.
        - `vpc_security_group_ids`: 인스턴스에 연결할 Security Group ID 목록을 지정합니다.
        - `associate_public_ip_address`: Public Subnet에 생성된 인스턴스에 Public IP를 할당할지 여부를 지정합니다.
        - `user_data`: 인스턴스가 시작될 때 실행할 스크립트를 지정합니다. 여기서는 `nginx` 웹 서버를 설치하는 스크립트를 작성했습니다.
        - `tags`: 인스턴스에 태그를 추가합니다. 태그는 리소스를 쉽게 식별하고 관리하는 데 사용됩니다.

## Step 12. output.tf

`output.tf` 파일은 Terraform에서 생성된 리소스의 속성 값을 출력하는 데 사용됩니다. 이 파일을 통해 원하는 리소스의 특정 정보를 Terraform 실행이 완료된 후에 명확히 확인할 수 있습니다. 출력된 값은 터미널에 표시되며, 다른 Terraform 모듈 또는 작업에서 참조할 수도 있습니다.

다음은 `output.tf` 파일에서 EC2 인스턴스의 퍼블릭 IP 주소를 출력하는 예시 코드입니다:

```hcl
output "ec2_instance_public_ip" {
  description = "Public IP address of the EC2 instance"  
  value       = aws_instance.ec2_instance.public_ip      # EC2 인스턴스의 퍼블릭 IP 주소를 출력
}
```

### 주요 설명:
- `output`: Terraform에서 출력할 값을 정의하는 키워드입니다.
- `"ec2_instance_public_ip"`: 출력 블록의 이름으로, 원하는 리소스 속성에 대해 의미 있는 이름을 부여합니다.
- `description`: 출력 값의 목적이나 설명을 나타내는 선택적 필드입니다. 협업 시 또는 나중에 코드를 유지보수할 때 출력 값의 의미를 쉽게 파악할 수 있게 해줍니다.
- `value`: 출력하고자 하는 실제 리소스 속성을 나타내며, 여기서는 `aws_instance.ec2_instance.public_ip`를 사용하여 EC2 인스턴스의 퍼블릭 IP 주소를 출력합니다.

이렇게 `output.tf` 파일을 활용하면, Terraform으로 리소스를 배포한 후 필요한 정보를 쉽게 확인하고 재사용할 수 있습니다.

## Step 13. terraform init, plan, apply

위에서 작성한 Terraform 코드를 실행하기 위해 다음 명령어를 순서대로 실행합니다.

1. `terraform init`: Terraform 코드를 초기화하고 필요한 플러그인을 다운로드합니다.
2. `terraform plan`: Terraform 코드를 실행하기 전에 변경 사항을 미리 확인합니다.
3. `terraform apply`: Terraform 코드를 실행하고 실제 리소스를 생성합니다.
```
Plan: 13 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + ec2_instance_public_ip = (known after apply)

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

module.vpc.aws_vpc.this[0]: Creating...
module.vpc.aws_vpc.this[0]: Still creating... [10s elapsed]
module.vpc.aws_vpc.this[0]: Creation complete after 12s [id=vpc-0a5a2280cc8cc1734]
module.vpc.aws_route_table.public[0]: Creating...
module.vpc.aws_subnet.public[0]: Creating...
module.vpc.aws_default_security_group.this[0]: Creating...
module.vpc.aws_default_route_table.default[0]: Creating...
module.vpc.aws_internet_gateway.this[0]: Creating...
aws_security_group.terraform-ec2-sg: Creating...
module.vpc.aws_default_network_acl.this[0]: Creating...
module.vpc.aws_default_route_table.default[0]: Creation complete after 0s [id=rtb-056d0d1b483928fca]
module.vpc.aws_internet_gateway.this[0]: Creation complete after 0s [id=igw-0044ecb642df217ec]
module.vpc.aws_route_table.public[0]: Creation complete after 0s [id=rtb-064920f864fabd65a]
module.vpc.aws_route.public_internet_gateway[0]: Creating...
module.vpc.aws_default_network_acl.this[0]: Creation complete after 1s [id=acl-0cfcc8a06c67ddc84]
module.vpc.aws_route.public_internet_gateway[0]: Creation complete after 1s [id=r-rtb-064920f864fabd65a1080289494]
module.vpc.aws_default_security_group.this[0]: Creation complete after 1s [id=sg-0dfa5282577fd9e2a]
aws_security_group.terraform-ec2-sg: Creation complete after 2s [id=sg-08fb1d1a5fd0b0eb5]
aws_security_group_rule.terraform-ec2-sg-i: Creating...
aws_security_group_rule.terraform-ec2-ssh-i: Creating...
aws_security_group_rule.terraform-ec2-sg-i: Creation complete after 1s [id=sgrule-3805596464]
aws_security_group_rule.terraform-ec2-ssh-i: Creation complete after 1s [id=sgrule-1415485061]
module.vpc.aws_subnet.public[0]: Still creating... [10s elapsed]
module.vpc.aws_subnet.public[0]: Creation complete after 11s [id=subnet-06292e16501eee619]
module.vpc.aws_route_table_association.public[0]: Creating...
aws_instance.ec2_instance: Creating...
module.vpc.aws_route_table_association.public[0]: Creation complete after 0s [id=rtbassoc-04865c599015a677b]
aws_instance.ec2_instance: Still creating... [10s elapsed]
aws_instance.ec2_instance: Creation complete after 13s [id=i-0330f936aa9dc3133]

Apply complete! Resources: 13 added, 0 changed, 0 destroyed.

Outputs:

ec2_instance_public_ip = "43.203.180.249"
```

## Step 13. ec2 접속 확인

위에서 `Outputs` 을 확인해 public ip 주소를 확인하고, 접속해본다. nginx을 설치하는 데 시간이 좀 걸릴 수 있어서, nginx 기본 페이지를 확인하는 데 최대 5-10분 정도 소요될 수도 있다.

![](https://velog.velcdn.com/images/minhojjang/post/a7f434b5-8fe9-4f14-8d0b-4ff9c4c5f53d/image.png)

![](https://velog.velcdn.com/images/minhojjang/post/3f4827c2-8844-412c-a818-cf4be95f7073/image.png)




























