#!/bin/bash
# Git global config installation script

set -e

# Color codes for better output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${GREEN}=== Git Configuration Setup ===${NC}"

# 1. Install global gitignore
echo -e "\n${BLUE}Installing global gitignore...${NC}"
if [ -f ~/.gitignore_global ]; then
    echo -e "${YELLOW}Backing up existing ~/.gitignore_global to ~/.gitignore_global.backup${NC}"
    cp ~/.gitignore_global ~/.gitignore_global.backup
fi
cp "$SCRIPT_DIR/gitignore_global" ~/.gitignore_global
echo -e "${GREEN}Installed ~/.gitignore_global${NC}"

# 2. Remove old Bitwarden credential helper config if this repo installed it.
current_helper="$(git config --global --get-all credential.helper 2>/dev/null || true)"
if echo "$current_helper" | grep -q "git-credential-bitwarden"; then
    echo -e "\n${YELLOW}Removing old Bitwarden credential helper config...${NC}"
    git config --global --unset-all credential.helper ".*git-credential-bitwarden.*" || true
    echo -e "${GREEN}Removed credential.helper entries that used git-credential-bitwarden${NC}"
fi

# 3. Set global excludes file
echo -e "\n${BLUE}Configuring global excludes file...${NC}"
git config --global core.excludesFile ~/.gitignore_global
echo -e "${GREEN}Set core.excludesFile to ~/.gitignore_global${NC}"

# 4. Check and prompt for user identity
echo -e "\n${BLUE}Checking git user identity...${NC}"

current_name="$(git config --global user.name 2>/dev/null || true)"
current_email="$(git config --global user.email 2>/dev/null || true)"

if [ -n "$current_name" ]; then
    echo -e "${GREEN}user.name is already set: ${current_name}${NC}"
else
    echo -e "${YELLOW}user.name is not configured.${NC}"
    read -rp "$(echo -e "${BLUE}Enter your name for git commits: ${NC}")" input_name
    if [ -n "$input_name" ]; then
        git config --global user.name "$input_name"
        echo -e "${GREEN}Set user.name to: ${input_name}${NC}"
    else
        echo -e "${RED}Skipped — you can set it later with: git config --global user.name \"Your Name\"${NC}"
    fi
fi

if [ -n "$current_email" ]; then
    echo -e "${GREEN}user.email is already set: ${current_email}${NC}"
else
    echo -e "${YELLOW}user.email is not configured.${NC}"
    read -rp "$(echo -e "${BLUE}Enter your email for git commits: ${NC}")" input_email
    if [ -n "$input_email" ]; then
        git config --global user.email "$input_email"
        echo -e "${GREEN}Set user.email to: ${input_email}${NC}"
    else
        echo -e "${RED}Skipped — you can set it later with: git config --global user.email \"you@example.com\"${NC}"
    fi
fi

echo -e "\n${GREEN}=== Git configuration complete ===${NC}"
echo -e "${BLUE}No credential helper is configured by this script. Use SSH keys or gh auth for GitHub.${NC}"
echo -e "${BLUE}See gitconfig.template for a reference of all configured settings.${NC}"
