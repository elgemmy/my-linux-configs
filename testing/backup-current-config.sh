#!/bin/bash

# ===================================================================
# Backup Current Configuration for Testing
# Created with ☕ by Ahmed Gamal (Gemmy)
# GitHub: https://github.com/AhmedGamal2212
# ===================================================================

# Color codes for better output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m' # No Color

BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo -e "${CYAN}🔄 Creating backup in: ${BLUE}$BACKUP_DIR${NC}"

echo
echo -e "${YELLOW}📦 Backing up configuration files...${NC}"
echo

# Backup ZSH config
if [ -f ~/.zshrc ]; then
    cp ~/.zshrc "$BACKUP_DIR/zshrc.backup"
    echo -e "${GREEN}✅ ZSH config backed up${NC}"
fi

if [ -f ~/.zshrc.local ]; then
    cp ~/.zshrc.local "$BACKUP_DIR/zshrc.local.backup"
    echo -e "${GREEN}✅ ZSH local config backed up${NC}"
fi

# Backup Oh My Zsh
if [ -d ~/.oh-my-zsh ]; then
    cp -r ~/.oh-my-zsh "$BACKUP_DIR/oh-my-zsh.backup"
    echo -e "${GREEN}✅ Oh My Zsh backed up${NC}"
fi

# Backup Vim config
if [ -f ~/.vimrc ]; then
    cp ~/.vimrc "$BACKUP_DIR/vimrc.backup"
    echo -e "${GREEN}✅ Vim config backed up${NC}"
fi

# Backup Kitty config, including sessions
if [ -d ~/.config/kitty ]; then
    cp -r ~/.config/kitty "$BACKUP_DIR/kitty.backup"
    echo -e "${GREEN}✅ Kitty config backed up${NC}"
fi

# Backup editor user settings/keybindings only
backup_editor_config() {
    local name="$1"
    local source_dir="$2"
    local target_dir="$BACKUP_DIR/editors/$name"

    if [ -f "$source_dir/settings.json" ] || [ -f "$source_dir/keybindings.json" ]; then
        mkdir -p "$target_dir"
        [ -f "$source_dir/settings.json" ] && cp "$source_dir/settings.json" "$target_dir/settings.json"
        [ -f "$source_dir/keybindings.json" ] && cp "$source_dir/keybindings.json" "$target_dir/keybindings.json"
        echo -e "${GREEN}✅ $name editor config backed up${NC}"
    fi
}

backup_editor_config "vscode" "$HOME/.config/Code/User"
backup_editor_config "cursor" "$HOME/.config/Cursor/User"
backup_editor_config "zed" "$HOME/.config/zed"

# Backup starship config
if [ -f ~/.config/starship.toml ]; then
    cp ~/.config/starship.toml "$BACKUP_DIR/starship.toml.backup"
    echo -e "${GREEN}✅ Starship config backed up${NC}"
fi

# Record current shell
echo "$SHELL" > "$BACKUP_DIR/current_shell.txt"
echo -e "${GREEN}✅ Current shell recorded${NC}"

echo
echo -e "${GREEN}✅ Backup completed successfully!${NC}"
echo -e "${CYAN}📁 Location: ${BLUE}$BACKUP_DIR${NC}"
echo
echo -e "${YELLOW}To restore later, run:${NC}"
echo -e "  ${BLUE}./restore-config.sh $BACKUP_DIR${NC}"
echo
echo -e "${PURPLE}Ready for testing! 🚀${NC}"
