# Development Environment Setup

This guide covers programming languages and development tools **not included** in the dotfiles install scripts.

## Core Development Tools

### System Build Tools (Essential)
```bash
# Ubuntu/Debian-based distributions
sudo apt update && sudo apt install -y build-essential curl git wget

# Fedora
sudo dnf install -y @development-tools curl git wget
```

## Programming Languages

### Java Development (OpenJDK 17 & 21)
**See `java/` directory for complete Java installation and setup.**

After Java installation, test the ZSH switcher:
```bash
source ~/.zshrc  # Use 'source ~/.bashrc' if not using ZSH
setJdk17  # Switch to Java 17
setJdk21  # Switch to Java 21
```

### Python Development
```bash
# Ubuntu/Debian
sudo apt install -y python3 python3-pip python3-venv python3-dev

# Fedora
sudo dnf install -y python3 python3-pip python3-devel

# Essential Python tools (user-level, no sudo)
# Note: pip requires Python >=3.9 (latest pip 25.2)
pip3 install --user --upgrade pip setuptools wheel

# Verify Python and pip versions
python3 --version  # Should be 3.9+ for latest pip compatibility
pip3 --version     # Should be 25.x for latest features
```

### Go Development
```bash
# Install Go (latest version - recommended)
# Easy Go installer from https://github.com/kerolloz/go-installer
# Doesn't download the script ~ runs the script directly
bash <(curl -sL https://raw.githubusercontent.com/kerolloz/go-installer/master/go-installer.sh)
# Or see https://go.dev/doc/install for the official method.

# Verify Go setup (paths already configured in ZSH config)
source ~/.zshrc  # Use 'source ~/.bashrc' if not using ZSH
go version
```

### Node.js Development (Recommended: NVM)
```bash
# Install NVM (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# Restart terminal or reload
source ~/.zshrc  # Use 'source ~/.bashrc' if not using ZSH

# Install latest LTS
nvm install --lts
nvm use --lts  
nvm alias default lts/*

# Alternative: System packages (less flexible)
# Ubuntu: sudo apt install nodejs npm
# Fedora: sudo dnf install nodejs npm
```

> **Note:** NVM loading is configured in `~/.zshrc.local` (created by `post-setup/configure.sh`). It is not in the base zshrc.

## Quick Installation Scripts

### Essential Development Environment
```bash
# Install all essential development tools at once
./install-essentials.sh
```

### Optional Development Tools  
```bash
# Install optional tools (databases, containers, etc.)
./install-optional.sh
```

## Additional Development Tools

### Database Development
```bash
# SQLite (lightweight)
sudo apt install sqlite3  # Ubuntu
sudo dnf install sqlite   # Fedora

# PostgreSQL client
sudo apt install postgresql-client  # Ubuntu
sudo dnf install postgresql         # Fedora

# MySQL client  
sudo apt install mysql-client  # Ubuntu
sudo dnf install mysql         # Fedora
```

### Network and API Development
```bash
# Modern HTTP clients
sudo apt install httpie  # Ubuntu
sudo dnf install httpie  # Fedora

# Alternative: Install via pip
pip3 install --user httpie

# cURL (usually pre-installed)
curl --version
```

### Container Development
```bash
# Docker — see official docs for your distro:
# https://docs.docker.com/engine/install/

# Fedora
sudo dnf install docker docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

# Note: Log out and back in for group changes to take effect
```

## Verification Commands

### Language Versions
```bash
echo "=== Programming Languages ==="
echo "Git: $(git --version)"
echo "Python: $(python3 --version)"
echo "Go: $(go version 2>/dev/null || echo 'Not installed')"
echo "Node.js: $(node --version 2>/dev/null || echo 'Not installed via NVM')"
echo "Java: $(java -version 2>&1 | head -1)"
echo "GCC: $(gcc --version | head -1)"
```

### Development Tools
```bash
echo "=== Development Tools ==="
echo "Make: $(make --version | head -1)"
echo "SQLite: $(sqlite3 --version 2>/dev/null || echo 'Not installed')"
echo "Docker: $(docker --version 2>/dev/null || echo 'Not installed')"
echo "HTTPie: $(http --version 2>/dev/null || echo 'Not installed')"
```

### ZSH Integration Test
```bash
echo "=== ZSH Integration ==="
# Test Java switcher (after ZSH install)
setJdk17 && echo "Java 17: $(java -version 2>&1 | head -1)"
setJdk21 && echo "Java 21: $(java -version 2>&1 | head -1)"

# Test Go setup
echo "Go workspace: $GOPATH"
echo "Go binary path: $(which go)"

# Test Python tools
echo "Python user packages: ~/.local/bin in PATH: $(echo $PATH | grep -q ~/.local/bin && echo 'Yes' || echo 'No')"
```

## Language-Specific Setup

### Go Workspace
```bash
# Workspace directory (already configured in ZSH)
mkdir -p ~/go/{bin,src,pkg}

# Test Go installation
go version
go env GOPATH
go env GOROOT

# Install common Go tools
go install golang.org/x/tools/gopls@latest  # Language server
go install github.com/go-delve/delve/cmd/dlv@latest  # Debugger
```

### Python Virtual Environments
```bash
# Create project-specific environments
mkdir -p ~/Projects/python
cd ~/Projects/python

# Create virtual environment for a project
python3 -m venv myproject-env
source myproject-env/bin/activate
pip install --upgrade pip

# Deactivate when done
deactivate
```

### Node.js Project Setup
```bash
# After installing via NVM
# Create a new project
mkdir -p ~/Projects/nodejs/myproject
cd ~/Projects/nodejs/myproject

# Initialize Node.js project
npm init -y
npm install --save-dev eslint prettier

# Use specific Node version for project
echo "22.19.0" > .nvmrc  # Current LTS
nvm use

# Install project dependencies
npm install express  # Example framework
```

## Troubleshooting

### Common Issues

**Go not found after installation:**
```bash
# Check if /usr/local/go/bin is in PATH (ZSH config handles this)
echo $PATH | grep -q /usr/local/go/bin && echo "In PATH" || echo "Missing from PATH"

# Restart terminal after ZSH installation
```

**Python packages not found:**
```bash
# Ensure ~/.local/bin is in PATH (ZSH config handles this)
echo $PATH | grep -q ~/.local/bin && echo "In PATH" || echo "Missing from PATH"
```

**Java switcher not working:**
```bash
# Ensure ZSH config is installed and sourced
source ~/.zshrc  # Use 'source ~/.bashrc' if not using ZSH
type setJdk17  # Should show function definition
```

**Docker permission denied:**
```bash
# Add user to docker group and restart
sudo usermod -aG docker $USER
# Log out and back in, or restart system
```
