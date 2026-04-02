#!/bin/bash
# AppImage management system setup

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${GREEN}=== AppImage Management Setup ===${NC}"

# Create ~/Applications
echo -e "\n${BLUE}📁 Creating ~/Applications directory...${NC}"
mkdir -p "$HOME/Applications"
echo -e "${GREEN}✅ ~/Applications ready${NC}"

# Install scripts
echo -e "\n${BLUE}🔧 Installing scripts to ~/.local/bin...${NC}"
mkdir -p "$HOME/.local/bin"
cp "$SCRIPT_DIR/bin/appimage-install"   "$HOME/.local/bin/appimage-install"
cp "$SCRIPT_DIR/bin/appimage-update"    "$HOME/.local/bin/appimage-update"
cp "$SCRIPT_DIR/bin/appimage-uninstall" "$HOME/.local/bin/appimage-uninstall"
chmod +x "$HOME/.local/bin/appimage-install" \
         "$HOME/.local/bin/appimage-update" \
         "$HOME/.local/bin/appimage-uninstall"
echo -e "${GREEN}✅ appimage-install, appimage-update, appimage-uninstall installed${NC}"

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

echo
echo -e "${GREEN}✅ AppImage management setup complete${NC}"
echo
echo -e "${BLUE}Usage:${NC}"
echo -e "  ${YELLOW}appimage-install <file.AppImage>${NC}         install a new AppImage"
echo -e "  ${YELLOW}appimage-update <name> <file.AppImage>${NC}   update an installed AppImage"
echo -e "  ${YELLOW}appimage-uninstall [-y] <name>${NC}           remove an installed AppImage"
echo
echo -e "${BLUE}See appimages/README.md for full documentation.${NC}"
