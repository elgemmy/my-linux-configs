# Vim Configuration

Clean, development-focused Vim configuration optimized for keyboard-centric workflows.

## Quick Setup

### Automatic Installation
```bash
./install.sh
```

### Manual Installation
```bash
# Install vim with clipboard support
sudo apt install vim-gtk3 xclip    # Ubuntu/Debian
sudo dnf install vim-enhanced xclip # Fedora

# Copy configuration
cp vimrc ~/.vimrc

# Create undo directory
mkdir -p ~/.vim/undo
```

## Key Features

- **System clipboard integration** - seamless copy/paste with other applications
- **Smart search** - case-insensitive by default, case-sensitive when needed
- **Vim motions** - H/L for line beginning/end, Ctrl+hjkl for window navigation
- **Quick escape** - `jj` alternative to Escape key
- **Persistent undo** - undo history survives file closes
- **Clean interface** - relative line numbers, current line highlighting
- **Git commit formatting** — automatic column guide at 72 characters and spell check for commit messages

## Essential Key Bindings

| Key | Action |
|-----|--------|
| `jj` | Exit insert mode |
| `Tab` | Exit insert mode (alternative to jj/Esc) |
| `Space` | Clear search highlighting |
| `H` / `L` | Beginning / end of line |
| `Ctrl+h/j/k/l` | Navigate between split windows |
| `,y` | Copy to system clipboard |
| `,p` | Paste from system clipboard |

## Requirements

- Vim with clipboard support (`vim --version | grep +clipboard`)
- `xclip` for system clipboard integration

## Customization

Create `~/.vimrc.local` for machine-specific settings:
```vim
" Example local customizations
set background=light
colorscheme desert
```

## Troubleshooting

**Clipboard not working:**
- Verify clipboard support: `vim --version | grep clipboard`
- Install clipboard package: `sudo apt install vim-gtk3 xclip`

**Search highlighting persists:**
- Press `Space` to clear highlighting
