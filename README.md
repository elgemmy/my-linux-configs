# Ubuntu/Debian development environment

The supported path installs a useful development baseline on **Debian or
Ubuntu amd64/x86_64**: Git, Zsh, modern CLI utilities, Vim, Python, Node, Rust,
the official Kitty and Neovim binaries, Tree-sitter, and the tracked
configuration.

## Fresh machine

The bootstrap keeps the repository in a stable location because managed config
files link back to it. On the current testing branch:

```bash
sudo apt-get update && sudo apt-get install -y curl
curl -fsSL https://raw.githubusercontent.com/elgemmy/my-linux-configs/testing-deb-vm/bootstrap.sh | bash
```

With no arguments, `bootstrap.sh` installs the full `desktop` profile
non-interactively. It installs Git if needed, clones
`testing-deb-vm` into `~/.local/share/my-linux-configs`, and runs setup. To
select another profile:

```bash
curl -fsSL https://raw.githubusercontent.com/elgemmy/my-linux-configs/testing-deb-vm/bootstrap.sh |
  bash -s -- --profile developer --non-interactive
```

If you already have the repository:

```bash
./setup.sh --profile developer --plan       # local plan; no writes/sudo/downloads/logs
./setup.sh --profile developer
./setup.sh --profile desktop --non-interactive
./doctor.sh --profile developer
```

`--non-interactive` requires an explicit profile and never reads stdin. There is no `--only` or `--check` mode.

## Fully expanded profiles

* `minimal`: `core shell git vim`
* `developer`: `core shell git vim python node rust`
* `desktop`: `core git shell vim fonts kitty python node rust neovim editors`

The desktop order is intentional: the terminal is installed early, language
runtimes follow, and Neovim is bootstrapped after them so Mason-backed tools can
use Node/Python/Rust. A failed user-tool module is reported immediately but does
not prevent independent modules from being attempted. Setup exits unsuccessfully
after printing a per-module summary and running the complete health check.

Go and Java are intentional extras, never profile dependencies:

```bash
./extras/install.sh             # interactive selection
./extras/install.sh go java     # explicit
```

Go uses the distribution `golang-go`; Java installs exactly the distribution `default-jdk` and reports a `JAVA_HOME` dynamically derived from the selected `java`. Apt packages are intentionally unpinned. Node, Rust, Neovim, Kitty, Tree-sitter, Starship, Oh My Zsh, and its custom plugins use the revisions, release versions, or checksums recorded in `versions.conf`; upstream release publishers remain an explicit trust boundary.

## Package and configuration policy

All profile package requirements are collected first. Installed packages are queried without sudo. If anything is missing, setup performs one `apt-get update`, verifies every candidate, then one fatal `apt-get install` transaction. If complete, apt is not called. Python is distro Python plus `venv`, pip and pipx—never `pip --user` or `--break-system-packages`. Common CLI tools come from apt; `batcat`/`fdfind` compatibility names are placed in `~/.local/bin` without Cargo builds.

Configuration deployment uses explicit **per-file symlinks** from the home directory into this repository. Keep the clone in a stable location: moving or deleting it breaks managed configuration until setup is rerun from the new path. `bootstrap.sh` uses `~/.local/share/my-linux-configs` for that reason. Correct links are no-ops. Every conflicting file, directory, or link in one run is moved into one timestamped `$XDG_STATE_HOME/linux-config/backups/` tree, preserving its absolute-path-relative layout; `manifest.tsv` records backup/link operations. A deployment error rolls back links changed in that phase. This is transactional only for config deployment: apt changes and user changes after a successful prior run are outside recovery. Shared editor directories are never wholesale linked.

To recover a preserved conflict, first review the manifest and current target, remove the setup-managed replacement, then run `tools/restore-config-backup <backup-directory>`. The recovery tool refuses to overwrite an existing target.

Git setup owns only the XDG global ignore file. It never changes identity, credentials, SSH, or `gh`; doctor warns when identity is missing. Editor settings, keybindings, and extension lists remain under `editors/`. Setup deploys each config file but never installs extensions. Install desired IDs manually, for example:

```bash
xargs -n1 code --install-extension < editors/vscode/extensions.txt
```

The Zsh config is a small loader plus a managed feature module. Existing aliases
and productivity functions are preserved, while optional Kitty, Bitwarden,
Java, NVM, Starship, eza, bat, fd, and rg behavior activates only when
available. It does not force `TERM`, `LANG`, or `LC_ALL`, and preserves
`~/.zshrc.local` and `~/.zshrc.work`. Profiles containing `shell` set Zsh as the
account login shell. Log out and back in after the first successful or partially
successful run to start a real Zsh login session.

## Desktop and trusted-workflow utilities

Desktop setup installs the pinned official Kitty binary in `~/.local/kitty.app`,
creates the upstream `kitty` and `kitten` PATH links, installs both upstream
desktop entries, and deploys its config/session/launcher. It also installs the
pinned official Neovim binary and clones `elgemmy/nvim-config` directly into
`~/.config/nvim` (or `$XDG_CONFIG_HOME/nvim`). Existing Neovim configuration is
never overwritten. KDev launcher failures are written to
`~/.local/state/linux-config/kdev.log`; run `kdev --check` for a non-graphical
diagnostic. Desktop setup does **not** change the Cinnamon/GNOME default terminal
or autostart. Review and intentionally run `extras/desktop-preferences.sh` for
those changes. Editor extension installation is also manual.

`appimages/` and `tarapps/` retain their existing setup commands and all `tar-install`, `tar-update`, and `tar-uninstall` abilities. They are excluded from every profile because they are **intentional trusted-workflow utilities**: they execute/extract user-supplied application payloads and may manage desktop files or `/opt`. Review their dedicated READMEs before use.

The installer uses colored stage headers, explicit success/failure markers, and
a final summary. Colors are disabled when output is redirected or `NO_COLOR` is
set. Required module runners are validated before any mutation; a missing or
non-executable runner can no longer be skipped silently.

Legacy component scripts, broad permission repair, destructive backup tests, authentication helpers, post-setup mutation, and the old `install.sh` implementation remain for migration/history but are not used by normal setup. `install.sh` now warns and delegates to `setup.sh`.

## Validation

Run `tests/run.sh` for Bash syntax, optional ShellCheck, exact profile validation,
plan no-write, symlink conflict/idempotency/rollback, and doctor failure
semantics. Run `tests/container-smoke.sh` for fresh-install and rerun testing as
a non-root user across disposable Debian and Ubuntu containers. See
`testing/README.md` for the matrix, engine selection, and the Cinnamon VM
acceptance-test boundary. Neither test path performs a destructive host
installation.
