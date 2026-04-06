# ZSH Configuration

Comprehensive ZSH setup with Oh My Zsh, development tools, and vim integration.

## Quick Setup


### Automatic Installation
```bash
./install.sh
```

### Manual Installation
```bash
# Install ZSH
sudo apt install zsh curl git  # Ubuntu/Debian
sudo dnf install zsh curl git  # Fedora

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

# Install Starship prompt
curl -sS https://starship.rs/install.sh | sh

# Copy configuration
cp zshrc ~/.zshrc

# Set as default shell
chsh -s $(which zsh)
```

## Key Features

- **Starship prompt** - Modern, fast, and customizable cross-shell prompt
- **Modern CLI tools** - eza, bat, fd-find, ripgrep, tig, fzf for enhanced productivity
- **Enhanced Oh My Zsh plugins** - JSON tools, web search, clipboard integration
- **Vi mode** for vim-like command line editing
- **Development aliases** for common tasks
- **Java version switching** between JDK 17 and 21
- **Git enhancements** - Interactive utilities and advanced workflows
- **Bitwarden/GitHub credential integration** (bw-unlock, lazy gh wrapper)
- **Enhanced history** with 10,000 commands
- **Smart completion** with case-insensitive matching
- **Syntax highlighting** and auto-suggestions

## 🧩 Oh My Zsh Plugins

### JSON Tools
```bash
pp_json '{"name":"test","data":[1,2,3]}'     # Pretty print JSON
is_json '{"valid": true}'                    # Validate JSON (returns exit code)
echo '{"test": "data"}' | pp_json            # Format JSON from pipe
urlencode_json '{"key": "value with spaces"}'  # URL encode JSON
urldecode_json 'encoded%20json'              # URL decode JSON
```

### Web Search
```bash
google "linux command line tips"            # Search Google
stackoverflow "zsh functions"               # Search Stack Overflow  
github "starship prompt"                    # Search GitHub
duckduckgo "privacy tools"                  # Search DuckDuckGo
youtube "terminal productivity"             # Search YouTube
```

### Clipboard Integration
```bash
copyfile ~/.zshrc                          # Copy file content to clipboard
copydir ~/Projects                         # Copy directory path to clipboard
```

### Sudo Enhancement
- Press `ESC` twice to add `sudo` to current command
- Press `ESC` twice on empty line to add `sudo` to previous command

## 🚀 Modern CLI Tools

### Enhanced File Listing (eza)
```bash
ls          # Lists with icons and colors
ll          # Long format with git status
la          # All files including hidden
lt          # Sort by modification time
tree        # Directory tree view with icons
```

### Better File Viewing (bat)
```bash
cat file.py    # Syntax highlighted output
less file.log  # Paged view with syntax highlighting
man ls         # Manual pages with syntax highlighting
```

### Fast File Finding (fd-find)
```bash
find "*.js"           # Find JavaScript files
fd test              # Find files/directories matching "test"
fd -e py             # Find Python files
fd -t f config       # Find files (not directories) matching "config"
```

### Advanced Text Search (ripgrep)
```bash
grep "function"       # Search for "function" in files
rg "TODO" --type js   # Search in JavaScript files only
rg -i "error"         # Case-insensitive search
rg -C 3 "import"      # Show 3 lines of context around matches
```

### Interactive Git (tig)
```bash
tig              # Browse git log interactively
tigs             # Interactive git status (stage/unstage files)
tigb             # View all branches
tig blame file   # Interactive git blame
```

### Fuzzy Finder (fzf)
```bash
fcd              # Fuzzy directory navigation
vff              # Fuzzy file finder with preview before editing
gswitch          # Interactive git branch switching
```

## 📁 Enhanced Functions

### Project Management
```bash
# Create projects with templates
mkproject myapp                    # Basic project with README
mkproject webapp node             # Node.js project with package.json
mkproject api python              # Python project with requirements.txt
mkproject service go              # Go project with go.mod

# Navigate and edit files
fcd                               # Fuzzy change directory
fcd ~/Projects                    # Fuzzy navigate within specific path
vff                               # Fuzzy file finder with preview
grepf "TODO" "*.js"              # Search for pattern in specific file types
```

### Process Management
```bash
psg nginx                         # Find processes matching "nginx"
```

## 🎯 Quick Aliases & Shortcuts

### Essential Aliases
| Alias | Command | Description |
|-------|---------|-------------|
| `v` | `vim` | Edit with vim |
| `vi` | `vim` | Edit with vim |
| `ll` | `ls -la` | Long list with hidden files |
| `la` | `ls -A` | List all files |
| `lt` | `ls -ltr` | List by time (newest last) |
| `lh` | `ls -lah` | Human readable long list |

### Git Shortcuts
| Alias | Command | Description |
|-------|---------|-------------|
| `gs` | `git status` | Show git status |
| `ga` | `git add` | Stage files |
| `gc` | `git commit` | Commit changes |
| `gp` | `git push` | Push to remote |
| `gl` | `git log --oneline -10` | Show last 10 commits |
| `gd` | `git diff` | Show differences |
| `gb` | `git branch` | List branches |
| `gco` | `git checkout` | Switch branches/checkout |

### Development Shortcuts
| Alias | Command | Description |
|-------|---------|-------------|
| `py` | `python3` | Run Python 3 |
| `pip` | `pip3` | Use pip3 |
| `serve` | `python3 -m http.server` | Quick HTTP server |
| `jsonpp` | `python3 -m json.tool` | Pretty print JSON |

