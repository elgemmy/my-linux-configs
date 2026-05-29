# Kitty Terminal Configuration

High-performance terminal emulator configuration with vim-style navigation.

## Quick Setup

### Automatic Installation
```bash
./install.sh
```

### Manual Installation
```bash
# Install kitty
sudo apt install kitty         # Ubuntu/Debian
sudo dnf install kitty         # Fedora

# Copy configuration
mkdir -p ~/.config/kitty
cp kitty.conf ~/.config/kitty/kitty.conf
mkdir -p ~/.config/kitty/sessions
cp sessions/daily.kitty-session ~/.config/kitty/sessions/daily.kitty-session

# Optional desktop launcher for the daily session
mkdir -p ~/.local/share/applications
KITTY_BIN="$(command -v kitty || printf kitty)"
sed -e "s|__HOME__|$HOME|g" -e "s|__KITTY__|$KITTY_BIN|g" desktop/kdev.desktop > ~/.local/share/applications/kdev.desktop

# Pick a theme
kitten themes
```

## Key Features

- **Vim-style navigation** — directional pane movement, linear tab switching
- **Background opacity** with dynamic adjustment
- **GPU acceleration** for smooth performance
- **Session management** — save and restore workspace layouts
- **Daily session launcher** — `kdev` alias plus an app launcher for `daily.kitty-session`
- **Customizable fonts and themes** (per-machine via `kitten themes` and `kitten choose-fonts`)

## Keybindings

### Tab Management (Ctrl+Alt)
| Key | Action |
|-----|--------|
| `Ctrl+Alt+Enter` | New tab |
| `Ctrl+Alt+W` | Close tab |
| `Ctrl+Alt+Q` | Close window |
| `Ctrl+Alt+H/L` | Previous/Next tab |
| `Ctrl+Alt+,/.` | Move tab backward/forward |

### Pane Navigation (Ctrl+Shift)
| Key | Action |
|-----|--------|
| `Ctrl+Shift+H/J/K/L` | Navigate to left/down/up/right pane |
| `Ctrl+Shift+Alt+H/J/K/L` | Move pane left/down/up/right |
| `Ctrl+Arrow keys` | Resize panes |
| `Ctrl+Home` | Reset pane sizes |
| `Ctrl+Shift+Space` | Cycle layouts |

### General
| Key | Action |
|-----|--------|
| `Ctrl+Shift+C/V` | Copy/Paste |
| `Ctrl+Plus/Minus` | Font size |
| `Ctrl+Shift+F` | Search scrollback |
| `Ctrl+Shift+S` | Save session |
| `Ctrl+Shift+Delete` | Clear terminal |

## Theming

Themes are per-machine and not tracked in the repo:
```bash
kitten themes              # Browse and apply a theme
```

Fonts are also per-machine:
```bash
kitten choose-fonts        # Select fonts interactively
```

## Daily Session

The tracked session lives at `sessions/daily.kitty-session`. The installer copies it to:

```bash
~/.config/kitty/sessions/daily.kitty-session
```

It also installs `~/.local/share/applications/kdev.desktop`, which appears in the app launcher as `kdev` and launches the same command as the `kdev` shell alias:

```bash
kitty --detach --session ~/.config/kitty/sessions/daily.kitty-session
```

## Requirements

- Kitty terminal emulator
- A Nerd Font for icons (install your preferred font, or use fonts/install.sh for Fira Code / JetBrains Mono)

## Customization

Create `~/.config/kitty/local.conf` for machine-specific overrides:
```conf
# Example local customizations
font_size 16.0
background_opacity 1.0
```

## Troubleshooting

**Font not displaying correctly:**
- Install a Nerd Font or run `fonts/install.sh`
- Update font cache: `fc-cache -f`

**Shortcuts not working:**
- Check for conflicting system shortcuts
- Verify kitty version: `kitty --version`
