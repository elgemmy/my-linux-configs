#!/bin/bash
# Tarball app management system setup

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${GREEN}=== Tarball App Management Setup ===${NC}"

# Install scripts
echo -e "\n${BLUE}🔧 Installing scripts to ~/.local/bin...${NC}"
mkdir -p "$HOME/.local/bin"
cp "$SCRIPT_DIR/bin/tar-install"   "$HOME/.local/bin/tar-install"
cp "$SCRIPT_DIR/bin/tar-update"    "$HOME/.local/bin/tar-update"
cp "$SCRIPT_DIR/bin/tar-uninstall" "$HOME/.local/bin/tar-uninstall"
chmod +x "$HOME/.local/bin/tar-install" \
         "$HOME/.local/bin/tar-update" \
         "$HOME/.local/bin/tar-uninstall"
echo -e "${GREEN}✅ tar-install, tar-update, tar-uninstall installed${NC}"

# PATH check
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo -e "\n${YELLOW}⚠️  ~/.local/bin is not in your current PATH.${NC}"
    echo -e "${YELLOW}   Add this to your ~/.zshrc or ~/.bashrc:${NC}"
    echo -e "${BLUE}   export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
else
    echo -e "${GREEN}✅ ~/.local/bin is in PATH${NC}"
fi

# Dependency check
echo -e "\n${BLUE}🔍 Checking dependencies...${NC}"

check_cmd() {
    if command -v "$1" &>/dev/null; then
        echo -e "  ${GREEN}✅ $1${NC}"
    else
        echo -e "  ${YELLOW}⚠️  $1 not found — install: $2${NC}"
    fi
}

check_cmd update-desktop-database \
    "apt: desktop-file-utils | pacman: desktop-file-utils | dnf: desktop-file-utils"
check_cmd gtk-update-icon-cache \
    "apt: libgtk-3-bin | pacman: gtk3 | dnf: gtk3"
check_cmd tar \
    "apt: tar | pacman: tar | dnf: tar"
echo -e "  ${BLUE}ℹ️  node/npx is optional — only used to pull icons out of Electron app.asar files${NC}"

echo
echo -e "${GREEN}✅ Tarball app management setup complete${NC}"
echo
echo -e "${BLUE}Usage:${NC}"
echo -e "  ${YELLOW}tar-install <file.tar.gz>${NC}             install a new tarball app to /opt"
echo -e "  ${YELLOW}tar-update <name> <file.tar.gz>${NC}       update an installed tarball app"
echo -e "  ${YELLOW}tar-uninstall [-y] <name>${NC}             remove an installed tarball app"
echo
echo -e "${BLUE}See tarapps/README.md for full documentation.${NC}"
