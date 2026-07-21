# Ubuntu/Debian workstation bootstrap

The supported path is a straightforward Bash bootstrap for **Ubuntu (primary)** and Debian on amd64/x86_64. Run it from any directory; it refuses root. `setup.sh` mutates the machine, while `doctor.sh` is strictly read-only (no sudo, writes, or network).

```bash
./setup.sh --profile developer --plan       # local plan; no writes/sudo/downloads/logs
./setup.sh --profile developer
./setup.sh --profile minimal --non-interactive
./doctor.sh --profile developer
```

`--non-interactive` requires an explicit profile and never reads stdin. There is no `--only` or `--check` mode.

## Fully expanded profiles

* `minimal`: `core shell git vim`
* `developer`: `core shell git vim python node rust`
* `desktop`: `core shell git vim python node rust fonts kitty editors`

Go and Java are intentional extras, never profile dependencies:

```bash
./extras/install.sh             # interactive selection
./extras/install.sh go java     # explicit
```

Go uses the distribution `golang-go`; Java installs exactly the distribution `default-jdk` and reports a `JAVA_HOME` dynamically derived from the selected `java`. Apt packages are intentionally unpinned. Node, Rust, Starship, Oh My Zsh, and its custom plugins use the revisions or checksums recorded in `versions.conf`; upstream release publishers remain an explicit trust boundary.

## Package and configuration policy

All profile package requirements are collected first. Installed packages are queried without sudo. If anything is missing, setup performs one `apt-get update`, verifies every candidate, then one fatal `apt-get install` transaction. If complete, apt is not called. Python is distro Python plus `venv`, pip and pipx—never `pip --user` or `--break-system-packages`. Common CLI tools come from apt; `batcat`/`fdfind` compatibility names are placed in `~/.local/bin` without Cargo builds.

Configuration deployment is **currently copy-based**. Explicit per-file mappings are centralized in `lib/deploy.sh` so a later small migration can switch correct targets to symlinks. Identical files are no-ops. Every conflict in one run is moved into one timestamped `$XDG_STATE_HOME/linux-config/backups/` tree, preserving its absolute-path-relative layout; `manifest.tsv` records backup/copy operations. A deployment error rolls back files changed in that phase. This is transactional only for config deployment: apt changes and user changes after a successful prior run are outside recovery. Shared editor directories are never wholesale copied.

To recover a preserved conflict, first review the manifest and current target, remove the setup-managed replacement, then run `tools/restore-config-backup <backup-directory>`. The recovery tool refuses to overwrite an existing target.

Git setup owns only the XDG global ignore file. It never changes identity, credentials, SSH, or `gh`; doctor warns when identity is missing. Editor settings, keybindings, and extension lists remain under `editors/`. Setup deploys each config file but never installs extensions. Install desired IDs manually, for example:

```bash
xargs -n1 code --install-extension < editors/vscode/extensions.txt
```

The Zsh config is a small loader plus a managed feature module. Existing aliases and productivity functions are preserved, while optional Kitty, Bitwarden, Java, NVM, Starship, eza, bat, fd, and rg behavior activates only when available. It does not force `TERM`, `LANG`, or `LC_ALL`, and preserves `~/.zshrc.local` and `~/.zshrc.work`.

## Desktop and trusted-workflow utilities

Desktop setup installs Kitty via apt and deploys its config/session/launcher plus per-file editor settings. It deliberately does **not** change login shell, default terminal, or autostart. Review and intentionally run `extras/desktop-preferences.sh` for those changes. Editor extension installation is also manual.

`appimages/` and `tarapps/` retain their existing setup commands and all `tar-install`, `tar-update`, and `tar-uninstall` abilities. They are excluded from every profile because they are **intentional trusted-workflow utilities**: they execute/extract user-supplied application payloads and may manage desktop files or `/opt`. Review their dedicated READMEs before use.

Legacy component scripts, broad permission repair, destructive backup tests, authentication helpers, post-setup mutation, and the old `install.sh` implementation remain for migration/history but are not used by normal setup. `install.sh` now warns and delegates to `setup.sh`.

## Validation

Run `tests/run.sh` for Bash syntax, optional ShellCheck, exact profile validation, plan no-write, copy conflict/idempotency/rollback, and doctor failure semantics. `tests/container-smoke.sh` documents the Ubuntu/Debian container smoke entry point. Tests do not perform destructive host installation.
