#!/bin/bash
# Interactive master installation script for Linux development environment setup
# Created by Ahmed Gamal (Gemmy) - https://github.com/AhmedGamal2212/my-linux-configs
# Because good developers deserve great development environments ☕

set -e
# Interactive setup with proper dependency order

# Color codes for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored headers
print_header() {
    echo -e "\n${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC} $1"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}\n"
}

# Function to print module info
print_module_info() {
    echo -e "${CYAN}📋 Module: $1${NC}"
    echo -e "${YELLOW}$2${NC}"
    echo
}

# Function to ask for confirmation
ask_confirmation() {
    local module_name="$1"
    local description="$2"
    
    print_module_info "$module_name" "$description"
    read -p "$(echo -e ${GREEN}Continue with this module? [Y/n]:${NC} )" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo -e "${YELLOW}⏭️  Skipping $module_name${NC}"
        return 1
    fi
    return 0
}

print_header "🚀 Linux Development Environment Setup"
echo -e "${GREEN}Welcome to the interactive Linux development environment installer!${NC}"
echo -e "${CYAN}This will set up a modern, powerful development environment with:${NC}"
echo "  • Modern terminal (ZSH + Starship + modern CLI tools)"
echo "  • Development tools and programming languages"
echo "  • Clean configuration files (vim, kitty, etc.)"
echo "  • Optional components (Docker, databases, etc.)"
echo

echo -e "${YELLOW}⚠️  Important Notes:${NC}"
echo "  • Scripts will request sudo permissions when needed"
echo "  • You can skip any module you don't need"
echo "  • Installation follows proper dependency order"
echo "  • Existing configurations will be backed up"
echo

echo -e "${CYAN}🔄 Backup Recommendation:${NC}"
echo -e "  • For comprehensive backup/restore: run ${BLUE}./testing/backup-current-config.sh${NC} first"
echo "  • Individual scripts create simple .backup files"
echo "  • Comprehensive backup allows full system restore if needed"
echo

read -p "$(echo -e ${YELLOW}Create comprehensive backup first? [Y/n]:${NC} )" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    if [ -f testing/backup-current-config.sh ]; then
        echo -e "${BLUE}🔄 Creating comprehensive backup...${NC}"
        cd testing && ./backup-current-config.sh && cd ..
        echo -e "${GREEN}✅ Backup completed - you can restore later if needed${NC}"
        echo
    else
        echo -e "${YELLOW}⚠️  Backup script not found, continuing with installation${NC}"
        echo
    fi
fi

read -p "$(echo -e ${GREEN}Ready to begin installation? [Y/n]:${NC} )" -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo -e "${RED}Installation cancelled.${NC}"
    exit 0
fi

# Module 1: System Preparation and Permissions
if ask_confirmation "System Preparation" "Fix file permissions and make scripts executable.\nEssential for proper installation."; then
    print_header "🔧 System Preparation"
    echo -e "${BLUE}📝 Making scripts executable...${NC}"
    chmod +x */install.sh troubleshooting/fix-permissions.sh
    
    if [ -f troubleshooting/fix-permissions.sh ]; then
        echo -e "${BLUE}🔧 Fixing any existing permission issues...${NC}"
        ./troubleshooting/fix-permissions.sh 2>/dev/null || true
    fi
    echo -e "\n${GREEN}✅ System preparation completed${NC}\n"
fi

# Module 2: Fonts (recommended before terminal)
if ask_confirmation "Fonts Installation" "Install Fira Code and JetBrains Mono fonts.\nRequired for proper terminal display and modern CLI tools."; then
    print_header "🔤 Installing Fonts"
    echo -e "${BLUE}📦 Installing font packages...${NC}"
    cd fonts && ./install.sh && cd ..
    echo -e "\n${GREEN}✅ Fonts installation completed${NC}\n"
fi

# Module 3: Development Environment
if ask_confirmation "Development Environment" "Install core development tools and programming languages.\nIncludes: build tools, git, Rust (required for modern CLI tools).\n🎯 Interactive: You'll choose which languages to install (Python, Node.js, Go)."; then
    print_header "🛠️  Development Environment Setup"
    echo -e "${BLUE}🔧 Setting up development tools...${NC}"
    cd dev && ./install-essentials.sh && cd ..
    echo -e "\n${GREEN}✅ Development environment completed${NC}\n"
fi

# Module 4: Terminal and Shell
if ask_confirmation "Terminal & Shell Setup" "Install and configure ZSH with Oh My Zsh, Starship prompt,\nand modern CLI tools (eza, bat, fd-find, ripgrep, tig, fzf).\nCreates a powerful, beautiful terminal experience."; then
    print_header "🐚 Terminal & Shell Setup"
    echo -e "${BLUE}🐚 Installing ZSH and modern CLI tools...${NC}"
    cd zsh && ./install.sh && cd ..
    echo -e "\n${GREEN}✅ Terminal & shell setup completed${NC}\n"
fi

# Module 5: Terminal Emulator
if ask_confirmation "Kitty Terminal" "Install and configure Kitty terminal emulator.\nModern GPU-accelerated terminal with great font rendering.\nOptional but recommended for best experience."; then
    print_header "🖥️  Terminal Emulator Setup"
    echo -e "${BLUE}🖥️  Installing Kitty terminal emulator...${NC}"
    cd kitty && ./install.sh && cd ..
    echo -e "\n${GREEN}✅ Kitty terminal setup completed${NC}\n"
