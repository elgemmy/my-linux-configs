#!/bin/bash
# Simple font installation script

set -e

# Color codes for better output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Font Installation ===${NC}"

# Create fonts directory
echo -e "${BLUE}📁 Creating fonts directory...${NC}"
mkdir -p ~/.local/share/fonts
echo -e "${GREEN}✅ Fonts directory created${NC}"

# Function to download and install font
install_font() {
    local name=$1
    local url=$2
    local extract_path=$3

    echo -e "${YELLOW}Installing $name...${NC}"

    # Download
    wget -q -O /tmp/$name.zip "$url" || { echo -e "${RED}Failed to download $name${NC}"; return 1; }

    # Extract
    unzip -q /tmp/$name.zip -d /tmp/$name/

    # Copy TTF files
    find /tmp/$name/$extract_path -name "*.ttf" -exec cp {} ~/.local/share/fonts/ \; 2>/dev/null

    # Cleanup
    rm -rf /tmp/$name*

    echo -e "${GREEN}✅ $name installed${NC}"
}

# Try package manager first
echo -e "\n${BLUE}📦 Trying package manager installation...${NC}"
if command -v apt &> /dev/null; then
    echo -e "${YELLOW}Trying package installation (Ubuntu/Debian)...${NC}"
    sudo apt update
    sudo apt install -y fonts-firacode 2>/dev/null || echo -e "${YELLOW}Fira Code not in repos, using manual install${NC}"
elif command -v dnf &> /dev/null; then
    echo -e "${YELLOW}Trying package installation (Fedora)...${NC}"
    sudo dnf install -y fira-code-fonts 2>/dev/null || echo -e "${YELLOW}Fira Code not in repos, using manual install${NC}"
elif command -v pacman &> /dev/null; then
    echo -e "${YELLOW}Installing fonts (Arch Linux)...${NC}"
    sudo pacman -Sy --noconfirm ttf-fira-code ttf-jetbrains-mono 2>/dev/null || echo -e "${YELLOW}Some fonts not in repos, using manual install${NC}"
fi

# Manual installation as backup
echo -e "\n${BLUE}🔤 Installing programming fonts...${NC}"
if ! fc-list | grep -qi "fira code"; then
    echo -e "${YELLOW}Installing Fira Code manually...${NC}"
    echo -e "${BLUE}📥 Fetching latest Fira Code release...${NC}"

    # Get latest Fira Code version dynamically
    FIRA_VERSION=$(curl -s https://api.github.com/repos/tonsky/FiraCode/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

    if [ -z "$FIRA_VERSION" ]; then
        echo -e "${YELLOW}⚠️  Could not fetch latest version, using fallback 6.2${NC}"
        FIRA_URL="https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip"
    else
        echo -e "${GREEN}✅ Latest Fira Code version: $FIRA_VERSION${NC}"
        FIRA_URL="https://github.com/tonsky/FiraCode/releases/download/$FIRA_VERSION/Fira_Code_$FIRA_VERSION.zip"
    fi

    install_font "FiraCode" "$FIRA_URL" "ttf"
else
    echo -e "${GREEN}✅ Fira Code already installed${NC}"
fi

# Install JetBrains Mono as backup
if ! fc-list | grep -qi "jetbrains mono"; then
    echo -e "${YELLOW}Installing JetBrains Mono as backup...${NC}"
    echo -e "${BLUE}📥 Fetching latest JetBrains Mono release...${NC}"

    # Get latest JetBrains Mono version dynamically
    JB_VERSION=$(curl -s https://api.github.com/repos/JetBrains/JetBrainsMono/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

    if [ -z "$JB_VERSION" ]; then
        echo -e "${YELLOW}⚠️  Could not fetch latest version, using fallback v2.304${NC}"
        JB_URL="https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip"
    else
        echo -e "${GREEN}✅ Latest JetBrains Mono version: $JB_VERSION${NC}"
        JB_URL="https://github.com/JetBrains/JetBrainsMono/releases/download/$JB_VERSION/JetBrainsMono-${JB_VERSION#v}.zip"
    fi

    install_font "JetBrainsMono" "$JB_URL" "fonts/ttf"
else
    echo -e "${GREEN}✅ JetBrains Mono already installed${NC}"
fi

# Update font cache
echo -e "\n${BLUE}🔄 Updating font cache...${NC}"
fc-cache -f
echo -e "${GREEN}✅ Font cache updated${NC}"

echo
echo -e "${GREEN}✅ Font installation completed${NC}"
echo -e "${BLUE}Available fonts:${NC}"
fc-list | grep -E "(Fira|JetBrains)" | cut -d: -f2 | sort -u | head -10
