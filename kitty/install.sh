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

# Detect package manager and install kitty
echo -e "\n${BLUE}📦 Installing Kitty terminal...${NC}"
if command -v apt &> /dev/null; then
    echo -e "${YELLOW}Installing Kitty terminal (Ubuntu/Debian)...${NC}"
    sudo apt update && sudo apt install -y kitty
    echo -e "${GREEN}✅ Kitty installed successfully${NC}"
elif command -v dnf &> /dev/null; then
    echo -e "${YELLOW}Installing Kitty terminal (Fedora)...${NC}"
    sudo dnf install -y kitty
    echo -e "${GREEN}✅ Kitty installed successfully${NC}"
else
    echo -e "${RED}Package manager not supported. Please install kitty manually.${NC}"
    exit 1
fi

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
KITTY_BIN="$(command -v kitty || true)"
if [ -z "$KITTY_BIN" ]; then
    KITTY_BIN="kitty"
fi
sed -e "s|__HOME__|$HOME|g" -e "s|__KITTY__|$KITTY_BIN|g" desktop/kdev.desktop > ~/.local/share/applications/kdev.desktop
chmod 644 ~/.local/share/applications/kdev.desktop
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database ~/.local/share/applications 2>/dev/null || true
fi
echo -e "${GREEN}✅ Desktop launcher installed as kdev.desktop${NC}"

# Add kitty alias to ~/.zshrc.local
echo -e "\n${BLUE}🔧 Adding kitty aliases to ~/.zshrc.local...${NC}"
KITTY_MARKER="# --- kitty-helpers-start ---"
if ! grep -q "$KITTY_MARKER" "$HOME/.zshrc.local" 2>/dev/null; then
    touch "$HOME/.zshrc.local"
    cat >> "$HOME/.zshrc.local" << 'KITTYEOF'

# --- kitty-helpers-start ---
# Kitty aliases (added by kitty/install.sh)
alias icat="kitten icat"
alias kdev="kitty --detach --session ~/.config/kitty/sessions/daily.kitty-session"
# --- kitty-helpers-end ---
KITTYEOF
    echo -e "${GREEN}✅ Kitty aliases added to ~/.zshrc.local${NC}"
else
    echo -e "${GREEN}✅ Kitty aliases already in ~/.zshrc.local${NC}"
fi

if ! grep -q 'alias kdev=' "$HOME/.zshrc.local" 2>/dev/null; then
    sed -i '/# --- kitty-helpers-end ---/i alias kdev="kitty --detach --session ~/.config/kitty/sessions/daily.kitty-session"' "$HOME/.zshrc.local"
    echo -e "${GREEN}✅ kdev alias added to ~/.zshrc.local${NC}"
fi

echo
echo -e "${GREEN}✅ Kitty terminal installed successfully${NC}"
echo -e "${BLUE}Launch with: ${YELLOW}kitty${NC}"
echo -e "${BLUE}Daily session: ${YELLOW}kdev${NC} or app launcher ${YELLOW}Kitty Daily Session${NC}"
echo -e "${BLUE}Key shortcuts:${NC}"
echo -e "${BLUE}  • ${YELLOW}Ctrl+Alt+Enter${NC} (new tab)"
echo -e "${BLUE}  • ${YELLOW}Ctrl+Shift+H/J/K/L${NC} (pane navigation)"
echo -e "${YELLOW}Note: Pick a theme with: kitten themes${NC}"
