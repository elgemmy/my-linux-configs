# Linux Config Repository

## Overview
Clean, modular dotfiles for quick Linux development environment setup on Debian and Fedora distros.

## Repository Structure
```
my-linux-config/
├── README.md
├── install.sh          # 🚀 Interactive master installer
├── dev/
│   ├── README.md
│   ├── MODERN-CLI-TOOLS.md
│   ├── install-essentials.sh
│   └── install-optional.sh
├── vim/
│   ├── vimrc
│   ├── install.sh
│   └── README.md
├── kitty/
│   ├── kitty.conf
│   ├── install.sh
│   └── README.md
├── zsh/
│   ├── zshrc
│   ├── install.sh
│   └── README.md
├── git/
│   ├── git-credential-bitwarden
│   ├── gitignore_global
│   ├── gitconfig.template
│   ├── install.sh
│   └── README.md
├── post-setup/
│   ├── check.sh
│   ├── configure.sh
│   └── README.md
├── java/
│   ├── GUIDE.md
│   ├── install.sh
│   └── README.md
├── fonts/
│   ├── install.sh
│   └── README.md
├── appimages/
│   ├── bin/
│   │   ├── appimage-install
│   │   ├── appimage-update
│   │   └── appimage-uninstall
│   ├── install.sh
│   └── README.md
└── troubleshooting/
    ├── TROUBLESHOOTING.md
    └── fix-permissions.sh
```

## Quick Setup

### 🚀 Interactive Installation (Recommended)
The easiest way to set up your development environment:

```bash
./install.sh
```

**Features:**
- **Interactive guidance** - Clear descriptions for each module
- **Selective installation** - Choose only what you need
- **Proper dependency order** - Automatically handles prerequisites
- **Colorful progress** - Visual feedback throughout the process
- **Safety checks** - Backs up existing configurations

**What you'll choose:**
1. **System preparation** (permissions, script setup)
2. **Fonts** (Fira Code, JetBrains Mono) 
3. **Development environment** (languages: Python, Node.js, Go - your choice)
4. **Terminal & shell** (ZSH + modern CLI tools)
5. **Terminal emulator** (Kitty - optional)
6. **Editor** (Vim configuration - optional)
7. **Java development** (OpenJDK 17 & 21 - optional)
8. **Additional tools** (databases, Docker, etc. - selective)
9. **AppImage management** (`appimage-install` / `appimage-update` scripts - optional, desktop only)
10. **Git & credentials** (Bitwarden credential helper, gitignore)
11. **Post-setup check** (verify external tools, create config templates)

### ⚡ One-Command Setup
For a complete development environment with sensible defaults:
```bash
# Clone and run (press 'Y' for recommended modules)
git clone <repository-url>
cd my-linux-configs
./install.sh
```

## Manual Installation

### 🔄 Backup First (Recommended)
Before manual installation, create a comprehensive backup of your current configuration:

```bash
# Create timestamped backup of current configs
./testing/backup-current-config.sh

# This backs up: ~/.zshrc, ~/.vimrc, ~/.config/kitty/, ~/.config/starship.toml, 
# ~/.oh-my-zsh/, and your current shell setting
```

**Restore Instructions:**
```bash
# If you need to restore later
./testing/restore-config.sh ~/.config-backup-YYYYMMDD-HHMMSS

# Clean up test backups when done
./testing/clean-all.sh
```

### System Preparation
```bash
# Fix any permission issues first (if needed)
./troubleshooting/fix-permissions.sh

# Make scripts executable
chmod +x */install.sh

# Install system build tools (required for development)
# Ubuntu/Debian: sudo apt update && sudo apt install -y build-essential curl git wget
# Fedora: sudo dnf install -y @development-tools curl git wget
```

### Component Installation Order
Install components in the recommended order for best results:

