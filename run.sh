#!/bin/bash

# terraform.tfvars 파일에서 변수 값 읽기
function get_var_from_tfvars() {
    local var_name="$1"
    echo $(grep "^$var_name" terraform.tfvars | awk -F'=' '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}' | tr -d '"')
}

# 비밀번호 마스킹 처리를 위한 별도 함수
function mask_password() {
    local value="$1"
    local pwd_length=${#value}
    
    if [[ $pwd_length -lt 5 ]]; then
        echo "$value"
    else
        local first_two="${value:0:2}"
        local last_two="${value: -2}"
        local mask_length=$((pwd_length - 4))
        local masked_part=$(printf '%*s' "$mask_length" | tr ' ' '*')
        echo "${first_two}${masked_part}${last_two}"
    fi
}

# 기본값을 사용하여 사용자 입력을 받는 함수
function get_input_with_default() {
  local prompt="$1"
  local default_value="$2"
  local sensitive="$3"

  # RDS 비밀번호인 경우 마스킹된 버전을 표시
  if [[ "$prompt" == *"RDS password"* ]]; then
    local masked_default=$(mask_password "$default_value")
    read -p "$prompt [$masked_default]: " input_value
  else
    read -p "$prompt [$default_value]: " input_value
  fi

  # 입력값이 비어있다면 기본값을 반환하고, 그렇지 않으면 입력값 반환
  echo "${input_value:-$default_value}"
}

# RDS 비밀번호 조건 검사 함수
function validate_rds_password() {
  local password="$1"
  local username="$2" # 사용자 이름 추가

  # 길이 확인 (8~41자)
  if [[ ${#password} -lt 8 || ${#password} -gt 41 ]]; then
    return 1  # 실패
  fi

  # tr을 사용하여 소문자 변환
  local lowercase_password=$(echo "$password" | tr '[:upper:]' '[:lower:]')
  local lowercase_username=$(echo "$username" | tr '[:upper:]' '[:lower:]')

  # 문자 종류 확인 (대문자, 소문자, 숫자, 기호 중 3개 이상 포함)
  local has_uppercase=0
  local has_lowercase=0
  local has_digit=0
  local has_symbol=0

  for ((i=0; i<${#password}; i++)); do
    local char="${password:i:1}"
    if [[ "$char" =~ [[:upper:]] ]]; then
      has_uppercase=1
    elif [[ "$char" =~ [[:lower:]] ]]; then
      has_lowercase=1
    elif [[ "$char" =~ [[:digit:]] ]]; then
      has_digit=1
    elif [[ "$char" =~ [[:punct:]] ]]; then
      has_symbol=1
    fi
  done

  if [[ $((has_uppercase + has_lowercase + has_digit + has_symbol)) -lt 3 ]]; then
    return 1  # 실패
  fi

  # rdsadmin 또는 사용자 이름과 동일한 비밀번호 금지
  if [[ "$lowercase_password" == *"rdsadmin"* ]] || [[ "$lowercase_password" == "$lowercase_username" ]]; then
    return 1 # 실패
  fi

  return 0  # 성공
}

# terraform.tfvars 파일 업데이트 함수 (4개 변수만 덮어쓰기)
function update_tfvars_file() {
  local name_prefix="$1"
  local rds_username="$2"
  local rds_password="$3"
  local profile="$4"

  # 기존 tfvars 파일 백업
  cp terraform.tfvars terraform.tfvars.bak

  sed -i '' "s/^name_prefix.*=.*/name_prefix = \"${name_prefix}\"/" terraform.tfvars
  sed -i '' "s/^rds_username.*=.*/rds_username = \"${rds_username}\"/" terraform.tfvars
  sed -i '' "s/^rds_password.*=.*/rds_password = \"${rds_password}\"/" terraform.tfvars
  sed -i '' "s/^profile.*=.*/profile = \"${profile}\"/" terraform.tfvars
}

# terraform.tfvars 파일에서 기본값 가져오기
DEFAULT_NAME_PREFIX=$(get_var_from_tfvars "name_prefix")
DEFAULT_RDS_USERNAME=$(get_var_from_tfvars "rds_username")
DEFAULT_RDS_PASSWORD=$(get_var_from_tfvars "rds_password")
DISPLAY_RDS_PASSWORD=$(mask_password "$DEFAULT_RDS_PASSWORD")  # 표시용 마스킹된 비밀번호
DEFAULT_PROFILE=$(get_var_from_tfvars "profile")

# 사용자 입력 받기 (기본값 표시할 때는 마스킹된 버전 사용)
NAME_PREFIX=$(get_input_with_default "Enter your name prefix" "$DEFAULT_NAME_PREFIX")
RDS_USERNAME=$(get_input_with_default "Enter the RDS username" "$DEFAULT_RDS_USERNAME")

# RDS 비밀번호 입력 (검증 포함)
while true; do
    RDS_PASSWORD=$(get_input_with_default "Enter the RDS password" "$DEFAULT_RDS_PASSWORD")
    
    if validate_rds_password "$RDS_PASSWORD" "$RDS_USERNAME"; then
        break
    else
        echo "Error: Invalid RDS password. Please ensure it meets the following criteria:"
        echo "- Length: 8-41 characters"
        echo "- Character types: Must include at least 3 of the following: uppercase, lowercase, numbers, and symbols."
        echo "- Restrictions: Cannot contain 'rdsadmin' (case-insensitive) or be the same as the username."
        echo ""
    fi
done

PROFILE=$(get_input_with_default "Enter the AWS profile name" "$DEFAULT_PROFILE")

# 사용자 입력 확인 단계 (비밀번호는 마스킹해서 표시)
echo ""
echo "=========================="
echo "   Confirm Your Inputs    "
echo "=========================="
echo "Name Prefix     : $NAME_PREFIX"
echo "RDS Username    : $RDS_USERNAME"
echo "RDS Password    : [REDACTED]"
echo "AWS Profile     : $PROFILE"
echo "=========================="
echo ""

# 사용자 확인 (yes 만 허용)
while true; do
  read -r -p "Are you sure you want to proceed with these values? Type 'yes' to continue: " confirm
  case "$confirm" in
    yes )
      break ;; # 루프 종료 및 진행
    no | * ) # no 또는 다른 입력
      echo "Operation cancelled by user."
      exit 1 ;;
  esac
done

update_tfvars_file "$NAME_PREFIX" "$RDS_USERNAME" "$RDS_PASSWORD" "$PROFILE"

# Terraform 명령어 실행
echo "Initializing Terraform..."
terraform init

terraform fmt --recursive

echo "Applying Terraform deployment (user confirmation required)..."
terraform apply -var="name_prefix=$NAME_PREFIX" \
                -var="rds_username=$RDS_USERNAME" \
                -var="rds_password=$RDS_PASSWORD" \
                -var="profile=$PROFILE"