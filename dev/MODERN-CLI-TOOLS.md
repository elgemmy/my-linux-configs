# Modern CLI Tools Guide

Enhanced command-line tools that improve upon traditional Unix utilities with better performance, features, and user experience.

## Core Modern Replacements

### `bat` - Better `cat`
Modern cat with syntax highlighting and Git integration.

```bash
# Traditional
cat file.py

# Modern (bat)
bat file.py                    # Syntax highlighting
bat file.py --style=numbers   # Show line numbers
bat *.py                       # Multiple files with headers
bat file.py | head -20         # Works in pipes
```

**Key features:**
- Automatic syntax highlighting for 200+ languages
- Git integration (shows modifications)
- Automatic paging for large files
- Line numbers and file headers

### `fd` - Better `find`
Simple, fast, and user-friendly alternative to find.

```bash
# Traditional find (complex syntax)
find . -name "*.py" -type f

# Modern (fd)
fd .py                         # Find .py files
fd config                      # Find files/dirs with "config" in name
fd -e py                       # Find by extension
fd -t f config                 # Find files only (-t d for directories)
fd config /etc                 # Search in specific directory
```

**Key features:**
- Simpler syntax (no need for quotes or -name)
- Respects .gitignore by default
- Fast parallel execution
- Colored output
- Unicode support

### `ripgrep` (rg) - Better `grep`
Extremely fast text search tool.

```bash
# Traditional grep
grep -r "function" . --include="*.py"

# Modern (ripgrep)
rg "function"                  # Search in current directory
rg "function" --type py        # Search only Python files
rg "function" -A 3 -B 3        # Show context (3 lines before/after)
rg "function" -g "*.py"        # Glob pattern
rg "function" --stats          # Show search statistics
```

**Key features:**
- Automatically skips binary files and .gitignore files
- Support for many file types
- Extremely fast (often faster than grep)
- Unicode support
- Multiline search

### `eza` - Better `ls` (alternative to `ls`)
Modern ls with more features and better defaults.

```bash
# Traditional ls
ls -la

# Modern (eza) - if available
eza -la                        # Long format with all files
eza --tree                     # Tree view
eza --tree --level=2           # Tree with depth limit
eza --grid --icons             # Grid view with icons (if terminal supports)
eza --long --header --git      # Show git status
```

**Note:** eza may not be available in all repositories. Use standard `ls` if not installed.

## System Information Tools

### `htop` - Better `top`
Interactive process viewer with better interface.

```bash
# Traditional
top

# Modern (htop)
htop                           # Interactive process viewer
htop -u username               # Show processes for specific user
```

**Key features:**
- Color-coded CPU and memory usage
- Tree view of processes
- Mouse support
- Easy sorting and filtering
- Kill processes with F9

### `neofetch` - System Information
Displays system information in a visually appealing way.

```bash
neofetch                       # Show system info with ASCII art
neofetch --ascii_distro ubuntu # Force specific distro ASCII
neofetch --off                 # Text only, no ASCII art
```

**Use cases:**
- Quick system overview
- Screenshots and sharing system specs
- Server information display

### `tree` - Directory Structure
Display directory structure as a tree.

```bash
tree                           # Show current directory tree
tree -L 2                      # Limit depth to 2 levels
tree -a                        # Show hidden files
tree -I "node_modules|.git"    # Ignore specific directories
tree -f                        # Show full path
```

## Network and API Tools

### `httpie` - Better `curl`
Human-friendly HTTP client.

```bash
# Traditional curl (complex)
curl -X POST -H "Content-Type: application/json" -d '{"key":"value"}' https://api.ezample.com

# Modern (httpie)
http POST https://api.ezample.com key=value
http GET https://api.ezample.com/users
http PUT https://api.ezample.com/users/1 name="John" age:=30
http --download https://ezample.com/file.zip  # Download file
```

**Key features:**
- Simple, intuitive syntax
- Automatic JSON serialization
- Syntax highlighting
- Built-in authentication support
- Upload/download progress