```bash
# 1. Fonts (needed for terminal display)
cd fonts && ./install.sh

# 2. Development environment (see dev/README.md for details)
cd dev && ./install-essentials.sh
cd dev && ./install-optional.sh  # optional tools

# 3. Java development (see java/README.md for details)
cd java && ./install.sh

# 4. Terminal & shell
cd zsh && ./install.sh    # ZSH + modern CLI tools
cd kitty && ./install.sh  # terminal emulator (optional)

# 5. Editor
cd vim && ./install.sh    # vim configuration (optional)
```

### Manual Configuration Fallback
If installation scripts fail, manually copy configuration files:

```bash
# System preparation
cp vim/vimrc ~/.vimrc
mkdir -p ~/.config/kitty && cp kitty/kitty.conf ~/.config/kitty/
cp zsh/zshrc ~/.zshrc
```


## Features

### Vim Configuration
- Clean, minimal setup with essential development features
- System clipboard integration
- Vim motions and keyboard-centric workflow
- Smart search and navigation

### Kitty Terminal
- Customizable fonts and themes (per-machine via kitten themes)
- Vim-style pane/tab navigation
- Efficient keybindings for tab and window management
- Performance optimizations

### ZSH Shell
- Oh My Zsh framework with intelligent completions
- **Starship prompt** - Fast, cross-platform, highly customizable prompt
- Custom aliases and productivity shortcuts
- Git integration and status indicators  
- Syntax highlighting and auto-suggestions
- **☕ Coffee-Powered Features** - Because I can't let my caffeine addiction leave me anywhere I go, I've baked coffee into the terminal itself:
  - Daily coffee quotes and programming wisdom
  - Coffee quotes on terminal startup

### Fonts
- Fira Code (primary) with JetBrains Mono backup
- Automatic installation and fallback handling

### AppImage Management
- `appimage-install` — one command to turn any AppImage into a proper desktop app (icon, launcher entry, URI scheme handler)
- `appimage-update` — one command to update any installed AppImage and refresh its icon
- Follows the XDG desktop entry spec; works across GNOME, KDE, and other desktop environments
- See `appimages/README.md` for full documentation

### Extension Files
The ZSH configuration supports machine-specific and work-specific extensions:
- `~/.zshrc.local` — Machine-specific config (NVM loading, extra PATHs, tool-specific helpers installed on-demand)
- `~/.zshrc.work` — Work-specific functions and aliases (not tracked in this repo)

Docker, PostgreSQL, and Kitty shell helpers are automatically appended to `~/.zshrc.local` by their respective install scripts.

### Post-Setup (External Tools)
Some tools have their own installers and shouldn't be automated:
- **Bitwarden CLI** (`bw`) — for credential management
- **GitHub CLI** (`gh`) — for GitHub operations
- **Docker** — kernel-level changes, group membership
- **Go** — official installer at go.dev

Run `post-setup/check.sh` to see what's installed and get install instructions for missing tools.
Run `post-setup/configure.sh` to wire up credentials and create config templates.

## Supported Systems
- Ubuntu/Debian-based distributions (Ubuntu, Linux Mint, Pop!_OS, Elementary OS, etc.)
- Fedora and Red Hat-based distributions

## Installation Scripts
- Automatic package manager detection (apt/dnf)
- Safe backup of existing configurations
- Error handling and verification
- Minimal dependencies and complexity

## Troubleshooting

### Permission Denied Errors
If install scripts fail with permission errors:

```bash
# Quick fix - make scripts executable
chmod +x */install.sh

# Fix config file permissions (if previously created as root)
sudo chown -R $USER:$USER ~/.vimrc ~/.vim/ ~/.config/ ~/.zshrc

# Run the fix-permissions script (nuclear option)
./troubleshooting/fix-permissions.sh
```

### Common Issues

- **Scripts not executable:** Run `chmod +x */install.sh`
- **Config files owned by root:** Run permission fix command above
- **Home directory permission issues:** Run `sudo chown -R $USER:$USER ~/`
