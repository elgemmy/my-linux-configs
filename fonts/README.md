# Font Installation

The kitty terminal configuration uses per-machine font selection via `kitten choose-fonts`.
Fira Code and JetBrains Mono are installed as baseline development fonts.

Essential development fonts: Fira Code (primary) and JetBrains Mono (backup).

## Quick Setup

### Automatic Installation
```bash
./install.sh
```

### Manual Installation

#### Package Manager (Recommended)
```bash
# Ubuntu/Debian
sudo apt install fonts-firacode

# Fedora
sudo dnf install fira-code-fonts
```

#### Manual Download
```bash
# Create fonts directory
mkdir -p ~/.local/share/fonts

# Download Fira Code
wget https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip
unzip Fira_Code_v6.2.zip
cp ttf/*.ttf ~/.local/share/fonts/

# Update font cache
fc-cache -f
```

## Included Fonts

### Fira Code (Primary)
- **Purpose**: Programming font with ligatures
- **Features**: Combines `->`, `=>`, `!=` into single glyphs
- **Use**: Code editors, terminals

### JetBrains Mono (Backup)
- **Purpose**: Monospace font for developers
- **Features**: Excellent readability, wide character support
- **Use**: IDEs, terminals when Fira Code unavailable

## Verification

```bash
# Check installed fonts
fc-list | grep -i fira
fc-list | grep -i jetbrains

# Test font availability
fc-match "Fira Code"
```

## Application Configuration

### Kitty Terminal
```conf
font_family Fira Code Bold
```

### VS Code
```json
{
    "editor.fontFamily": "'Fira Code', 'JetBrains Mono', monospace",
    "editor.fontLigatures": true
}
```

## Troubleshooting

**Fonts not appearing:**
- Rebuild font cache: `fc-cache -f`
- Check permissions: `ls -la ~/.local/share/fonts/`
- Restart applications

**Ligatures not working:**
- Enable ligatures in application settings
- Verify font supports ligatures
- Use correct font name in configuration
