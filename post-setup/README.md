# Post-Setup: External Tools & Configuration

Tools like Bitwarden CLI, GitHub CLI, Docker, and Go have their own installers that change frequently and require manual steps (authentication, kernel changes, group membership). Rather than automating fragile installs, this module verifies what's present and helps you wire up configuration.

## Two-Layer Philosophy

1. **Install scripts** (fonts, zsh, kitty, vim, etc.) — handle package manager installs and config file placement. Reliable and automated.
2. **Post-setup** — checks for external tools, prints install instructions for missing ones, and wires up config files that depend on those tools.

## Usage

### Check Tool Status
```bash
./check.sh
```

Shows which external tools are installed and provides install commands for missing ones:
- `bw` (Bitwarden CLI)
- `gh` (GitHub CLI)
- `git-credential-bitwarden` (custom credential helper)
- `docker`
- `go`
- `nvm` / `node`

### Interactive Configuration
```bash
./configure.sh
```

Runs `check.sh` first, then:
1. Offers to set up the git credential helper (if `bw` is installed)
2. Creates `~/.zshrc.local` template (if missing) — with commented-out NVM loading, PATH placeholders, and opt-in Cursor Agent shell integration
3. Creates `~/.zshrc.work` template (if missing) — for work-specific functions

## Extension Files

### `~/.zshrc.local`
Machine-specific configuration. Created by `configure.sh` with a template, then populated on-demand:
- **NVM loading** — uncomment after installing NVM
- **Docker helpers** — added automatically by `dev/install-optional.sh` when Docker is installed
- **PostgreSQL helpers** — added automatically by `dev/install-optional.sh` when PostgreSQL client is installed
- **Kitty aliases** — added automatically by `kitty/install.sh`
- **Cursor Agent shell integration** — keep opt-in to avoid blocking VS Code/Cursor shell environment resolution
- **Extra PATH entries** — for tools installed to non-standard locations

### `~/.zshrc.work`
Work-specific functions and aliases. Not populated by install scripts — edit manually for your work environment (e.g., Odoo helpers, company-specific tools).

## Installing External Tools

### Bitwarden CLI
```bash
# Via snap (recommended on Ubuntu)
sudo snap install bw

# Via npm
npm install -g @bitwarden/cli
```

### GitHub CLI
```bash
# Ubuntu/Debian (requires adding the repo first)
# See: https://github.com/cli/cli/blob/trunk/docs/install_linux.md
sudo apt install gh

# Fedora
sudo dnf install gh
```

### Docker
```bash
# See official docs for your distro:
# https://docs.docker.com/engine/install/

# Fedora
sudo dnf install docker docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
# Log out and back in for group changes
```

### Go
```bash
# Official method:
# https://go.dev/doc/install

# Quick installer:
bash <(curl -sL https://raw.githubusercontent.com/kerolloz/go-installer/master/go-installer.sh)
```

### NVM / Node.js
```bash
# Install NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# Then uncomment the NVM lines in ~/.zshrc.local
# Install Node.js LTS
nvm install --lts
nvm alias default lts/*
```
