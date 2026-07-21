# Troubleshooting Guide

Common issues and solutions for dotfiles installation.

## Permission Denied Errors

### Quick Fixes
```bash
# Make install scripts executable
chmod +x */install.sh

# Fix config file permissions (most common issue)
sudo chown -R $USER:$USER ~/.vimrc ~/.vim/ ~/.config/ ~/.zshrc ~/.oh-my-zsh/ 2>/dev/null || true

# Run comprehensive permission fix
./fix-permissions.sh
```

### Root Cause
Usually caused by:
- Previously running `sudo vim` or config tools as root
- Extracting dotfiles as root user
- Home directory permission issues

### Nuclear Option
```bash
# Remove all configs and start fresh
sudo rm -rf ~/.vimrc ~/.vim ~/.config/kitty ~/.zshrc ~/.oh-my-zsh
sudo chown -R $USER:$USER ~/
# Then run install scripts again
```

## Script Execution Issues

### Scripts Won't Run
```bash
# Make executable
chmod +x vim/install.sh

# Or run directly with bash
bash vim/install.sh
```

### Package Installation Fails
```bash
# Update package lists first
sudo apt update    # Debian/Ubuntu

# Check internet connection
ping google.com
```

## Font Issues

### Fonts Not Appearing
```bash
# Rebuild font cache
fc-cache -f

# Check font installation
fc-list | grep -i fira
```

### Kitty Shows Wrong Font
- Restart Kitty terminal
- Check font name in config matches installed font
- Install Fira Code: `cd fonts && ./install.sh`

## ZSH Issues

### Oh My Zsh Installation Fails
```bash
# Install dependencies first
sudo apt install curl git    # Debian/Ubuntu

# Manual Oh My Zsh install
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Plugins Not Loading
```bash
# Check plugin directories exist
ls ~/.oh-my-zsh/custom/plugins/

# Reinstall plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
```

### Java Switcher Not Working
```bash
# Install Java first
sudo apt install openjdk-17-jdk openjdk-21-jdk    # Debian/Ubuntu

# Check Java paths match your system
ls /usr/lib/jvm/

```

## Vim Issues

### Clipboard Not Working
```bash
# Check clipboard support
vim --version | grep clipboard

# Install clipboard support
sudo apt install vim-gtk3 xclip    # Debian/Ubuntu
```

### Config Not Loading
```bash
# Check config exists and is readable
ls -la ~/.vimrc

# Test config syntax
vim -c "syntax on" -c "q" /dev/null
```

## GitHub Authentication Issues

### Git Still Prompting for Credentials
```bash
# Prefer SSH remotes for GitHub repos
git remote -v
git remote set-url origin git@github.com:<user>/<repo>.git

# Or authenticate GitHub CLI for gh commands
gh auth login
gh auth status
```

This repo intentionally does not configure a Git credential helper. If you use
HTTPS remotes, configure your preferred credential manager outside this repo.

## .zshrc.local Issues

### Helpers Not Loading
```bash
# Check if .zshrc.local exists and is sourced
cat ~/.zshrc.local

# The base zshrc sources it automatically:
# [ -f ~/.zshrc.local ] && source ~/.zshrc.local

# Re-run install scripts to re-add helpers:
cd dev && ./install-optional.sh   # Re-adds Docker/PostgreSQL helpers
cd kitty && ./install.sh          # Re-adds kitty aliases
```

### Duplicate Entries
```bash
# Install scripts use marker comments to prevent duplicates
# If you see duplicates, remove the duplicate block manually
# Look for markers like: # --- docker-helpers-start --- / # --- docker-helpers-end ---
```

## Getting Help

1. **Check this troubleshooting guide first**
2. **Run the permission fix script**: `./fix-permissions.sh`
3. **Try manual installation** using README instructions
4. **Check Debian/Ubuntu version-specific package availability**

## Prevention

```bash
# Before installing dotfiles, always run:
echo "User: $(whoami)"
echo "Home writable: $([ -w ~ ] && echo 'Yes' || echo 'No')"
sudo chown -R $USER:$USER ~/
chmod +x */install.sh
```
