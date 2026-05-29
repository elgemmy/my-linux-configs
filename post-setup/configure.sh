#!/bin/bash
# Interactive post-setup configuration script

set -e

# Color codes for better output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo -e "${GREEN}=== Post-Setup Configuration ===${NC}\n"

# 1. Run check.sh to show current status
echo -e "${BLUE}Running environment check...${NC}\n"
bash "$SCRIPT_DIR/check.sh"
echo

# 2. Offer git credential helper setup if bw is available
if command -v bw &>/dev/null; then
    echo -e "${BLUE}Bitwarden CLI detected.${NC}"
    read -rp "$(echo -e "${YELLOW}Set up git-credential-bitwarden? [Y/n]: ${NC}")" reply
    if [[ ! "$reply" =~ ^[Nn]$ ]]; then
        echo -e "${BLUE}Running git credential helper installer...${NC}"
        bash "$REPO_DIR/git/install.sh"
        echo
    else
        echo -e "${YELLOW}Skipping git credential helper setup.${NC}\n"
    fi
else
    echo -e "${YELLOW}Bitwarden CLI not found — skipping git credential helper setup.${NC}"
    echo -e "${YELLOW}Install bw first, then re-run this script or run git/install.sh directly.${NC}\n"
fi

# 3. Create ~/.zshrc.local template if it doesn't exist
if [ ! -f ~/.zshrc.local ]; then
    echo -e "${BLUE}Creating ~/.zshrc.local template...${NC}"
    cp "$REPO_DIR/zsh/templates/zshrc.local" ~/.zshrc.local
    echo -e "${GREEN}Created ~/.zshrc.local${NC}"
else
    echo -e "${YELLOW}~/.zshrc.local already exists — skipping.${NC}"
fi

# 4. Create ~/.zshrc.work template if it doesn't exist
if [ ! -f ~/.zshrc.work ]; then
    echo -e "${BLUE}Creating ~/.zshrc.work template...${NC}"
    cp "$REPO_DIR/zsh/templates/zshrc.work" ~/.zshrc.work
    echo -e "${GREEN}Created ~/.zshrc.work${NC}"
else
    echo -e "${YELLOW}~/.zshrc.work already exists — skipping.${NC}"
fi

echo -e "\n${GREEN}=== Post-setup configuration complete ===${NC}"
echo -e "${BLUE}Review and edit these files as needed:${NC}"
echo -e "  ${YELLOW}~/.zshrc.local${NC}  — machine-specific shell config"
echo -e "  ${YELLOW}~/.zshrc.work${NC}   — work-specific aliases and functions"
echo -e "  ${YELLOW}~/.gitconfig${NC}    — git configuration (see git/gitconfig.template)"
