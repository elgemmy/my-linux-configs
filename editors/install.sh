#!/bin/bash
# Restore editor settings and extensions for editors available on this machine.

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Editor Configuration Setup ===${NC}"

install_vscode_like() {
    local name="$1"
    local cli="$2"
    local user_dir="$3"
    local source_dir="$4"

    if ! command -v "$cli" &> /dev/null && [ ! -d "$user_dir" ]; then
        echo -e "${YELLOW}Skipping $name: CLI and config directory not found.${NC}"
        return
    fi

    echo -e "\n${BLUE}Configuring $name...${NC}"
    mkdir -p "$user_dir"

    if [ -f "$user_dir/settings.json" ]; then
        cp "$user_dir/settings.json" "$user_dir/settings.json.backup"
    fi
    if [ -f "$user_dir/keybindings.json" ]; then
        cp "$user_dir/keybindings.json" "$user_dir/keybindings.json.backup"
    fi

    cp "$source_dir/settings.json" "$user_dir/settings.json"
    cp "$source_dir/keybindings.json" "$user_dir/keybindings.json"
    echo -e "${GREEN}✅ $name settings installed${NC}"

    if command -v "$cli" &> /dev/null && [ -f "$source_dir/extensions.txt" ]; then
        echo -e "${BLUE}Installing $name extensions...${NC}"
        while IFS= read -r extension; do
            [[ -z "$extension" || "$extension" =~ ^# ]] && continue
            "$cli" --install-extension "$extension" --force || true
        done < "$source_dir/extensions.txt"
        echo -e "${GREEN}✅ $name extensions processed${NC}"
    else
        echo -e "${YELLOW}Skipping $name extensions: $cli command not found.${NC}"
    fi
}

install_zed() {
    local user_dir="$HOME/.config/zed"

    if ! command -v zed &> /dev/null && [ ! -d "$user_dir" ]; then
        echo -e "${YELLOW}Skipping Zed: CLI and config directory not found.${NC}"
        return
    fi

    echo -e "\n${BLUE}Configuring Zed...${NC}"
    mkdir -p "$user_dir"
    if [ -f "$user_dir/settings.json" ]; then
        cp "$user_dir/settings.json" "$user_dir/settings.json.backup"
    fi
    cp zed/settings.json "$user_dir/settings.json"
    echo -e "${GREEN}✅ Zed settings installed${NC}"
    echo -e "${YELLOW}Install Zed extensions manually from editors/zed/extensions.txt.${NC}"
}

install_vscode_like "VS Code" "code" "$HOME/.config/Code/User" "vscode"
install_vscode_like "Cursor" "cursor" "$HOME/.config/Cursor/User" "cursor"
install_zed

echo -e "\n${GREEN}✅ Editor configuration completed${NC}"
