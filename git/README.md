# Git Configuration

Simple Git baseline setup for a fresh machine.

## Quick Setup

```bash
./install.sh
```

This installs/configures:
- `~/.gitignore_global` — global gitignore for editor and OS noise
- `core.excludesFile` — points Git at the global gitignore
- `user.name` and `user.email` prompts if they are missing

It intentionally does **not** configure a credential helper. Use SSH keys,
`gh auth login`, or your preferred credential manager outside this repo.

## Manual Setup

```bash
cp gitignore_global ~/.gitignore_global
git config --global core.excludesFile ~/.gitignore_global
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

## Files

| File | Purpose |
|------|---------|
| `gitignore_global` | Global gitignore for editor/OS noise |
| `gitconfig.template` | Reference template for Git config |
| `install.sh` | Automated Git baseline setup |

## GitHub Auth

Recommended options:
- SSH remotes with an SSH key added to GitHub
- `gh auth login` for GitHub CLI operations
- A credential manager installed/configured outside this repo, if you prefer HTTPS
