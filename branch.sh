#!/bin/bash

# 스크립트 오류 시 중단
set -e

# ANSI 색상 코드 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m' 
BOLD='\033[1m'
RESET='\033[0m'  # 모든 스타일 리셋

# Git 프로젝트 루트 디렉토리로 이동
cd "$(git rev-parse --show-toplevel)"

# main 브랜치로 이동 후 최신 상태로 업데이트
echo "${BOLD}Switching to main branch and pulling latest changes...${RESET}"
git checkout main
git pull

# 사용자로부터 브랜치명을 입력받음
printf "${BOLD}${BLUE}Enter the branch name: ${RESET}"
read BRANCH_NAME

# 새로운 브랜치 생성 및 이동
echo "${BLUE}${BOLD}Creating and checking out new branch '$BRANCH_NAME'...${RESET}"
if git checkout -b "$BRANCH_NAME"; then
    echo "${GREEN}Branch '$BRANCH_NAME' has been successfully created and checked out.${RESET}"
else
    echo "${RED}Error: Failed to create and check out branch '$BRANCH_NAME'.${RESET}"
    exit 1
fi

# 리모트 브랜치와 연결 및 푸시
echo "${BLUE}${BOLD}Pushing and linking the branch with the remote repository...${RESET}"
if git push --set-upstream origin "$BRANCH_NAME"; then
    echo "${GREEN}Branch '$BRANCH_NAME' has been pushed and linked with the remote repository.${RESET}"
else
    echo "${RED}Error: Failed to push and link branch '$BRANCH_NAME' with the remote repository.${RESET}"
    exit 1
fi

echo "${BLUE}${BOLD}Transaction completed successfully. Branch '$BRANCH_NAME' is now ready.${RESET}"