### Navigation Shortcuts
| Alias | Command | Description |
|-------|---------|-------------|
| `proj` | `cd ~/Projects` | Go to Projects directory |
| `repos` | `cd ~/Projects/repos` | Go to repos directory |
| `docs` | `cd ~/Documents` | Go to Documents |
| `dwn` | `cd ~/Downloads` | Go to Downloads |
| `..` | `cd ..` | Go up one directory |
| `...` | `cd ../..` | Go up two directories |
| `....` | `cd ../../..` | Go up three directories |

## 🔧 Git Enhancements

### Enhanced Git Aliases
```bash
# Status and Information
gs          # git status
gst         # git status (short format with branch info)
gl          # git log --oneline (last 10)
glog        # git log with graph, decorations (last 20)

# Working with Changes  
ga          # git add
gc          # git commit
gd          # git diff
gdiff       # git diff (word-level differences)

# Branch Management
gb          # git branch
gco         # git checkout
gnew feat   # Create and switch to new branch "feat"
gswitch     # Interactive branch switching with fuzzy finder

# Remote Operations
gp          # git push
gpull       # git pull with autostash
gsync       # Safe sync: pull with rebase + push

# Utilities
gundo       # Undo last commit (keep changes staged)
gclean      # Nuclear option: remove all uncommitted changes
gwip        # Quick WIP commit with timestamp
```

### Git Usage Guidelines

**Safe Commands (use anytime):**
- `gst`, `glog`, `gdiff` - Information only
- `gnew`, `gswitch` - Branch navigation
- `gwip` - Quick work-in-progress saves
- `gundo` - Safe undo (keeps your changes)

**Use with Caution:**
- `gsync` - Don't use on shared branches where others might have pushed
- `gclean` - Permanently deletes uncommitted changes
- `gpull` - Rebases, which rewrites history

## 🛠 Development Environment Utilities

### Java Environment
```bash
setJdk17    # Switch to Java 17
setJdk21    # Switch to Java 21
devinfo     # Show all development tool versions
```

### Development Servers
```bash
serve-py 8080              # Start Python HTTP server on port 8080
```

### Environment Setup and Information
```bash
devinfo                    # Display all installed development tools
setup-env node             # Initialize Node.js project with linting
setup-env python           # Create Python virtual environment  
setup-env go               # Initialize Go module
```

## ⚡ Performance Optimizations

### Modern Tool Benefits
- **eza**: 3x faster than `ls` with better output
- **bat**: Instant syntax highlighting vs. slower external tools
- **fd**: 10x faster than `find` with simpler syntax
- **ripgrep**: 5x faster than `grep` with better defaults

## 📚 Command Reference

### Quick Navigation
| Command | Description |
|---------|-------------|
| `proj` | `cd ~/Projects` |
| `repos` | `cd ~/Projects/repos` |
| `docs` | `cd ~/Documents` |
| `..` | Go up one directory |
| `...` | Go up two directories |

### Development Shortcuts  
| Alias | Command | Description |
|-------|---------|-------------|
| `v` | `vim` | Edit with vim |
| `py` | `python3` | Run Python 3 |
| `serve` | `python3 -m http.server` | Quick HTTP server |
| `jsonpp` | `python3 -m json.tool` | Pretty print JSON |

### System Information
| Command | Description |
|---------|-------------|
| `myip` | Show external IP address |
| `ports` | Show network ports in use |
| `meminfo` | Memory usage information |
| `cpuinfo` | CPU information |
| `diskusage` | Disk space usage |

## Requirements

- ZSH shell
- Oh My Zsh
- Git and curl

## Customization

Create local configuration files:
- `~/.zshrc.local` — Machine-specific customizations (NVM, extra paths, tool helpers)
- `~/.zshrc.work` — Work-specific settings

## 🔐 Bitwarden & GitHub Integration

Seamless GitHub authentication using a PAT stored in Bitwarden — no credentials on disk.

### Setup
1. Store your GitHub Personal Access Token in Bitwarden as "GitHub PAT"
2. Install Bitwarden CLI: `sudo snap install bw` or `npm install -g @bitwarden/cli`
3. Run `git/install.sh` to set up the credential helper

### Daily Workflow
```bash
bw-unlock          # Unlock Bitwarden (once per terminal session)
git push           # Just works — credential helper fetches PAT from Bitwarden
gh pr create       # Just works — GH_TOKEN fetched lazily on first gh command
```

### How It Works
- `bw-unlock` exports `BW_SESSION` for the terminal session
- `git push/pull` triggers `git-credential-bitwarden` which reads the PAT via Bitwarden CLI
- `gh` is wrapped to lazily fetch `GH_TOKEN` from Bitwarden on first use

## 🔧 On-Demand Shell Helpers

Docker, PostgreSQL, and Kitty helpers are added to `~/.zshrc.local` automatically when their respective tools are installed via the repo's install scripts. They are not in the base zshrc to keep it clean and portable.

See `dev/install-optional.sh` for Docker and PostgreSQL, `kitty/install.sh` for Kitty aliases.

## Troubleshooting

**Vi mode not working:**
- Restart terminal or run `exec zsh`
- Check with `bindkey -L | grep vi`

**Plugins not loading:**
- Verify plugin directories exist
- Run `source ~/.zshrc` to reload
