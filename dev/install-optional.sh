#!/bin/bash
# Optional development tools installation script

set -e

# Color codes for better output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Optional Development Tools Setup ===${NC}"
echo -e "${BLUE}Installing additional development tools and utilities...${NC}"
echo

# Detect package manager
if command -v apt &> /dev/null; then
    PKG_MANAGER="apt"
    INSTALL_CMD="sudo apt install -y"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    INSTALL_CMD="sudo dnf install -y"
elif command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
    INSTALL_CMD="sudo pacman -S --noconfirm"
else
    echo "❌ Unsupported package manager. This script supports apt (Ubuntu/Debian), dnf (Fedora), and pacman (Arch Linux)."
    exit 1
fi

echo -e "${CYAN}📦 Using package manager: $PKG_MANAGER${NC}"
echo

# Function to install with error handling
install_package() {
    local package=$1
    local description=$2

    echo -e "${YELLOW}📦 Installing $description ($package)...${NC}"
    if $INSTALL_CMD $package; then
        echo -e "${GREEN}✅ $description installed successfully${NC}"
    else
        echo -e "${RED}⚠️  Failed to install $description - may not be available in repositories${NC}"
    fi
    echo
}

# Database tools (interactive)
echo -e "${BLUE}🗄️  Database Tools Installation${NC}"
read -p "Do you want to install database client tools (SQLite, PostgreSQL, MySQL)? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Installing database tools...${NC}"
    install_package "sqlite3" "SQLite database"

    if [ "$PKG_MANAGER" = "apt" ]; then
        install_package "postgresql-client" "PostgreSQL client"
        install_package "mysql-client" "MySQL client"
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        install_package "postgresql" "PostgreSQL client"
        install_package "mysql" "MySQL client"
    elif [ "$PKG_MANAGER" = "pacman" ]; then
        install_package "postgresql-libs" "PostgreSQL client"
        install_package "mariadb-clients" "MySQL/MariaDB client"
    fi
else
    echo -e "${YELLOW}⏭️  Skipping database tools installation${NC}"
    echo
fi

# Network and API tools (interactive)
echo -e "${BLUE}🌐 Network and API Tools Installation${NC}"
read -p "Do you want to install network and API tools (HTTPie, jq, nmap, net-tools)? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Installing network and API tools...${NC}"
    install_package "httpie" "HTTPie (modern HTTP client)"
    install_package "jq" "JSON processor"

    if [ "$PKG_MANAGER" = "apt" ]; then
        install_package "net-tools" "Network utilities"
        install_package "nmap" "Network mapper"
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        install_package "net-tools" "Network utilities"
        install_package "nmap" "Network mapper"
    elif [ "$PKG_MANAGER" = "pacman" ]; then
        install_package "net-tools" "Network utilities"
        install_package "nmap" "Network mapper"
    fi
else
    echo -e "${YELLOW}⏭️  Skipping network and API tools installation${NC}"
    echo
fi

# System monitoring and utilities (interactive)
echo -e "${BLUE}🖥️  System Utilities Installation${NC}"
read -p "Do you want to install system utilities (htop, tree)? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Installing system utilities...${NC}"
    install_package "htop" "Interactive process viewer"
    install_package "tree" "Directory tree viewer"
else
    echo -e "${YELLOW}⏭️  Skipping system utilities installation${NC}"
    echo
fi

# Optional eye candy
echo -e "${BLUE}🎨 System Information Display${NC}"
read -p "Install neofetch (system info display)? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    install_package "neofetch" "System information tool"
else
    echo -e "${YELLOW}⏭️  Skipping neofetch installation${NC}"
    echo
fi

# Archive tools (interactive)
echo -e "${BLUE}📦 Archive Utilities Installation${NC}"
read -p "Do you want to install archive utilities (unzip, 7zip)? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Installing archive utilities...${NC}"
    if [ "$PKG_MANAGER" = "apt" ]; then
        install_package "unzip" "Unzip utility"
        install_package "p7zip-full" "7-Zip archive tool"
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        install_package "unzip" "Unzip utility"
        install_package "p7zip" "7-Zip archive tool"
    elif [ "$PKG_MANAGER" = "pacman" ]; then
        install_package "unzip" "Unzip utility"
        install_package "p7zip" "7-Zip archive tool"
    fi
else
    echo -e "${YELLOW}⏭️  Skipping archive utilities installation${NC}"
    echo
fi

