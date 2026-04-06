# Git Configuration

Bitwarden-based GitHub credential management — no PAT on disk, no GCM required.

## Quick Setup

```bash
./install.sh
```

This installs:
- `git-credential-bitwarden` — custom git credential helper that reads your GitHub PAT from Bitwarden
- `~/.gitignore_global` — global gitignore (IDE files)
- Git config entries for the credential helper and global gitignore

## Prerequisites

- **Bitwarden CLI** (`bw`): `sudo snap install bw` or `npm install -g @bitwarden/cli`
- **GitHub CLI** (`gh`): `sudo apt install gh` / `sudo dnf install gh`
- A GitHub Personal Access Token stored in Bitwarden as **"GitHub PAT"**

## How It Works

### The Credential Helper
`git-credential-bitwarden` implements git's credential helper protocol. When git needs credentials for `github.com`:

1. Git calls the helper with `get` on stdin
2. The helper checks for `$BW_SESSION` (set by `bw-unlock`)
3. If present, fetches the PAT from Bitwarden via `bw get password 'GitHub PAT'`
4. Returns the credentials to git

This means the PAT never touches disk — it lives only in Bitwarden and in memory during the session.

### The gh Wrapper
The ZSH configuration includes a `gh()` function that wraps the GitHub CLI:
- On first `gh` command, it fetches `GH_TOKEN` from Bitwarden
- Subsequent calls reuse the cached token for the session
- Requires `bw-unlock` to have been run first

### Daily Workflow
```bash
bw-unlock              # Once per terminal session
git push               # Silent — credential helper handles auth
gh pr create           # Silent — GH_TOKEN fetched lazily
```

## Manual Setup

If you prefer not to use the install script:

```bash
# Copy the credential helper
cp git-credential-bitwarden ~/.local/bin/
chmod +x ~/.local/bin/git-credential-bitwarden

# Configure git
git config --global credential.helper ~/.local/bin/git-credential-bitwarden
git config --global core.excludesFile ~/.gitignore_global

# Copy gitignore
cp gitignore_global ~/.gitignore_global
```

## Files

| File | Purpose |
|------|---------|
| `git-credential-bitwarden` | Custom credential helper script |
| `gitignore_global` | Global gitignore (IDE files) |
| `gitconfig.template` | Reference template for git config |
| `install.sh` | Automated setup script |

## Troubleshooting

**"BW_SESSION not set" errors:**
- Run `bw-unlock` to unlock Bitwarden for this terminal session

**Git still prompting for credentials:**
- Check: `git config --global credential.helper` should show the helper path
- Check: `ls -la ~/.local/bin/git-credential-bitwarden` should exist and be executable

**Wrong GitHub username:**
- The helper uses `el_gemmmy` as the username. Edit `~/.local/bin/git-credential-bitwarden` to change it.