### `jq` - JSON Processor
Command-line JSON processor for parsing and manipulating JSON data.

```bash
# Parse JSON response
curl -s https://api.github.com/users/octocat | jq '.'

# Extract specific fields
echo '{"name": "John", "age": 30}' | jq '.name'

# Filter arrays
echo '[{"name": "John", "age": 30}, {"name": "Jane", "age": 25}]' | jq '.[].name'

# Complex filtering
curl -s https://api.github.com/repos/microsoft/vscode/issues | jq '.[] | select(.state == "open") | .title'

# Pretty print JSON
cat data.json | jq '.'

# Extract and format
curl -s https://api.github.com/users/octocat | jq '{name: .name, location: .location}'
```

**Key features:**
- Powerful JSON filtering and transformation
- Built-in functions for common operations
- Streaming JSON parser
- Colorized output

## Database and Development Tools

### `sqlite3` - Lightweight Database
Command-line interface for SQLite databases.

```bash
# Create/open database
sqlite3 myapp.db

# Quick query
sqlite3 myapp.db "SELECT * FROM users LIMIT 5;"

# Import CSV
sqlite3 myapp.db ".mode csv" ".import data.csv users"

# Export to CSV
sqlite3 myapp.db ".headers on" ".mode csv" ".output users.csv" "SELECT * FROM users;"

# Database info
sqlite3 myapp.db ".tables"              # List tables
sqlite3 myapp.db ".schema users"        # Show table schema
```

### `nmap` - Network Discovery
Network exploration and security auditing tool.

```bash
# Scan local network
nmap 192.168.1.0/24

# Scan specific host
nmap google.com

# Port scan
nmap -p 80,443,22 google.com

# Service detection
nmap -sV google.com

# Quick host discovery
nmap -sn 192.168.1.0/24
```

**Warning:** Only use nmap on networks you own or have permission to scan.

## Getting Started Tips

### Setting Up Aliases
Add to your `~/.zshrc.local` (or `~/.bashrc` if using bash):

```bash
# Modern CLI aliases
alias cat='bat'                # Use bat instead of cat
alias find='fd'                # Use fd instead of find  
alias grep='rg'                # Use ripgrep instead of grep
alias ls='eza'                 # Use eza instead of ls (if available)
alias top='htop'               # Use htop instead of top

# Helpful shortcuts
alias ll='eza -la --git'       # Long listing with git status
alias tree2='tree -L 2'       # Tree with depth 2
alias json='jq .'              # Pretty print JSON
```

### Learning Progression

**Week 1: Start with basics**
- `bat` instead of `cat` for reading files
- `htop` instead of `top` for process monitoring
- `tree` for directory structure

**Week 2: Search and find**
- `fd` for finding files
- `rg` for searching content
- `jq` for JSON processing

**Week 3: Advanced usage**
- `httpie` for API testing
- `sqlite3` for database work
- Combine tools with pipes

### Practical Examples

#### Development Workflow
```bash
# Find Python files with TODO comments
fd -e py -x rg "TODO" {}

# Search for function definitions in Go files
rg "func \w+\(" --type go

# Pretty print API response
http GET https://api.github.com/user | jq '.name, .location'

# Monitor resource usage while running tests
htop &
python -m pytest
```

#### System Administration
```bash
# Find large files
fd -t f -x ls -lh {} | sort -k5 -hr | head -10

# Search logs for errors
rg "ERROR|FATAL" /var/log/ --type log

# Check network connectivity
nmap -sn 192.168.1.0/24

# Monitor system while debugging
htop --sort-key=PERCENT_CPU
```

#### Data Processing
```bash
# Process JSON API responses
curl -s https://api.ezample.com/data | jq '.results[] | {id, name, status}'

# Find and process files
fd "\.json$" | xargs -I {} jq '.important_field' {}

# Search and extract information
rg "version.*(\d+\.\d+\.\d+)" --only-matching
```

## Tool Combinations