# Modern CLI alternatives (interactive)
echo -e "${BLUE}⚡ Modern CLI Tools Installation${NC}"
read -p "Do you want to install modern CLI tools (bat, fd-find, ripgrep)? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Installing modern CLI tools...${NC}"
    if [ "$PKG_MANAGER" = "apt" ]; then
        install_package "bat" "Modern cat alternative (syntax highlighting)"
        install_package "fd-find" "Modern find alternative"
        install_package "ripgrep" "Modern grep alternative"
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        install_package "bat" "Modern cat alternative"
        install_package "fd-find" "Modern find alternative"
        install_package "ripgrep" "Modern grep alternative"
    elif [ "$PKG_MANAGER" = "pacman" ]; then
        install_package "bat" "Modern cat alternative"
        install_package "fd" "Modern find alternative"
        install_package "ripgrep" "Modern grep alternative"
    fi
else
    echo -e "${YELLOW}⏭️  Skipping modern CLI tools installation${NC}"
    echo
fi

# Docker installation (optional, requires user confirmation)
echo -e "${BLUE}🐳 Docker Installation${NC}"
read -p "Do you want to install Docker? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Installing Docker...${NC}"

    if [ "$PKG_MANAGER" = "apt" ]; then
        # Docker official installation script
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        rm get-docker.sh

        # Add user to docker group
        sudo usermod -aG docker $USER
        echo -e "${GREEN}✅ Docker installed. Log out and back in to use docker without sudo.${NC}"

    elif [ "$PKG_MANAGER" = "dnf" ]; then
        $INSTALL_CMD docker docker-compose
        sudo systemctl enable --now docker
        sudo usermod -aG docker $USER
        echo -e "${GREEN}✅ Docker installed and enabled. Log out and back in to use docker without sudo.${NC}"

    elif [ "$PKG_MANAGER" = "pacman" ]; then
        $INSTALL_CMD docker docker-compose
        sudo systemctl enable --now docker
        sudo usermod -aG docker $USER
        echo -e "${GREEN}✅ Docker installed and enabled. Log out and back in to use docker without sudo.${NC}"
    fi
else
    echo -e "${YELLOW}⏭️  Skipping Docker installation${NC}"
    echo
fi

# Python development tools (interactive)
echo -e "${BLUE}🐍 Python Development Tools${NC}"
read -p "Do you want to install Python development tools (black, flake8, mypy)? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Installing Python development packages...${NC}"
    pip3 install --user httpie black flake8 mypy 2>/dev/null || echo -e "${RED}⚠️  Some Python packages may not be available${NC}"
    echo -e "${GREEN}✅ Python tools installation completed${NC}"
else
    echo -e "${YELLOW}⏭️  Skipping Python development tools${NC}"
fi
echo

# Go development tools (if Go is installed)
if command -v go &> /dev/null; then
    echo -e "${BLUE}🐹 Go Development Tools${NC}"
    read -p "Do you want to install Go development tools (gopls, delve)? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Installing Go language server and debugger...${NC}"
        go install golang.org/x/tools/gopls@latest 2>/dev/null || echo -e "${RED}⚠️  Failed to install gopls${NC}"
        go install github.com/go-delve/delve/cmd/dlv@latest 2>/dev/null || echo -e "${RED}⚠️  Failed to install delve debugger${NC}"
        echo -e "${GREEN}✅ Go tools installation completed${NC}"
    else
        echo -e "${YELLOW}⏭️  Skipping Go development tools${NC}"
    fi
else
    echo -e "${YELLOW}⏭️  Go not found, skipping Go tools${NC}"
fi
echo

echo
echo -e "${GREEN}✅ Optional development tools installation completed!${NC}"
echo
echo -e "${CYAN}📋 Installation Summary:${NC}"
echo -e "${BLUE}The following tools were selectively installed based on your choices:${NC}"
echo -e "${BLUE}  • Database clients (SQLite, PostgreSQL, MySQL)${NC}"
echo -e "${BLUE}  • Network tools (HTTPie, jq, nmap, net-tools)${NC}"
echo -e "${BLUE}  • System utilities (htop, neofetch, tree)${NC}"
echo -e "${BLUE}  • Archive tools (unzip, 7zip)${NC}"
echo -e "${BLUE}  • Modern CLI alternatives (bat, fd, ripgrep)${NC}"
echo -e "${BLUE}  • Python development tools (black, flake8, mypy)${NC}"
echo -e "${BLUE}  • Go development tools (gopls, delve)${NC}"
echo -e "${BLUE}  • Docker and Docker Compose${NC}"
echo
echo -e "${CYAN}🔄 Next Steps:${NC}"
echo -e "${YELLOW}  • Restart terminal for new tools to be available${NC}"
echo -e "${YELLOW}  • Test tools with verification commands in DEVELOPMENT.md${NC}"
echo -e "${YELLOW}  • Log out and back in to use Docker without sudo (if installed)${NC}"
echo -e "${YELLOW}  • See MODERN-CLI-TOOLS.md for usage guides${NC}"
