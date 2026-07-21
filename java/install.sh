#!/bin/bash
# Java installation script for ZSH switcher compatibility

set -e

# Color codes for better output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Java Development Kit Setup ===${NC}"

if ! command -v apt &> /dev/null; then
    echo -e "${RED}❌ apt is required. This script supports Debian and Ubuntu only.${NC}" >&2
    exit 1
fi

# Function to detect system and install Java
install_java() {
    echo -e "${YELLOW}Installing Java on Debian/Ubuntu system...${NC}"
    sudo apt update
    sudo apt install -y openjdk-17-jdk openjdk-21-jdk
    echo -e "${GREEN}✅ Java packages installed${NC}"

    JAVA_17_PATH="/usr/lib/jvm/java-17-openjdk-amd64"
    JAVA_21_PATH="/usr/lib/jvm/java-21-openjdk-amd64"
}

# Install Java
echo -e "\n${BLUE}☕ Installing Java Development Kits...${NC}"
install_java

# Verify installations
echo -e "\n${BLUE}🔍 Verifying Java installations...${NC}"

if [ -d "$JAVA_17_PATH" ]; then
    echo -e "${GREEN}✅ Java 17 found at: $JAVA_17_PATH${NC}"
    echo -e "${BLUE}Version: ${NC}$($JAVA_17_PATH/bin/java -version 2>&1 | head -1)"
else
    echo -e "${RED}❌ Java 17 not found at expected path: $JAVA_17_PATH${NC}"
    echo -e "${YELLOW}Available Java installations:${NC}"
    ls -la /usr/lib/jvm/ | grep java || echo -e "${RED}None found${NC}"
fi

if [ -d "$JAVA_21_PATH" ]; then
    echo -e "${GREEN}✅ Java 21 found at: $JAVA_21_PATH${NC}"
    echo -e "${BLUE}Version: ${NC}$($JAVA_21_PATH/bin/java -version 2>&1 | head -1)"
else
    echo -e "${RED}❌ Java 21 not found at expected path: $JAVA_21_PATH${NC}"
fi

# Test switcher functions if zshrc is already installed
echo -e "\n${BLUE}🔧 Testing Java switcher functions...${NC}"
if [ -f ~/.zshrc ] && grep -q "setJdk17" ~/.zshrc; then
    echo -e "${YELLOW}Testing Java switcher functions...${NC}"
    
    # Source the zshrc in a subshell to test
    (
        source ~/.zshrc 2>/dev/null
        [ -f ~/.zshrc.local ] && source ~/.zshrc.local 2>/dev/null
        
        echo -e "${YELLOW}Testing setJdk17...${NC}"
        setJdk17 2>/dev/null && echo -e "${GREEN}✅ Java 17 switcher works${NC}"
        
        echo -e "${YELLOW}Testing setJdk21...${NC}"
        setJdk21 2>/dev/null && echo -e "${GREEN}✅ Java 21 switcher works${NC}"
    ) || echo -e "${YELLOW}⚠ Install ZSH configuration first to test switcher functions${NC}"
else
    echo -e "${YELLOW}⚠ ZSH configuration not found. Install it to use Java switcher functions.${NC}"
fi

echo
echo -e "${GREEN}✅ Java installation completed!${NC}"
echo
echo -e "${BLUE}Usage after installing ZSH config:${NC}"
echo -e "${BLUE}  • ${YELLOW}setJdk17${NC}    # Switch to Java 17"
echo -e "${BLUE}  • ${YELLOW}setJdk21${NC}    # Switch to Java 21"
echo -e "${BLUE}  • ${YELLOW}java -version${NC}   # Check current version"
echo
