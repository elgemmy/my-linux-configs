#!/bin/bash
# Simple Vim installation script

set -e

# Color codes for better output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Vim Configuration Setup ===${NC}"

# Detect package manager and install vim with clipboard support
echo -e "\n${BLUE}📦 Installing Vim with clipboard support...${NC}"
if command -v apt &> /dev/null; then
    echo -e "${YELLOW}Installing vim with clipboard support (Ubuntu/Debian)...${NC}"
    sudo apt update && sudo apt install -y vim-gtk3 xclip
    echo -e "${GREEN}✅ Vim installed successfully${NC}"
elif command -v dnf &> /dev/null; then
    echo -e "${YELLOW}Installing vim with clipboard support (Fedora)...${NC}"
    sudo dnf install -y vim-enhanced xclip
    echo -e "${GREEN}✅ Vim installed successfully${NC}"
elif command -v pacman &> /dev/null; then
    echo -e "${YELLOW}Installing vim with clipboard support (Arch Linux)...${NC}"
    sudo pacman -Sy --noconfirm gvim xclip
    echo -e "${GREEN}✅ Vim installed successfully${NC}"
else
    echo -e "${RED}Package manager not supported. Please install vim with clipboard support manually.${NC}"
    exit 1
fi

# Backup existing vimrc
echo -e "\n${BLUE}📁 Setting up Vim configuration...${NC}"
if [ -f ~/.vimrc ]; then
    echo -e "${YELLOW}Backing up existing ~/.vimrc to ~/.vimrc.backup${NC}"
    cp ~/.vimrc ~/.vimrc.backup
fi

# Copy vimrc
echo -e "${YELLOW}Installing vim configuration...${NC}"
cp vimrc ~/.vimrc
echo -e "${GREEN}✅ Configuration installed${NC}"

# Create undo directory
echo -e "${YELLOW}Creating undo directory...${NC}"
mkdir -p ~/.vim/undo
echo -e "${GREEN}✅ Undo directory created${NC}"

# Verify installation
echo -e "\n${BLUE}🔍 Verifying installation...${NC}"
if vim --version | grep -q "+clipboard"; then
    echo -e "${GREEN}✅ Vim installed successfully with clipboard support${NC}"
else
    echo -e "${YELLOW}⚠ Vim installed but clipboard support may not be available${NC}"
fi

echo
echo -e "${GREEN}✅ Vim configuration installed${NC}"
echo -e "${BLUE}Usage: ${YELLOW}vim filename${NC}"
echo -e "${BLUE}Key shortcuts:${NC}"
echo -e "${BLUE}  • ${YELLOW}jj${NC} (exit insert mode)"
echo -e "${BLUE}  • ${YELLOW},y${NC} (copy to clipboard)"
echo -e "${BLUE}  • ${YELLOW},p${NC} (paste from clipboard)"
