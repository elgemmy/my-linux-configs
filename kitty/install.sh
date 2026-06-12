#!/bin/bash
# Simple Kitty terminal installation script

set -e

# Color codes for better output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Kitty Terminal Setup ===${NC}"

# Install Kitty from the official binary installer. Distro packages can lag and
# have missed features needed by saved sessions on fresh machines.
echo -e "\n${BLUE}📦 Installing Kitty terminal...${NC}"
if ! command -v curl &> /dev/null; then
    echo -e "${YELLOW}Installing curl dependency...${NC}"
    if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y curl
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y curl
    else
        echo -e "${RED}curl is required. Please install curl and re-run this script.${NC}"
        exit 1
    fi
fi

if [ ! -x "$HOME/.local/kitty.app/bin/kitty" ]; then
    echo -e "${YELLOW}Running official Kitty installer...${NC}"
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
else
    echo -e "${GREEN}✅ Official Kitty binary already installed${NC}"
fi

mkdir -p "$HOME/.local/bin"
ln -sfn "$HOME/.local/kitty.app/bin/kitty" "$HOME/.local/bin/kitty"
ln -sfn "$HOME/.local/kitty.app/bin/kitten" "$HOME/.local/bin/kitten"
echo -e "${GREEN}✅ Kitty installed and linked in ~/.local/bin${NC}"

# Create config directory
echo -e "\n${BLUE}📁 Setting up Kitty configuration...${NC}"
mkdir -p ~/.config/kitty
mkdir -p ~/.config/kitty/sessions
echo -e "${GREEN}✅ Config directory created${NC}"

# Backup existing config
if [ -f ~/.config/kitty/kitty.conf ]; then
    echo -e "${YELLOW}Backing up existing kitty.conf to kitty.conf.backup${NC}"
    cp ~/.config/kitty/kitty.conf ~/.config/kitty/kitty.conf.backup
fi

# Copy configuration
echo -e "${YELLOW}Installing kitty configuration...${NC}"
cp kitty.conf ~/.config/kitty/kitty.conf
cp sessions/daily.kitty-session ~/.config/kitty/sessions/daily.kitty-session
echo -e "${GREEN}✅ Configuration installed${NC}"

# Install desktop launcher for daily development session
echo -e "\n${BLUE}🖥️  Installing Kitty daily session launcher...${NC}"
mkdir -p ~/.local/share/applications
mkdir -p ~/.config/autostart
KITTY_BIN="$HOME/.local/bin/kitty"
sed -e "s|__HOME__|$HOME|g" -e "s|__KITTY__|$KITTY_BIN|g" desktop/kdev.desktop > ~/.local/share/applications/kdev.desktop
sed -e "s|__HOME__|$HOME|g" -e "s|__KITTY__|$KITTY_BIN|g" desktop/kdev.desktop > ~/.config/autostart/kdev.desktop
chmod 644 ~/.local/share/applications/kdev.desktop
chmod 644 ~/.config/autostart/kdev.desktop
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database ~/.local/share/applications 2>/dev/null || true
fi
echo -e "${GREEN}✅ Desktop and autostart launchers installed as kdev.desktop${NC}"
echo -e "${YELLOW}Kitty aliases are provided by zsh/zshrc; restart your shell after installing ZSH.${NC}"

echo
echo -e "${GREEN}✅ Kitty terminal installed successfully${NC}"
echo -e "${BLUE}Launch with: ${YELLOW}kitty${NC}"
echo -e "${BLUE}Daily session: ${YELLOW}kdev${NC} or app launcher ${YELLOW}Kitty Daily Session${NC}"
echo -e "${BLUE}Key shortcuts:${NC}"
echo -e "${BLUE}  • ${YELLOW}Ctrl+Alt+Enter${NC} (new tab)"
echo -e "${BLUE}  • ${YELLOW}Ctrl+Shift+H/J/K/L${NC} (pane navigation)"
echo -e "${YELLOW}Note: Pick a theme with: kitten themes${NC}"