fi

# Module 6: Editor Configuration
if ask_confirmation "Vim Editor" "Install and configure Vim with development-friendly settings.\nClean, minimal setup with essential features.\nOptional if you use other editors."; then
    print_header "📝 Editor Configuration"
    echo -e "${BLUE}📝 Configuring Vim editor...${NC}"
    cd vim && ./install.sh && cd ..
    echo -e "\n${GREEN}✅ Vim configuration completed${NC}\n"
fi

# Module 7: Java Development (optional)
if ask_confirmation "Java Development" "Install and configure Java development environment.\nIncludes OpenJDK 17 & 21 with version switching.\nOptional - only install if you need Java development."; then
    print_header "☕ Java Development Setup"
    echo -e "${BLUE}☕ Installing Java development environment...${NC}"
    cd java && ./install.sh && cd ..
    echo -e "\n${GREEN}✅ Java development setup completed${NC}\n"
fi

# Module 8: Optional Development Tools
if ask_confirmation "Optional Development Tools" "Install additional development tools:\n• Database clients (SQLite, PostgreSQL, MySQL)\n• Network tools (HTTPie, jq), Archive utilities\n• Docker (interactive choice), neofetch (interactive choice)\n🎯 Interactive: You'll choose specific tools within each category."; then
    print_header "🔧 Optional Development Tools"
    echo -e "${BLUE}🔧 Installing optional development tools...${NC}"
    cd dev && ./install-optional.sh && cd ..
    echo -e "\n${GREEN}✅ Optional tools installation completed${NC}\n"
fi

# Module 9: AppImage Management
if ask_confirmation "AppImage Management" "Set up ~/Applications/ and install two scripts:\n  • appimage-install: install any AppImage as a desktop app\n  • appimage-update:  update an installed AppImage\nOptional — only useful on desktop environments."; then
    print_header "📦 AppImage Management Setup"
    echo -e "${BLUE}📦 Setting up AppImage management...${NC}"
    cd appimages && ./install.sh && cd ..
    echo -e "\n${GREEN}✅ AppImage management setup completed${NC}\n"
fi

# Module 10: Git & Credentials Setup
if ask_confirmation "Git & Credentials" "Set up git credential helper (Bitwarden integration),\nglobal gitignore, and git configuration.\nRequires: Bitwarden CLI (bw) installed separately."; then
    print_header "🔑 Git & Credentials Setup"
    echo -e "${BLUE}🔑 Setting up git credentials...${NC}"
    cd git && ./install.sh && cd ..
    echo -e "\n${GREEN}✅ Git configuration completed${NC}\n"
fi

# Module 11: Post-Setup Verification
if ask_confirmation "Post-Setup Check" "Verify external tools and create local config templates.\nChecks: bw, gh, docker, go, nvm/node.\nCreates ~/.zshrc.local and ~/.zshrc.work templates if missing."; then
    print_header "🔍 Post-Setup Verification"
    echo -e "${BLUE}🔍 Running post-setup checks...${NC}"
    cd post-setup && ./configure.sh && cd ..
    echo -e "\n${GREEN}✅ Post-setup configuration completed${NC}\n"
fi

# Final summary
print_header "🎉 Installation Complete!"
echo -e "${GREEN}Your development environment has been successfully set up!${NC}"
echo
echo -e "${CYAN}🔄 Next Steps:${NC}"
echo -e "1. ${YELLOW}Restart your terminal${NC} or run: ${BLUE}exec zsh${NC}"
echo -e "2. ${YELLOW}Log out and back in${NC} if ZSH was set as default shell"
echo -e "3. ${YELLOW}Test your setup:${NC}"
echo -e "   • Run ${BLUE}starship --version${NC} to verify prompt"
echo -e "   • Try modern CLI tools: ${BLUE}bat, fd, rg, eza${NC}"
echo -e "   • Check programming languages: ${BLUE}python3 --version, go version, node --version${NC}"
echo
echo -e "${CYAN}🔄 Backup & Restore:${NC}"
echo -e "• ${YELLOW}Restore from backup:${NC} ${BLUE}./testing/restore-config.sh <backup-directory>${NC}"
echo -e "• ${YELLOW}Clean test backups:${NC} ${BLUE}./testing/clean-all.sh${NC}"
echo -e "• ${YELLOW}View backup guide:${NC} ${BLUE}testing/README.md${NC}"
echo
echo -e "${CYAN}📚 Resources:${NC}"
echo -e "• Modern CLI tools guide: ${BLUE}dev/MODERN-CLI-TOOLS.md${NC}"
echo -e "• ZSH features reference: ${BLUE}zsh/README.md${NC}"
echo -e "• Development setup: ${BLUE}dev/README.md${NC}"
echo -e "• Backup & testing guide: ${BLUE}testing/README.md${NC}"
echo -e "• Troubleshooting: ${BLUE}troubleshooting/TROUBLESHOOTING.md${NC}"
echo
echo -e "${PURPLE}Enjoy your new development environment! 🚀${NC}"
echo
echo -e "${CYAN}Created with ☕ by Ahmed Gamal (Gemmy)${NC}"
echo -e "${BLUE}GitHub: https://github.com/AhmedGamal2212${NC}"