### Powerful Pipes
```bash
# Find Python files and search for classes
fd -e py | xargs rg "class \w+:"

# Show git repositories and their status
fd -t d ".git" --max-depth 2 | sed 's/\.git$//' | xargs -I {} sh -c 'echo "=== {} ==="; git -C {} status --porcelain'

# Find large JSON files and validate them
fd -e json -x sh -c 'echo "File: {}"; jq empty {} && echo "Valid JSON" || echo "Invalid JSON"'

# Monitor processes and filter by name
htop --batch --iterations=1 | grep python
```

## Migration Guide

### From Traditional to Modern

| Traditional | Modern | Quick Start |
|-------------|--------|-------------|
| `cat file.py` | `bat file.py` | Better syntax highlighting |
| `find . -name "*.py"` | `fd .py` | Simpler syntax |
| `grep -r "text" .` | `rg "text"` | Faster, smarter defaults |
| `ls -la` | `eza -la` | Better colors and git info |
| `top` | `htop` | Interactive, more intuitive |
| `curl -X POST ...` | `http POST ...` | Human-friendly API calls |

### Gradual Adoption
1. **Start with one tool** - Pick `bat` or `htop` to begin
2. **Use alongside traditional** - Keep both until comfortable
3. **Create aliases** - Gradually replace traditional commands
4. **Learn one feature at a time** - Don't try to master everything immediately
5. **Practice with real tasks** - Use new tools for actual work

## When to Use Traditional Tools

Modern tools aren't always better for every situation:

- **Scripts and automation**: Traditional tools have more predictable output
- **Minimal systems**: Modern tools may not be available
- **Specific requirements**: Some advanced flags only exist in traditional tools
- **Compatibility**: When working with older systems or documentation

## Installation Troubleshooting

### Tool Not Available
```bash
# Check if tool is installed
command -v bat || echo "bat not installed"
command -v fd || echo "fd not installed"
command -v rg || echo "ripgrep not installed"

# Alternative installation methods
# bat: https://github.com/sharkdp/bat#installation
# fd: https://github.com/sharkdp/fd#installation  
# ripgrep: https://github.com/BurntSushi/ripgrep#installation
```

### Different Package Names
Some tools have different names in different distributions:
- `fd-find` (Ubuntu) vs `fd` (Fedora)
- `bat` vs `batcat` (older Ubuntu versions)

### Ubuntu Command Name Issues
```bash
# If fd command not found after installing fd-find
fdfind --version          # Check if fdfind works
echo "alias fd='fdfind'" >> ~/.zshrc.local

# If bat command not found but batcat exists
batcat --version          # Check if batcat works  
echo "alias bat='batcat'" >> ~/.zshrc.local

# Reload shell
source ~/.zshrc
```

### Performance Issues
If modern tools seem slow:
- Check if they're processing large .gitignore files
- Use `--no-ignore` flag to skip ignore files
- Increase system file descriptor limits if needed

### Quick Verification Script
```bash
#!/bin/bash
# test-modern-tools.sh
echo "=== Modern CLI Tools Verification ==="

tools=("fd:fdfind" "bat:batcat" "rg" "htop" "tree" "neofetch")
for tool_info in "${tools[@]}"; do
    IFS=':' read -r primary fallback <<< "$tool_info"
    if command -v "$primary" &> /dev/null; then
        echo "✅ $primary: $(command -v "$primary")"
    elif [ -n "$fallback" ] && command -v "$fallback" &> /dev/null; then
        echo "✅ $primary (as $fallback): $(command -v "$fallback")"
        echo "   💡 Add alias: echo \"alias $primary='$fallback'\" >> ~/.zshrc.local"
    else
        echo "❌ $primary: not found"
    fi
done

echo ""
echo "Run 'source ~/.zshrc' after adding aliases"
```

This guide covers the essential modern CLI tools that can significantly improve your command-line productivity. Start with one or two tools and gradually incorporate more as you become comfortable with them.
