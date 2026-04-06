#!/bin/bash
# Diagnostic script: check for external tools and report status

set -e

# Color codes for better output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Development Environment Check ===${NC}\n"

# Helper: check a command and report status
# Usage: check_tool <name> <command> <version_cmd> <install_hint>
check_tool() {
    local name="$1"
    local cmd="$2"
    local version_cmd="$3"
    local install_hint="$4"

    if command -v "$cmd" &>/dev/null; then
        local version
        version="$(eval "$version_cmd" 2>/dev/null || echo "installed")"
        echo -e "  ${GREEN}[OK]${NC}      ${BLUE}${name}${NC} — ${version}"
    else
        echo -e "  ${RED}[MISSING]${NC} ${BLUE}${name}${NC}"
        echo -e "            ${YELLOW}Install: ${install_hint}${NC}"
    fi
}

# Bitwarden CLI
check_tool "bw (Bitwarden CLI)" "bw" "bw --version" \
    "sudo snap install bw  OR  npm install -g @bitwarden/cli"

# GitHub CLI
check_tool "gh (GitHub CLI)" "gh" "gh --version | head -1" \
    "sudo apt install gh  /  sudo dnf install gh"

# git-credential-bitwarden
echo -n ""
if [ -x "$HOME/.local/bin/git-credential-bitwarden" ]; then
    echo -e "  ${GREEN}[OK]${NC}      ${BLUE}git-credential-bitwarden${NC} — installed in ~/.local/bin/"
else
    echo -e "  ${RED}[MISSING]${NC} ${BLUE}git-credential-bitwarden${NC}"
    echo -e "            ${YELLOW}Install: cd git && ./install.sh${NC}"
fi

# Docker
check_tool "docker" "docker" "docker --version" \
    "See https://docs.docker.com/engine/install/"

# Go
check_tool "go" "go" "go version" \
    "See https://go.dev/doc/install"

# NVM / Node
echo -n ""
if [ -s "${NVM_DIR:-$HOME/.nvm}/nvm.sh" ]; then
    # Source nvm to get node version if not already loaded
    if ! command -v nvm &>/dev/null; then
        source "${NVM_DIR:-$HOME/.nvm}/nvm.sh" 2>/dev/null || true
    fi
    local_node_version="$(node --version 2>/dev/null || echo "no node version active")"
    echo -e "  ${GREEN}[OK]${NC}      ${BLUE}nvm${NC} — installed (node ${local_node_version})"
elif command -v node &>/dev/null; then
    node_version="$(node --version 2>/dev/null || echo "unknown")"
    echo -e "  ${GREEN}[OK]${NC}      ${BLUE}node${NC} — ${node_version} (nvm not found, using system node)"
else
    echo -e "  ${RED}[MISSING]${NC} ${BLUE}nvm / node${NC}"
    echo -e "            ${YELLOW}Install NVM: https://github.com/nvm-sh/nvm${NC}"
fi

echo -e "\n${GREEN}=== Check complete ===${NC}"
