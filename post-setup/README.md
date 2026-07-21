# Post-Setup: External Tools & Configuration

Some tools change frequently or need manual authentication. This module checks
what is present and wires up local templates without forcing a credential setup.

## Usage

### Check Tool Status

```bash
./check.sh
```

Checks:
- `gh` (GitHub CLI)
- `docker`
- `go`
- `nvm` / `node`

### Interactive Configuration

```bash
./configure.sh
```

Runs `check.sh` first, then:
1. Offers baseline Git setup: global gitignore, `core.excludesFile`, and identity prompts
2. Creates `~/.zshrc.local` template if missing
3. Creates `~/.zshrc.work` template if missing

Git credentials are intentionally not configured here. Prefer SSH keys,
`gh auth login`, or a credential manager configured outside this repo.

## Extension Files

### `~/.zshrc.local`

Machine-specific configuration. Created by `configure.sh` with a template:
- Extra PATH entries
- Opt-in Cursor Agent shell integration
- Private aliases or one-off machine-local helpers

### `~/.zshrc.work`

Work-specific functions and aliases. Not populated by install scripts; edit
manually for your work environment.

## Installing External Tools

### GitHub CLI

```bash
# Debian/Ubuntu, after adding the official gh repo
sudo apt install gh
```

### Docker

```bash
# Follow the Debian or Ubuntu instructions:
# https://docs.docker.com/engine/install/
```

### Go

```bash
bash <(curl -sL https://raw.githubusercontent.com/kerolloz/go-installer/master/go-installer.sh)
```

### NVM / Node.js

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
nvm install --lts
nvm alias default lts/*
```
