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

# Function to detect system and install Java
install_java() {
    if command -v apt &> /dev/null; then
        echo -e "${YELLOW}Installing Java on Ubuntu/Debian system...${NC}"
        sudo apt update
        sudo apt install -y openjdk-17-jdk openjdk-21-jdk
        echo -e "${GREEN}✅ Java packages installed${NC}"

        # Verify Ubuntu/Debian paths
        JAVA_17_PATH="/usr/lib/jvm/java-17-openjdk-amd64"
        JAVA_21_PATH="/usr/lib/jvm/java-21-openjdk-amd64"

    elif command -v dnf &> /dev/null; then
        echo -e "${YELLOW}Installing Java on Fedora system...${NC}"
        sudo dnf install -y java-17-openjdk-devel java-21-openjdk-devel
        echo -e "${GREEN}✅ Java packages installed${NC}"

        # Fedora uses different paths
        JAVA_17_PATH="/usr/lib/jvm/java-17-openjdk"
        JAVA_21_PATH="/usr/lib/jvm/java-21-openjdk"

        # Set up alternatives system for Fedora
        echo -e "${YELLOW}Setting up Java alternatives system for Fedora...${NC}"
        sudo alternatives --install /usr/bin/java java ${JAVA_17_PATH}/bin/java 1700000 \
            --slave /usr/bin/javac javac ${JAVA_17_PATH}/bin/javac \
            --slave /usr/bin/jar jar ${JAVA_17_PATH}/bin/jar \
            --slave /usr/bin/javadoc javadoc ${JAVA_17_PATH}/bin/javadoc

        sudo alternatives --install /usr/bin/java java ${JAVA_21_PATH}/bin/java 2100000 \
            --slave /usr/bin/javac javac ${JAVA_21_PATH}/bin/javac \
            --slave /usr/bin/jar jar ${JAVA_21_PATH}/bin/jar \
            --slave /usr/bin/javadoc javadoc ${JAVA_21_PATH}/bin/javadoc

        # Set Java 21 as default
        sudo alternatives --set java ${JAVA_21_PATH}/bin/java
        echo -e "${GREEN}✅ Java alternatives configured (Java 21 set as default)${NC}"

        # Create local config for Fedora paths
        echo -e "${YELLOW}Creating ~/.zshrc.local with Fedora-specific Java paths...${NC}"
        cat >> ~/.zshrc.local << EOF
# Fedora Java paths (overrides zshrc defaults)
export JAVA_HOME_17=$JAVA_17_PATH
export JAVA_HOME_21=$JAVA_21_PATH
EOF
        echo -e "${GREEN}✅ Fedora paths configured${NC}"

    elif command -v pacman &> /dev/null; then
        echo -e "${YELLOW}Installing Java on Arch Linux system...${NC}"
        sudo pacman -Sy --noconfirm jdk17-openjdk jdk21-openjdk
        echo -e "${GREEN}✅ Java packages installed${NC}"

        # Arch Java paths
        JAVA_17_PATH="/usr/lib/jvm/java-17-openjdk"
        JAVA_21_PATH="/usr/lib/jvm/java-21-openjdk"

        # Set up archlinux-java (Arch's Java version manager)
        echo -e "${YELLOW}Setting up Java version management for Arch Linux...${NC}"

        # Set Java 21 as default using archlinux-java
        sudo archlinux-java set java-21-openjdk 2>/dev/null || true
        echo -e "${GREEN}✅ Java 21 set as default${NC}"

        # Create local config for Arch paths
        echo -e "${YELLOW}Creating ~/.zshrc.local with Arch-specific Java paths...${NC}"
        cat >> ~/.zshrc.local << EOF
# Arch Linux Java paths (overrides zshrc defaults)
export JAVA_HOME_17=$JAVA_17_PATH
export JAVA_HOME_21=$JAVA_21_PATH

# Arch-specific Java version switcher functions
setJdk17() {
    sudo archlinux-java set java-17-openjdk
    export JAVA_HOME=\$JAVA_HOME_17
    export PATH=\$JAVA_HOME/bin:\$PATH
    echo "Switched to Java 17"
    java -version
}

setJdk21() {
    sudo archlinux-java set java-21-openjdk
    export JAVA_HOME=\$JAVA_HOME_21
    export PATH=\$JAVA_HOME/bin:\$PATH
    echo "Switched to Java 21"
    java -version
}
EOF
        echo -e "${GREEN}✅ Arch paths and switcher functions configured${NC}"

    else
        echo -e "${RED}Package manager not supported. Please install Java manually.${NC}"
        exit 1
    fi
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
if command -v dnf &> /dev/null; then
    echo -e "${YELLOW}Note: Fedora-specific paths have been added to ~/.zshrc.local${NC}"
elif command -v pacman &> /dev/null; then
    echo -e "${YELLOW}Note: Arch Linux-specific paths and functions have been added to ~/.zshrc.local${NC}"
    echo -e "${BLUE}Arch also provides ${YELLOW}archlinux-java status${NC} to view all installed Java versions${NC}"
fi
