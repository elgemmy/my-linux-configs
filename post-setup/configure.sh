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
    cat > ~/.zshrc.local << 'LOCALEOF'
# ~/.zshrc.local
# Machine-specific configuration that is NOT tracked in the dotfiles repo.
# This file is sourced by ~/.zshrc if it exists.
# Add anything here that is specific to this machine or shouldn't be committed.

# --- NVM (Node Version Manager) ---
# Uncomment the following lines to load NVM on shell startup:
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# --- Additional PATH entries ---
# export PATH="$HOME/some-custom-path/bin:$PATH"
LOCALEOF
    echo -e "${GREEN}Created ~/.zshrc.local${NC}"
else
    echo -e "${YELLOW}~/.zshrc.local already exists — skipping.${NC}"
fi

# 4. Create ~/.zshrc.work template if it doesn't exist
if [ ! -f ~/.zshrc.work ]; then
    echo -e "${BLUE}Creating ~/.zshrc.work template...${NC}"
    cat > ~/.zshrc.work << 'WORKEOF'
# ~/.zshrc.work
# Work-specific functions, aliases, and environment variables.
# This file is sourced by ~/.zshrc if it exists.
# Keep work-related configuration here to avoid mixing it with personal dotfiles.

# Example:
# alias vpn="sudo openconnect --protocol=gp vpn.company.com"
# export WORK_PROJECT_DIR="$HOME/work"
WORKEOF
    echo -e "${GREEN}Created ~/.zshrc.work${NC}"
else
    echo -e "${YELLOW}~/.zshrc.work already exists — skipping.${NC}"
fi

echo -e "\n${GREEN}=== Post-setup configuration complete ===${NC}"
echo -e "${BLUE}Review and edit these files as needed:${NC}"
echo -e "  ${YELLOW}~/.zshrc.local${NC}  — machine-specific shell config"
echo -e "  ${YELLOW}~/.zshrc.work${NC}   — work-specific aliases and functions"
echo -e "  ${YELLOW}~/.gitconfig${NC}    — git configuration (see git/gitconfig.template)"
